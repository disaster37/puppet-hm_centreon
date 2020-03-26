require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host_in_host_group).provide(:centreon_api, :parent => ::Hm::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end


  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client().host().fetch(resources[resource_name][:host], false).each do |host|
        hash = host_to_hash(host, resources[resource_name][:groups])
        hash[:name] = resources[resource_name][:name]
        filters << new(hash) unless hash.empty?
      end
      
      if provider = filters.find { |c| c.name == resources[resource_name][:name] }
        resources[resource_name].provider = provider
        Puppet.info("Found host #{resources[resource_name][:host]}")
      end
    end
  end
  
  # Convert host to hash
  def self.host_to_hash(host, expected_groups)
    return {} if host.nil?
    
    {
      host:  host.name(),
      groups:  host.groups().select { |host_group| expected_groups.include? host_group.name() }.map{ |host_group| host_group.name()  },
      ensure: :present,
    }
  
  end

  def exists?
    Puppet.info("Checking if host #{host} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Adding group on host #{host}")
    
    host = Centreon::Host.new()
    host.set_name(resource[:host])
    resource[:groups].each do |group_name|
      host_group = Centreon::HostGroup.new()
      host_group.set_name(group_name)
      host.add_group(host_group)
    end
    
    client.host.add_groups(host)
    @property_hash[:ensure] = :present
    
  end

  def destroy
    Puppet.info("Deleting groups on host #{host}")
    
    host = Centreon::Host.new()
    host.set_name(@property_hash[:host])
    resource[:groups].each do |group_name|
      host_group = Centreon::HostGroup.new()
      host_group.set_name(group_name)
      host.add_group(host_group)
    end
    
    client.host.delete_groups(host)
    @property_hash[:ensure] = :absent
  end
  
  def flush
    
    if @property_hash[:ensure] != :absent && !@property_flush.empty? && !@property_flush[:groups].nil? && !@property_flush[:groups].empty?
      Puppet.info("Update groups on host #{host}")
      
      
      groups_to_create = @property_flush[:groups] - @property_hash[:groups]
      
      if groups_to_create.length() > 0
        host = Centreon::Host.new()
        host.set_name(@property_hash[:host])
        groups_to_create.each do |group_name|
          host_group = Centreon::HostGroup.new()
          host_group.set_name(group_name)
          host.add_group(host_group)
        end
        client.host.add_groups(host)
      end
      
    end
  end
  
  
  # Getter and setter
  def groups=(value)
    @property_flush[:groups] = value
  end
  
end