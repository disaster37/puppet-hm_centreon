require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host_group).provide(:centreon_api, :parent => ::Hm::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end


  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client().host_group.fetch(resources[resource_name][:name]).each do |host_group|
        hash = host_group_to_hash(host_group)
        
        filters << new(hash) unless hash.empty?
      end
      
      if provider = filters.find { |c| c.name == resources[resource_name][:name] }
        resources[resource_name].provider = provider
        Puppet.info("Found host group #{resources[resource_name][:name]}")
      end
    end
  end
  
  # Convert host to hash
  def self.host_group_to_hash(host_group)
    return {} if host_group.nil?
    
    {
      id: host_group.id(),
      name: host_group.name(),
      description: host_group.description(),
      ensure: :present,
    }
  
  end

  def exists?
    Puppet.info("Checking if host group #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating host group #{name}")
    
    host_group = ::Centreon::HostGroup.new()
    host_group.set_name(resource[:name])
    host_group.set_description(resource[:description]) unless resource[:description].nil?
    
    # Create host group
    client().host_group.add(host_group)
   
    
    @property_hash[:id] = host_group.id()
    @property_hash[:ensure] = :present
    
  end

  def destroy
    Puppet.info("Deleting host group #{name}")
    client().host_group.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end
  
  def flush
    
    
    if @property_hash[:ensure] != :absent && !@property_flush.empty?
      Puppet.info("Update host group #{name}")
    
      host_group = Centreon::HostGroup.new()
      host_group.set_name(@property_hash[:name])
      host_group.set_description(@property_flush[:description]) unless @property_flush[:description].nil?
     
      
      # Update host group
      client().host_group.update(host_group)
    
    end
  end
  
  
  # Getter and setter
  def name=(value)
    @property_flush[:name] = value
  end
  
  def description=(value)
    @property_flush[:description] = value
  end
  
end