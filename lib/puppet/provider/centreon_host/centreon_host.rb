require_relative '../../../hm/centreon/client.rb'

Puppet::Type.type(:centreon_host).provide(:centreon_host, :parent => ::Hm::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.instances()
    begin
      if @hosts.nil?
        @hosts = []
        client().host.fetch().each do |host|
          hash = host_to_hash(host)
          @hosts << new(hash) unless hash.empty?
        end
        Puppet.info("All hosts are loaded: " + @hosts.length.to_s)
      end
      @hosts
    rescue Timeout::Error, StandardError => e
      raise   Hm::Centreon::FetchingClapiDataError.new(url, self.resource_type.name.to_s, e.message)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name] # rubocop:disable Lint/AssignmentInCondition
        resource.provider = prov
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
      enable: host.is_activated(),
      ensure: :present,
    }
  
  end
  
  # Load advances properties
  def load_host()
    host = Centreon::Host.new()
    host.set_name(@property_hash[:name])
    client().host.load(host)
    @property_hash[:poller] = host.poller()
    @property_hash[:groups] = host.groups().map{ |host_group| host_group.name()  }
    @property_hash[:templates] = host.templates().map{ |host_template| host_template.name()  }
    @property_hash[:comment] = host.comment()
    @property_hash[:macros] = host.macros().map{ |macro| 
      {
        name: macro.name(),
        value: macro.value()
      }  
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
    host.set_address(resource[:address])
    host.set_poller(resource[:poller])
    host.set_comment(resource[:comment])
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
    
    if @property_hash[:ensure] != :absent
    
      host = Centreon::Host.new()
      host.set_name(@property_hash[:name])
      host.set_description(@property_flush[:description]) unless @property_flush[:description].nil?
      host.set_address(@property_flush[:address]) unless @property_flush[:address].nil?
      host.set_poller(@property_flush[:poller]) unless @property_flush[:poller].nil?
      host.set_comment(@property_flush[:comment]) unless @property_flush[:comment].nil?
      host.set_is_activated(@property_flush[:enable]) unless @property_flush[:enable].nil?
      
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
  
  def poller
    if @property_hash[:poller].nil?
      load_host()
    end
    return @property_hash[:poller]
  end
  
  def poller=(value)
    @property_flush[:poller] = value
  end
  
  def groups
    if @property_hash[:groups].nil?
      load_host()
    end
    
    return @property_hash[:groups]
  end
  
  def groups=(value)
    @property_flush[:groups] = value
  end
  
  def templates
    if @property_hash[:templates].nil?
      load_host()
    end
    
    return @property_hash[:templates]
  end
  
  def templates=(value)
    @property_flush[:templates] = value
  end
  
  def macros
    if @property_hash[:macros].nil?
      load_host()
    end
    
    return @property_hash[:macros]
  end
  
  def macros=(value)
    value.each do |hash|
      hash["name"] = hash["name"].upcase() unless hash["name"].nil?
    end
    @property_flush[:macros] = value
  end
  
  def comment
    if @property_hash[:templates].nil?
      load_host()
    end
    
    return @property_hash[:comment]
  end
  
  def comment=(value)
    @property_flush[:comment] = value
  end
  
end