module PuppetX
  module Centreon

    class Centreon < Puppet::Provider
      
        def self.read_only(*methods)
        methods.each do |method|
          define_method("#{method}=") do |v|
            Puppet.warning "#{method} property is read-only once #{resource.type} created."
          end
        end
      end

      def self.logger
        log_name = 'puppet-centreon-debug.log'
        if global_configuration and global_configuration['default'] and global_configuration['default']['logger']
          Logger.new(log_name) if global_configuration['default']['logger'] == 'true'
        elsif ENV['PUPPET_CENTREON_DEBUG_LOG'] and not ENV['PUPPET_CENTREON_DEBUG_LOG'].empty?
          Logger.new(log_name)
        else
          nil
        end
      end

      def self.global_credentials
        # Under a Puppet agent we don't have the HOME environment variable available
        # so the standard way of detecting the location for the config file doesn't
        # work. The following provides a fall back method to a confdir config file.
        # The preference is still to use IAM instance roles if possible.
        begin
          Puppet.initialize_settings unless Puppet[:confdir]
          {
            user: ENV['CENTREON_USERNAME'],
            password: ENV['CENTREON_PASSWORD']
          }
        rescue ::Aws::Errors::NoSuchProfileError
          nil
        end
      end

      def self.global_configuration
        Puppet.initialize_settings unless Puppet[:confdir]
        path = File.join(Puppet[:confdir], 'puppetlabs_centreon_configuration.ini')
        File.exists?(path) ? ini_parse(File.new(path)) : nil
      end


      def self.client_config()
        config = {logger: logger}
        config[:credentials] = global_credentials if global_credentials
        config
      end

      # This method is vendored from the AWS SDK, rather than including an
      # extra library just to parse an ini file
      def self.ini_parse(file)
        current_section = {}
        map = {}
        file.rewind
        file.each_line do |line|
          line = line.split(/^|\s;/).first # remove comments
          section = line.match(/^\s*\[([^\[\]]+)\]\s*$/) unless line.nil?
          if section
            current_section = section[1]
          elsif current_section
            item = line.match(/^\s*(.+?)\s*=\s*(.+?)\s*$/) unless line.nil?
            if item
              map[current_section] = map[current_section] || {}
              map[current_section][item[1]] = item[2]
            end
          end
        end
        map
      end

      def self.centreon_client(url)
        config = client_config
        r = ::RestClient.post(url, {params: {action: "authenticate"}}, {username: config["credentials"]["user"], password["credentials"]["password"]})
        data = JSON.parse(r.body)
        ::RestClient::Resource.new(url, {headers: {"centreon-auth-token": data["authToken"]}})

      end

      def centreon_client(url)
        self.class.centreon_client(url)
      end


      # Set up the @hosts.
      def self.init_hosts()
        @hosts ||= {}
      end

      def self.host_id_from_name(host_name)
        self.ec2_host_ids_from_names([host_name]).first
      end

      def self.host_ids_from_names(host_names)
        self.init_hosts()

        host_names_to_discover = []
        host_names.each do |host_name|
          next if @hosts.has_value?(host_name)
          host_names_to_discover << host_name
        end

        unless host_names_to_discover.empty?
          Puppet.debug("Calling centreon_client to resolve hosts: #{host_names_to_discover}")

          hosts_info = centreon_client(url).get()
          # TODO Check if we have next_token on the response

          instance_info.each do |response|
            response.data.reservations.each do |reservation|
              reservation.instances.each do |instance|
                instance_name_tag = instance.tags.detect { |tag| tag.key == 'Name' }
                if instance_name_tag
                  @ec2_instances[region][instance.instance_id]= instance_name_tag.value
                end
              end
            end
          end
        end

        instance_names.collect do |instance_name|
          @security_groups[region].key(instance_name)
        end.compact
      end

      def self.ec2_instance_name_from_id(region, instance_id)
        self.ec2_instance_names_from_ids(region, [instance_id]).first
      end

      def self.ec2_instance_names_from_ids(region, instance_ids)
        self.init_ec2_instances(region)

        instance_ids_to_discover = []
        instance_ids.each do |instance_id|
          next if @ec2_instances[region].has_key?(instance_id)
          instance_ids_to_discover << instance_id
        end

        unless instance_ids_to_discover.empty?
          Puppet.debug("Calling ec2_client to resolve instances: #{instance_ids_to_discover}")
          instance_info = ec2_client(region).describe_instances(instance_ids: instance_ids_to_discover)

          # TODO Check if we have next_token on the response

          instance_info.each do |response|
            response.data.reservations.each do |reservation|
              reservation.instances.each do |instance|
                instance_name_tag = instance.tags.detect { |tag| tag.key == 'Name' }
                if instance_name_tag
                  @ec2_instances[region][instance.instance_id]= instance_name_tag.value
                end
              end
            end
          end
        end

        instance_ids.collect do |instance_id|
          @ec2_instances[region][instance_id]
        end.compact
      end

      # Set up @security_groups. Always call this method before using
      # @security_groups. @security_groups[region] keeps track of security
      # group IDs => names discovered per region, to prevent duplicate API
      # calls.
      def self.init_security_groups(region)
        @security_groups ||= {}
        @security_groups[region] ||= {}
      end

      def self.security_group_id_from_name(region, sg_name)
        self.security_group_ids_from_names(region, [sg_name]).first
      end

      def self.security_group_ids_from_names(region, sg_names)
        self.init_security_groups(region)

        sg_names_to_discover = []
        sg_names.each do |sg_name|
          next if @security_groups[region].has_value?(sg_name)
          sg_names_to_discover << sg_name
        end

        unless sg_names_to_discover.empty?
          Puppet.debug("Calling ec2_client to resolve security_groups: #{sg_names_to_discover}")
          sg_info = ec2_client(region).describe_security_groups(filters: [{
            name: 'group-name',
            values: sg_names_to_discover,
          }])

          sg_info.security_groups.each do |sg|
            @security_groups[region][sg.group_id] = sg.group_name
          end
        end

        sg_names.collect do |sg_name|
          @security_groups[region].key(sg_name)
        end.compact
      end

      def self.security_group_name_from_id(region, sg_id)
        self.security_group_names_from_ids(region, [sg_id]).first
      end

      def self.security_group_names_from_ids(region, sg_ids)
        self.init_security_groups(region)

        sg_ids_to_discover = []
        sg_ids.each do |sg_id|
          sg_ids_to_discover << sg_id unless @security_groups[region].has_key?(sg_id)
        end

        unless sg_ids_to_discover.empty?
          Puppet.debug("Calling ec2_client to resolve security_groups: #{sg_ids_to_discover}")
          sg_info = ec2_client(region).describe_security_groups(group_ids: sg_ids_to_discover)

          sg_info.security_groups.each do |sg|
            @security_groups[region][sg.group_id] = sg.group_name
          end
        end

        sg_ids.collect do |sg_id|
          @security_groups[region][sg_id]
        end.compact
      end

      # Set up @subnets. Always call this method before using @subnets.
      # @subnets[region] keeps track of subnet IDs => names discovered per
      # region, to prevent duplicate API calls.
      def self.init_subnets(region)
        @subnets ||= {}
        @subnets[region] ||= {}
      end

      def self.subnet_id_from_name(region, subnet_name)
        self.subnet_ids_from_names(region, [subnet_name]).first
      end

      def self.subnet_ids_from_names(region, subnet_names)
        self.init_subnets(region)

        subnet_names_to_discover = []
        subnet_names.each do |subnet_name|
          next if @subnets[region].has_value?(subnet_name)
          subnet_names_to_discover << subnet_name
        end

        unless subnet_names_to_discover.empty?
          Puppet.debug("Calling ec2_client to resolve subnets: #{subnet_names_to_discover}")
          subnet_info = ec2_client(region).describe_subnets(filters: [{
            name: 'tag:Name',
            value: subnet_names_to_discover
          }])

          subnet_info.subnets.each do |subnet|
            subnet_name_tag = subnet.tags.detect { |tag| tag.key == 'Name' }
            if subnet_name_tag
              @subnets[region][subnet.subnet_id] = subnet_name_tag.value
            end
          end
        end

        subnet_names.collect do |subnet_name|
          @security_groups[region].key(subnet_name)
        end.compact
      end

      def self.subnet_name_from_id(region, subnet_id)
        self.subnet_names_from_ids(region, [subnet_id]).first
      end

      def self.subnet_names_from_ids(region, subnet_ids)
        self.init_subnets(region)

        subnet_ids_to_discover = []
        subnet_ids.each do |subnet_id|
          next if @subnets[region].has_key?(subnet_id)
          subnet_ids_to_discover << subnet_id
        end

        unless subnet_ids_to_discover.empty?
          Puppet.debug("Calling ec2_client to resolve subnets: #{subnet_ids_to_discover}")
          subnet_info = ec2_client(region).describe_subnets(
            subnet_ids: subnet_ids_to_discover
          )

          subnet_info.subnets.each do |subnet|
            subnet_name_tag = subnet.tags.detect { |tag| tag.key == 'Name' }
            if subnet_name_tag
              @subnets[region][subnet.subnet_id] = subnet_name_tag.value
            end
          end
        end

        subnet_ids.collect do |subnet_id|
          @subnets[region][subnet_id]
        end.compact
      end


      ####

      def self.customer_gateway_name_from_id(region, gateway_id)
        @customer_gateways ||= name_cache_hash do |ec2, key|
          response = ec2.describe_customer_gateways(customer_gateway_ids: [key])
          extract_name_from_tag(response.data.customer_gateways.first)
        end

        @customer_gateways[[region, gateway_id]]
      end

      def self.vpn_gateway_name_from_id(region, gateway_id)
        @vpn_gateways ||= name_cache_hash do |ec2, key|
          response = ec2.describe_vpn_gateways(vpn_gateway_ids: [key])
          extract_name_from_tag(response.data.vpn_gateways.first)
        end
        @vpn_gateways[[region, gateway_id]]
      end

      def self.options_name_from_id(region, options_id)
        @dhcp_options ||= name_cache_hash do |ec2, key|
          response = ec2.describe_dhcp_options(dhcp_options_ids: [key])
          extract_name_from_tag(response.dhcp_options.first)
        end

        @dhcp_options[[region, options_id]]
      end

      def self.name_cache_hash(&block)
        Hash.new do |h, rk|
          region, key = rk
          h[key] = unless key.nil? || key.empty?
            block.call(ec2_client(region), key)
          else
            nil
          end
        end
      end

      def queue_url_from_name(queue_name )
        sqs = sqs_client(target_region)
        response = sqs.get_queue_url ({queue_name: name})
        response.data.queue_url
      end

      def self.gateway_name_from_id(region, gateway_id)
        ec2 = ec2_client(region)
        @gateways ||= Hash.new do |h, key|
          h[key] = if key == 'local'
            'local'
          elsif key
            begin
              igw_response = ec2.describe_internet_gateways(internet_gateway_ids: [key])
              extract_name_from_tag(igw_response.data.internet_gateways.first)
            rescue ::Aws::EC2::Errors::InvalidInternetGatewayIDNotFound
              begin
                vgw_response = ec2.describe_vpn_gateways(vpn_gateway_ids: [key])
                extract_name_from_tag(vgw_response.data.vpn_gateways.first)
              rescue ::Aws::EC2::Errors::InvalidVpnGatewayIDNotFound
                nil
              end
            end
          else
            nil
          end
        end
        @gateways[gateway_id]
      end

      def self.peering_name_from_id(region, peering_id)
        ec2 = ec2_client(region)
        @peering ||= Hash.new do |h, key|
          if key
            begin
              pcx_response = ec2.describe_vpc_peering_connections(vpc_peering_connection_ids: [key])
              extract_name_from_tag(pcx_response.data.vpc_peering_connections.first)
            rescue ::Aws::EC2::Errors::InvalidVpcPeeringConnectionIDNotFound
              nil
            end
          else
            nil
          end
        end
        @peering[peering_id]
      end

      def self.normalize_hash(hash)
        # Sort and format the received hash for simpler comparison.
        #
        # Symbolized keys are converted to string'd keys.  Values are sent to the
        # normalize_values method for processing.  Returns a hash sorted by keys.
        #
        data = {}

        fail "Invalid data type when attempting normalize of hash: #{hash.class}" unless hash.is_a? Hash

        hash.keys.sort_by{|k|k.to_s}.each {|k|
          value = hash[k]
          data[k.to_s] = self.normalize_values(value)
        }
        sorted_hash = {}
        data.keys.sort.each {|k|
          sorted_hash[k] = data[k]
        }
        sorted_hash
      end

      def self.normalize_values(value)
        # Convert the received value data into a standard format for simpler
        # comparison.
        #
        # This results in the conversion of boolean strings to booleans, string
        # integers to integers, etc.  Array values are recursively normalized.
        # Hash values are normalized using the normalize_hash method.
        #
        if value.is_a? String
          return true if value == 'true'
          return false if value == 'false'

          begin
            return Integer(value)
          rescue ArgumentError
            return value
          end

        elsif value.is_a? true.class or value.is_a? false.class
          return value
        elsif value.is_a? Numeric
          return value
        elsif value.is_a? Symbol
          return value.to_s
        elsif value.is_a? Hash
          return self.normalize_hash(value)
        elsif value.is_a? Array
          value_class_list = value.map(&:class).uniq

          return [] unless value.size > 0

          if value_class_list.include? String
            return value.sort
          elsif value_class_list.include? Hash
            value_list = value
          else
            value_list = value
          end

          #return nil if value.size == 0
          results = value_list.map {|v|
            self.normalize_values(v)
          }

          results_class_list = results.map(&:class).uniq
          if results_class_list.include? Hash
            nested_results__value_class_list = results.collect {|i|
              i.collect {|k,v|
                v.class
              }
            }.flatten.uniq

            # If we've got a nestd hash, this sorting will fail
            unless nested_results__value_class_list.include? Hash
              results = results.sort_by{|k|
                k.flatten
              }
            end
          end
          return results
        else
          Puppet.debug("Value class #{value.class} not handled")
        end
      end

    end
  end
end