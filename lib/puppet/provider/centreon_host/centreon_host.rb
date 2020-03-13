require_relative '../../../hm/centreon/client.rb'

Puppet::Type.type(:centreon_host).provide(:centreon_host, :parent => ::Hm::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end


  def self.prefetch(resources)
    resources.keys.each do |name|
      filters = []
      client().host.fetch(name = resources[name][:name], lazzy = false).each do |host|
        
        hash = host_to_hash(host)
        
        filters << new(hash) unless hash.empty?
      end
      
      if provider = filters.find { |c| c.name == resources[name][:name] }
        resources[name].provider = provider
        Puppet.info("Found host #{resources[name][:name]}")
      end
    end
  end
  
  # Convert host to hash
  def self.host_to_hash(host)
    return {} if host.nil?
    
    {
      id: host.id(),
      name: host.name(),
      description: host.description(),
      address: host.address(),
      enable: host.is_activated().to_s,
      poller: host.poller(),
      groups: host.groups().map{ |host_group| host_group.name()  },
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
    Puppet.info("Checking if host #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating host #{name}")
    
    host = ::Centreon::Host.new()
    host.set_name(resource[:name])
    host.set_description(resource[:description]) unless resource[:description].nil?
    case resource[:enable]
    when :true
      host.set_is_activated(true)
    else
      host.set_is_activated(false)
    end
    host.set_address(resource[:address])
    host.set_poller(resource[:poller])
    host.set_comment(resource[:comment]) unless resource[:comment].nil?
    resource[:groups].each do |name|
      host_group = Centreon::HostGroup.new()
      host_group.set_name(name)
      host.add_group(host_group)
    end
    resource[:templates].each do |name|
      host_template = Centreon::HostTemplate.new()
      host_template.set_name(name)
      host.add_template(host_template)
    end
    resource[:macros].each do |hash|
      macro = Centreon::Macro.new()
      macro.set_name(hash["name"])
      macro.set_value(hash["value"])
      macro.set_description(hash["description"]) unless hash["description"].nil?
      macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
      host.add_macro(macro)
    end
    client().host.add(host)
    
    @property_hash[:id] = host.id()
    @property_hash[:ensure] = :present
    
  end

  def destroy
    Puppet.info("Deleting host #{name}")
    client().host.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end
  
  def flush
    Puppet.info("Update host #{name}")
    
    if @property_hash[:ensure] != :absent && !@property_flush.empty?
    
      host = Centreon::Host.new()
      host.set_name(@property_hash[:name])
      host.set_description(@property_flush[:description]) unless @property_flush[:description].nil?
      host.set_address(@property_flush[:address]) unless @property_flush[:address].nil?
      host.set_poller(@property_flush[:poller]) unless @property_flush[:poller].nil?
      host.set_comment(@property_flush[:comment]) unless @property_flush[:comment].nil?
      if !@property_flush[:enable].nil?
        case resource[:enable]
        when :true
          host.set_is_activated(true)
        else
          host.set_is_activated(false)
        end
      end
      
      @property_flush[:groups].each do |name|
        host_group = Centreon::HostGroup.new()
        host_group.set_name(name)
        host.add_group(host_group)
      end unless @property_flush[:groups].nil?
      @property_flush[:templates].each do |name|
        host_template = Centreon::HostTemplate.new()
        host_template.set_name(name)
        host.add_template(host_template)
      end unless @property_flush[:templates].nil?
      @property_flush[:macros].each do |hash|
        macro = Centreon::Macro.new()
        macro.set_name(hash["name"])
        macro.set_value(hash["value"])
        macro.set_description(hash["description"]) unless hash["description"].nil?
        macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
        host.add_macro(macro)
      end unless @property_flush[:macros].nil?
      
      # Update host
      client().host.update(host, groups = !@property_flush[:groups].nil?, templates = !@property_flush[:templates].nil?, macros = !@property_flush[:macros].nil?, activated = !@property_flush[:enable].nil?)
    
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
  
  def groups=(value)
    @property_flush[:groups] = value
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