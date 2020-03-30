require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host_template).provide(:centreon_api, :parent => ::PuppetX::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end


  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).host_template().fetch(resources[resource_name][:name], false).each do |host|
        
        hash = host_template_to_hash(host)
        
        filters << new(hash) unless hash.empty?
      end
      
      if provider = filters.find { |c| c.name == resources[resource_name][:name] }
        resources[resource_name].provider = provider
        Puppet.info("Found host #{resources[resource_name][:name]}")
      end
    end
  end
  
  # Convert host template to hash
  def self.host_template_to_hash(host)
    return {} if host.nil?
    
    {
      id: host.id(),
      name: host.name(),
      description: host.description(),
      address: host.address(),
      enable: host.is_activated(),
      poller: host.poller(),
      templates: host.templates().map{ |host_template| host_template.name()  },
      comment: host.comment(),
      macros: host.macros().map{ |macro| {
        "name" => macro.name(),
        "value"=> macro.value(),
        "is_password" => macro.is_password(),
        "description" => macro.description()
      }}.flatten.uniq.compact,
      ensure: :present,
    }
  
  end

  def exists?
    Puppet.info("Checking if host template #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating host template #{name}")
    
    host_template = ::Centreon::HostTemplate.new()
    host_template.set_name(resource[:name])
    host_template.set_description(resource[:description]) unless resource[:description].nil?
    host_template.set_is_activated(resource[:enable])
    host_template.set_address(resource[:address]) unless resource[:address].nil?
    host_template.set_poller(resource[:poller]) unless resource[:poller].nil?
    host_template.set_comment(resource[:comment]) unless resource[:comment].nil?
    resource[:templates].each do |name|
      ht = Centreon::HostTemplate.new()
      ht.set_name(name)
      host_template.add_template(ht)
    end unless resource[:templates].nil?
    resource[:macros].each do |hash|
      macro = Centreon::Macro.new()
      macro.set_name(hash["name"])
      macro.set_value(hash["value"])
      macro.set_description(hash["description"]) unless hash["description"].nil?
      macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
      host_template.add_macro(macro)
    end unless resource[:macros].nil?
    client(resource[:config]).host_template().add(host_template)
    
    @property_hash[:id] = host_template.id()
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting host template #{name}")
    client(resource[:config]).host_template().delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end
  
  def flush
    
    if @property_hash[:ensure] != :absent && !@property_flush.empty?
      Puppet.info("Update host template #{name}")
    
      host_template = Centreon::HostTemplate.new()
      host_template.set_name(@property_hash[:name])
      host_template.set_description(@property_flush[:description]) unless @property_flush[:description].nil?
      host_template.set_address(@property_flush[:address]) unless @property_flush[:address].nil?
      host_template.set_poller(@property_flush[:poller]) unless @property_flush[:poller].nil?
      host_template.set_comment(@property_flush[:comment]) unless @property_flush[:comment].nil?
      host_template.set_is_activated(@property_flush[:enable]) unless @property_flush[:enable].nil?
      
      @property_flush[:templates].each do |name|
        ht = Centreon::HostTemplate.new()
        ht.set_name(name)
        host_template.add_template(ht)
      end unless @property_flush[:templates].nil?
      @property_flush[:macros].each do |hash|
        macro = Centreon::Macro.new()
        macro.set_name(hash["name"])
        macro.set_value(hash["value"])
        macro.set_description(hash["description"]) unless hash["description"].nil?
        macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
        host_template.add_macro(macro)
      end unless @property_flush[:macros].nil?
      
      
      # Update host
      client(resource[:config]).host_template().update(host_template, !@property_flush[:templates].nil?, !@property_flush[:macros].nil?, !@property_flush[:enable].nil?)
    end
  end
  
  
  # Getter and setter
  def name=(value)
    @property_flush[:name] = value
  end
  
  def description=(value)
    @property_flush[:description] = value
  end
  
  def address=(value)
    @property_flush[:address] = value
  end
  
  def enable=(value)
    @property_flush[:enable] = value
  end
  
  
  def poller=(value)
    @property_flush[:poller] = value
  end
  
  def templates=(value)
    @property_flush[:templates] = value
  end
  
  def macros=(value)
    @property_flush[:macros] = value
  end
  
  def comment=(value)
    @property_flush[:comment] = value
  end
  
end