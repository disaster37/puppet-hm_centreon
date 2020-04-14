require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_service).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
  confine feature: :centreon

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
    @is_loaded = false
  end

  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).service.fetch(resources[resource_name][:host], resources[resource_name][:service_name], false).each do |service|

        hash = service_to_hash(service)
        hash[:name] = resources[resource_name][:name]

        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| (c.host == resources[resource_name][:host]) && (c.service_name == resources[resource_name][:service_name]) }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found service #{resources[resource_name][:host]} #{resources[resource_name][:service_name]}")
      end
    end
  end

  # Convert host to hash
  def self.service_to_hash(service)
    return {} if service.nil?
    {
      host: service.host.name,
      service_name: service.name,
      command: service.check_command,
      command_args: service.check_command_args,
      enable: service.activated,
      normal_check_interval: service.normal_check_interval,
      retry_check_interval: service.retry_check_interval,
      max_check_attempts: service.max_check_attempts,
      active_check: service.active_checks_enabled,
      passive_check: service.passive_checks_enabled,
      template: service.template,
      note_url: service.note_url,
      action_url: service.action_url,
      comment: service.comment,
      note: service.note,
      icon_image: service.icon_image,
      is_volatile: service.volatile_enabled,
      check_period: service.check_period,
      groups: service.groups.map { |service_group| service_group.name },
      categories: service.categories,
      service_traps: service.service_traps,
      macros: service.macros.map { |macro|
                {
                  'name' => macro.name,
                  'value' => macro.value,
                  'is_password' => macro.password,
                  'description' => macro.description,
                }}.flatten.uniq.compact,
      ensure: :present,
    }
  end

  def exists?
    Puppet.info("Checking if service #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating service #{name}")

    host = ::Centreon::Host.new
    host.name = resource[:host]
    service = ::Centreon::Service.new
    service.host = host
    service.name = resource[:service_name]
    service.activated = resource[:enable]
    service.check_command = resource[:command] unless resource[:command].nil?
    service.template = resource[:template] unless resource[:template].nil?
    service.normal_check_interval = resource[:normal_check_interval] unless resource[:normal_check_interval].nil?
    service.retry_check_interval = resource[:retry_check_interval] unless resource[:retry_check_interval].nil?
    service.max_check_attempts = resource[:max_check_attempts] unless resource[:max_check_attempts].nil?
    service.active_checks_enabled = resource[:active_check] unless resource[:active_check].nil?
    service.passive_checks_enabled = resource[:passive_check] unless resource[:passive_check].nil?
    service.note_url = resource[:note_url] unless resource[:note_url].nil?
    service.action_url = resource[:action_url] unless resource[:action_url].nil?
    service.comment = resource[:comment] unless resource[:comment].nil?
    service.check_period = resource[:check_period] unless resource[:check_period].nil?
    service.volatile_enabled = resource[:is_volatile] unless resource[:is_volatile].nil?
    service.note = resource[:note] unless resource[:note].nil?
    service.icon_image = resource[:icon_image] unless resource[:icon_image].nil?

    resource[:groups].each do |name|
      service_group = Centreon::ServiceGroup.new
      service_group.name = name
      service.add_group(service_group)
    end

    resource[:command_args].each do |arg|
      service.add_check_command_arg(arg)
    end

    resource[:categories].each do |category|
        service.add_category(category)
    end

    resource[:service_traps].each do |service_trap|
        service.add_service_trap(service_trap)
    end

    unless resource[:macros].nil?
      resource[:macros].each do |hash|
        macro = Centreon::Macro.new
        macro.name = hash['name']
        macro.value = hash['value']
        macro.description = hash['description'] unless hash['description'].nil?
        macro.password = hash['is_password'] unless hash['is_password'].nil?
        service.add_macro(macro)
      end
    end
    client(resource[:config]).service.add(service)
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting service #{name}")
    client(resource[:config]).service.delete(@property_hash[:host], @property_hash[:service_name])
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty?

    Puppet.info("Updating service #{name}")

    host = ::Centreon::Host.new
    host.name = @property_hash[:host]
    service = ::Centreon::Service.new
    service.host = host
    service.name = @property_hash[:service_name]
    service.activated = @property_flush[:enable] unless @property_flush[:enable].nil?
    service.check_command = @property_flush[:command] unless @property_flush[:command].nil?
    service.template = @property_flush[:template] unless @property_flush[:template].nil?
    service.normal_check_interval = @property_flush[:normal_check_interval] unless @property_flush[:normal_check_interval].nil?
    service.retry_check_interval = @property_flush[:retry_check_interval] unless @property_flush[:retry_check_interval].nil?
    service.max_check_attempts = @property_flush[:max_check_attempts] unless @property_flush[:max_check_attempts].nil?
    service.active_checks_enabled = @property_flush[:active_check] unless @property_flush[:active_check].nil?
    service.passive_checks_enabled = @property_flush[:passive_check] unless @property_flush[:passive_check].nil?
    service.note_url = @property_flush[:note_url] unless @property_flush[:note_url].nil?
    service.action_url = @property_flush[:action_url] unless @property_flush[:action_url].nil?
    service.comment = @property_flush[:comment] unless @property_flush[:comment].nil?
    service.check_period = @property_flush[:check_period] unless @property_flush[:check_period].nil?
    service.volatile_enabled = @property_flush[:is_volatile] unless @property_flush[:is_volatile].nil?
    service.note = @property_flush[:note] unless @property_flush[:note].nil?
    service.icon_image = @property_flush[:icon_image] unless @property_flush[:icon_image].nil?

    unless @property_flush[:groups].nil?
      @property_flush[:groups].each do |name|
        service_group = Centreon::ServiceGroup.new
        service_group.name = name
        service.add_group(service_group)
      end
    end
    unless @property_flush[:categories].nil?
      @property_flush[:categories].each do |name|
        service.add_category(name)
      end
    end
    unless @property_flush[:service_traps].nil?
      @property_flush[:service_traps].each do |name|
        service.add_service_trap(name)
      end
    end
    unless @property_flush[:command_args].nil?
      @property_flush[:command_args].each do |arg|
        service.add_check_command_arg(arg)
      end
    end
    unless @property_flush[:macros].nil?
      @property_flush[:macros].each do |hash|
        macro = Centreon::Macro.new
        macro.name = hash['name']
        macro.value = hash['value']
        macro.description = hash['description'] unless hash['description'].nil?
        macro.password = hash['is_password'] unless hash['is_password'].nil?
        service.add_macro(macro)
      end
    end

    # Update service
    client(resource[:config]).service.update(service, !@property_flush[:groups].nil?, !@property_flush[:macros].nil?, !@property_flush[:enable].nil?, !@property_flush[:command_args].nil?, !@property_flush[:categories].nil?, !@property_flush[:service_traps].nil?)
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

  def check_period=(value)
    @property_flush[:check_period] = value
  end

  def is_volatile=(value)
    @property_flush[:is_volatile] = value
  end

  def note=(value)
    @property_flush[:note] = value
  end

  def icon_image=(value)
    @property_flush[:icon_image] = value
  end

  def categories=(value)
    @property_flush[:categories] = value
  end

  def service_traps=(value)
    @property_flush[:service_traps] = value
  end

end
