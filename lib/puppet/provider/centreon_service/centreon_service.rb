require_relative '../../../hm/centreon/client.rb'

Puppet::Type.type(:centreon_service).provide(:centreon_service, :parent => ::Hm::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
    @is_loaded = false
  end

  def self.prefetch(resources)
    resources.keys.each do |name|
      filters = []
      puts "process '#{resources[name][:name]}': '#{resources[name][:host]}' and '#{resources[name][:service_name]}'"
      client().service.fetch(service_name = resources[name][:service_name], lazzy = true).each do |service|
        
        # Don't update unmanaged properties
        service.set_template(resources[name][:template]) unless resources[name][:template].nil?
        service.set_note_url(resources[name][:note_url]) unless resources[name][:note_url].nil?
        service.set_action_url(resources[name][:action_url]) unless resources[name][:action_url].nil?
        service.set_comment(resources[name][:comment]) unless resources[name][:comment].nil?
        
        # Load service group
        resources[name][:groups].each do |service_group_name|
          client().service.fetch_service_group(service_group_name = service_group_name, services = [service])
        end
        
        hash = service_to_hash(service)
        
        filters << new(hash) unless hash.empty?
      end
      
      filters.each do |c|
        puts "'#{c.host}' == '#{resources[name][:host]}' and '#{c.service_name}' == '#{resources[name][:service_name]}'"
      end
      
      if provider = filters.find { |c| (c.host == resources[name][:host]) && (c.service_name == resources[name][:service_name]) }
        resources[name].provider = provider
        Puppet.info("Found service #{resources[name][:host]} #{resources[name][:service_name]}")
      end
    end
  end
  
  def load()
    if @is_loaded == false
      host = Centreon::Host.new()
      host.set_name(@property_hash[:host])
      service = Centreon::Service.new()
      service.set_host(host)
      service.set_name(@property_hash[:service_name])
      
      # Load extra properties
      client().service.load(service)
      
      @property_hash[:macros] = service.macros().map{ |macro| {
        "name" => macro.name(),
        "value"=> macro.value(),
        "is_password" => macro.is_password(),
        "description" => macro.description()
      }}.flatten.uniq.compact,
      
      @is_loaded = true
    end
  end
  
  # Convert host to hash
  def self.service_to_hash(service)
    return {} if service.nil?
    {
      name: sprintf("%s|%s", service.host().name(), service.name()),
      host: service.host().name(),
      service_name: service.name(),
      command: service.command(),
      command_args: service.command_args(),
      enable: service.is_activated().to_s,
      normal_check_interval: service.normal_check_interval(),
      retry_check_interval: service.retry_check_interval(),
      max_check_attempts: service.max_check_attempts(),
      active_check: service.active_check_enabled(),
      passive_check: service.passive_check_enabled(),
      template: service.template(),
      note_url: service.note_url(),
      action_url: service.action_url(),
      comment: service.comment(),
      groups: service.groups().map{ |service_group| service_group.name()  },
      ensure: :present,
    }
  end


  def exists?
    Puppet.info("Checking if service #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating service #{name}")

    host = ::Centreon::Host.new()
    host.set_name(resource[:host])
    service = ::Centreon::Service.new()
    service.set_host(host)
    service.set_name(resource[:service_name])
    case resource[:enable]
    when :true
      service.set_is_activated(true)
    else
      service.set_is_activated(false)
    end
    service.set_command(resource[:command]) unless resource[:command].nil?
    service.set_template(resource[:template]) unless resource[:template].nil?
    service.set_normal_check_interval(resource[:normal_check_interval]) unless resource[:normal_check_interval].nil?
    service.set_retry_check_interval(resource[:retry_check_interval]) unless resource[:retry_check_interval].nil?
    service.set_max_check_attempts(resource[:max_check_attempts]) unless resource[:max_check_attempts].nil?
    service.set_active_check_enabled(resource[:active_check]) unless resource[:active_check].nil?
    service.set_passive_check_enabled(resource[:passive_check]) unless resource[:passive_check].nil?
    service.set_note_url(resource[:note_url]) unless resource[:note_url].nil?
    service.set_action_url(resource[:action_url]) unless resource[:action_url].nil?
    service.set_comment(resource[:comment]) unless resource[:comment].nil?

    resource[:groups].each do |name|
      service_group = Centreon::ServiceGroup.new()
      service_group.set_name(name)
      service.add_group(service_group)
    end
    
    resource[:command_args].each do |arg|
      service.add_command_arg(arg)
    end
    resource[:macros].each do |hash|
      macro = Centreon::Macro.new()
      macro.set_name(hash["name"])
      macro.set_value(hash["value"])
      macro.set_description(hash["description"]) unless hash["description"].nil?
      macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
      service.add_macro(macro)
    end unless resource[:macros].nil?
    client().service.add(service, retrive_id = false)
    
    # Take a long time
    #@property_hash[:id] = service.id()
    #@property_hash[:host_id] = service.host().id()
    @property_hash[:ensure] = :present
    
    
  end

  def destroy
    Puppet.info("Deleting service #{host} #{name}")
    client().service.delete(@property_hash[:host], @property_hash[:service_name])
    @property_hash[:ensure] = :absent
  end
  
  def flush
    
    if @property_hash[:ensure] != :absent && !@property_flush.empty?
      Puppet.info("Updating service #{host} #{name}")
      
      host = ::Centreon::Host.new()
      host.set_name(@property_hash[:host])
      service = ::Centreon::Service.new()
      service.set_host(host)
      service.set_name(@property_hash[:service_name])
      if !@property_flush[:enable].nil?
        case resource[:enable]
        when :true
          service.set_is_activated(true)
        else
          service.set_is_activated(false)
        end
      end
      service.set_command(@property_flush[:command]) unless @property_flush[:command].nil?
      service.set_template(@property_flush[:template]) unless @property_flush[:template].nil?
      service.set_normal_check_interval(@property_flush[:normal_check_interval]) unless @property_flush[:normal_check_interval].nil?
      service.set_retry_check_interval(@property_flush[:retry_check_interval]) unless @property_flush[:retry_check_interval].nil?
      service.set_max_check_attempts(@property_flush[:max_check_attempts]) unless @property_flush[:max_check_attempts].nil?
      service.set_active_check_enabled(@property_flush[:active_check]) unless @property_flush[:active_check].nil?
      service.set_passive_check_enabled(@property_flush[:passive_check]) unless @property_flush[:passive_check].nil?
      service.set_note_url(@property_flush[:note_url]) unless @property_flush[:note_url].nil?
      service.set_action_url(@property_flush[:action_url]) unless @property_flush[:action_url].nil?
      service.set_comment(@property_flush[:comment]) unless @property_flush[:comment].nil?
      
      @property_flush[:groups].each do |name|
        service_group = Centreon::ServiceGroup.new()
        service_group.set_name(name)
        service.add_group(service_group)
      end unless @property_flush[:groups].nil?
      @property_flush[:command_args].each do |arg|
        service.add_command_arg(arg)
      end unless  @property_flush[:command_args].nil?
      @property_flush[:macros].each do |hash|
        macro = Centreon::Macro.new()
        macro.set_name(hash["name"])
        macro.set_value(hash["value"])
        macro.set_description(hash["description"]) unless hash["description"].nil?
        macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
        service.add_macro(macro)
      end unless @property_flush[:macros].nil?
  
      # Update service
      client().service.update(service, groups = !@property_flush[:groups].nil?, macros = !@property_flush[:macros].nil?, activated = !@property_flush[:enable].nil?, check_command_arguments = !@property_flush[:command_args].nil?)

    end
  end

  # Getter and setter
  def host=(value)
    @property_flush[:host] = value
  end
  
  def service_name=(value)
    @property_flush[:service_name] = value
  end
  
  def command=(value)
    @property_flush[:command] = value
  end
  
  def command_args=(value)
    @property_flush[:command_args] = value
  end
  
  def enable=(value)
    @property_flush[:enable] = value
  end
  
  def normal_check_interval=(value)
    @property_flush[:normal_check_interval] = value
  end
  
  def retry_check_interval=(value)
    @property_flush[:retry_check_interval] = value
  end
  
  def max_check_attempts=(value)
    @property_flush[:max_check_attempts] = value
  end
  
  def active_check=(value)
    @property_flush[:active_check] = value
  end
  
  def passive_check=(value)
    @property_flush[:passive_check] = value
  end
  
  def template=(value)
    @property_flush[:template] = value
  end
  
  def note_url=(value)
    @property_flush[:note_url] = value
  end
  
  def action_url=(value)
    @property_flush[:action_url] = value
  end
  
  def comment=(value)
    @property_flush[:comment] = value
  end
  
  def groups=(value)
    @property_flush[:groups] = value
  end
  
  def macros=(value)
    @property_flush[:macros] = value
  end
  
  def macros
    load()
    resource[:macros]
  end
  
end