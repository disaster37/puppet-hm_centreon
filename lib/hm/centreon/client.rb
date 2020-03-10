require_relative '../../centreon/api.rb'

module Hm
  module Centreon
    # We purposefully inherit from Exception here due to PUP-3656
    # If we throw something based on StandardError prior to Puppet 4
    # the exception will prevent the prefetch, but the provider will
    # continue to run with incorrect data.
    class FetchingClapiDataError < Exception
      def initialize(url, type, message=nil)
        @message = message
        @url = url
        @type = type
      end

      def to_s
        """Puppet detected a problem with the information returned from Centreon
when looking up #{@type} in #{@url}. The specific error was:
#{@message}
Rather than report on #{@type} resources in an inconsistent state we have exited.
This could be because some other process is modifying AWS at the same time."""
      end
    end

    class Client < Puppet::Provider
      
      
      def self.url()
        ENV['CENTREON_URL'] || url_from_global_configuration
      end
      
      def read_only(*methods)
        methods.each do |method|
          define_method("#{method}=") do |v|
            Puppet.warning "#{method} property is read-only once #{resource.type} created."
          end
        end
      end

      def self.logger()
        log_name = 'puppet-centreon-debug.log'
        if global_configuration and global_configuration['default'] and global_configuration['default']['logger']
          Logger.new(log_name) if global_configuration['default']['logger'] == 'true'
        elsif ENV['PUPPET_CENTREON_DEBUG_LOG'] and not ENV['PUPPET_CENTREON_DEBUG_LOG'].empty?
          Logger.new(log_name)
        else
          nil
        end
      end

      def self.client()
        if !debug()
          ::Logging.logger.level = Logger::INFO
        end
        
        if @client.nil?
          raise("You must provide Centreon URL") unless !url().nil? && !url().empty?
          raise("You must provide Centreon user") unless !user().nil? && !user().empty?
          raise("You must provide Centreon password") unless !password().nil? && !password().empty?
            @client = ::Centreon::Client.new(
                url(),
                user(),
                password()
            )
            @hosts = []
            @services = []
        end
       
        @client
      end
      
      def client()
        self.class.client()
      end
      
      def self.user()
        ENV['CENTREON_USER'] || user_from_global_configuration
      end
    
      def self.password()
        ENV['CENTREON_PASSWORD'] || password_from_global_configuration
      end
      
      def self.debug()
        ENV['CENTREON_DEBUG'] || debug_from_global_configuration || false
      end
      
      def self.global_configuration()
        Puppet.initialize_settings unless Puppet[:confdir]
        path = File.join(Puppet[:confdir], 'puppetlabs_centreon_configuration.ini')
        File.exists?(path) ? ini_parse(File.new(path)) : nil
      end

      def self.url_from_global_configuration()
        global_configuration['default']['url'] if global_configuration
      end
      
      def self.user_from_global_configuration()
        global_configuration['default']['user'] if global_configuration
      end
      
      def self.password_from_global_configuration()
        global_configuration['default']['password'] if global_configuration
      end
      
      def self.debug_from_global_configuration()
        global_configuration['default']['debug'] if global_configuration
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
    end
  end
end