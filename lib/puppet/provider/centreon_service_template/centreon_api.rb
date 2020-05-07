require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_service_template).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
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
      client(resources[resource_name][:config]).service_template.fetch(resources[resource_name][:name], false).each do |service_template|
        hash = service_template_to_hash(service_template)

        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| c.name == resources[resource_name][:name] }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found service template #{resources[resource_name][:name]}")
      end
    end
  end

  # Convert service template to hash
  def self.service_template_to_hash(service_template)
    return {} if service_template.nil?
    {
      name: service_template.name,
      description: service_template.description,
      command: service_template.check_command,
      command_args: service_template.check_command_args,
      enable: service_template.activated,
      normal_check_interval: service_template.normal_check_interval,
      retry_check_interval: service_template.retry_check_interval,
      max_check_attempts: service_template.max_check_attempts,
      active_check: service_template.active_checks_enabled,
      passive_check: service_template.passive_checks_enabled,
      template: service_template.template,
      note_url: service_template.note_url,
      action_url: service_template.action_url,
      comment: service_template.comment,
      note: service_template.note,
      icon_image: service_template.icon_image,
      is_volatile: service_template.volatile_enabled,
      check_period: service_template.check_period,
      categories: service_template.categories,
      service_traps: service_template.service_traps,
      host_templates: service_template.host_templates.map { |host_template| host_template.name },
      macros: service_template.macros.map { |macro|
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
    Puppet.info("Checking if service template #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating service template #{name}")

    service_template = ::Centreon::ServiceTemplate.new
    service_template.name = resource[:name]
    service_template.description = resource[:description]
    service_template.activated = resource[:enable]
    service_template.check_command = resource[:command] unless resource[:command].nil?
    service_template.template = resource[:template] unless resource[:template].nil?
    service_template.normal_check_interval = resource[:normal_check_interval] unless resource[:normal_check_interval].nil?
    service_template.retry_check_interval = resource[:retry_check_interval] unless resource[:retry_check_interval].nil?
    service_template.max_check_attempts = resource[:max_check_attempts] unless resource[:max_check_attempts].nil?
    service_template.active_checks_enabled = resource[:active_check] unless resource[:active_check].nil?
    service_template.passive_checks_enabled = resource[:passive_check] unless resource[:passive_check].nil?
    service_template.note_url = resource[:note_url] unless resource[:note_url].nil?
    service_template.action_url = resource[:action_url] unless resource[:action_url].nil?
    service_template.comment = resource[:comment] unless resource[:comment].nil?
    service_template.check_period = resource[:check_period] unless resource[:check_period].nil?
    service_template.volatile_enabled = resource[:is_volatile] unless resource[:is_volatile].nil?
    service_template.note = resource[:note] unless resource[:note].nil?
    service_template.icon_image = resource[:icon_image] unless resource[:icon_image].nil?

    resource[:command_args].each do |arg|
      service_template.add_check_command_arg(arg)
    end

    resource[:categories].each do |category|
      service_template.add_category(category)
    end

    resource[:service_traps].each do |service_trap|
      service_template.add_service_trap(service_trap)
    end

    resource[:host_templates].each do |name|
      host_template = Centreon::HostTemplate.new
      host_template.name = name
      service_template.add_host_template(host_template)
    end

    unless resource[:macros].nil?
      resource[:macros].each do |hash|
        macro = Centreon::Macro.new
        macro.name = hash['name']
        macro.value = hash['value']
        macro.description = hash['description'] unless hash['description'].nil?
        macro.password = hash['is_password'] unless hash['is_password'].nil?
        service_template.add_macro(macro)
      end
    end
    client(resource[:config]).service_template.add(service_template)

    # Take a long time
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting service template #{name}")
    client(resource[:config]).service_template.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty?
    Puppet.info("Updating service template #{name}")

    service_template = ::Centreon::ServiceTemplate.new
    service_template.name = @property_hash[:name]
    service_template.description = @property_flush[:description] unless @property_flush[:description].nil?
    service_template.activate = @property_flush[:enable] unless @property_flush[:enable].nil?
    service_template.check_command = @property_flush[:command] unless @property_flush[:command].nil?
    service_template.template = @property_flush[:template] unless @property_flush[:template].nil?
    service_template.normal_check_interval = @property_flush[:normal_check_interval] unless @property_flush[:normal_check_interval].nil?
    service_template.retry_check_interval = @property_flush[:retry_check_interval] unless @property_flush[:retry_check_interval].nil?
    service_template.max_check_attempts = @property_flush[:max_check_attempts] unless @property_flush[:max_check_attempts].nil?
    service_template.active_checks_enabled = @property_flush[:active_check] unless @property_flush[:active_check].nil?
    service_template.passive_checks_enabled = @property_flush[:passive_check] unless @property_flush[:passive_check].nil?
    service_template.note_url = @property_flush[:note_url] unless @property_flush[:note_url].nil?
    service_template.action_url = @property_flush[:action_url] unless @property_flush[:action_url].nil?
    service_template.comment = @property_flush[:comment] unless @property_flush[:comment].nil?
    service_template.check_period = @property_flush[:check_period] unless @property_flush[:check_period].nil?
    service_template.volatile_enabled = @property_flush[:is_volatile] unless @property_flush[:is_volatile].nil?
    service_template.note = @property_flush[:note] unless @property_flush[:note].nil?
    service_template.icon_image = @property_flush[:icon_image] unless @property_flush[:icon_image].nil?

    unless @property_flush[:command_args].nil?
      @property_flush[:command_args].each do |arg|
        service_template.add_check_command_arg(arg)
      end
    end
    unless @property_flush[:categories].nil?
      @property_flush[:categories].each do |name|
        service_template.add_category(name)
      end
    end
    unless @property_flush[:service_traps].nil?
      @property_flush[:service_traps].each do |name|
        service_template.add_service_trap(name)
      end
    end
    unless @property_flush[:host_templates].nil?
      @property_flush[:host_templates].each do |name|
        host_template = Centreon::HostTemplate.new
        host_template.name = name
        service_template.add_host_template(host_template)
      end
    end
    unless @property_flush[:macros].nil?
      @property_flush[:macros].each do |hash|
        macro = Centreon::Macro.new
        macro.name = hash['name']
        macro.value = hash['value']
        macro.description = hash['description'] unless hash['description'].nil?
        macro.password = hash['is_password'] unless hash['is_password'].nil?
        service_template.add_macro(macro)
      end
    end

    # Update service
    client(resource[:config]).service_template.update(service_template, !@property_flush[:macros].nil?, !@property_flush[:enable].nil?, !@property_flush[:command_args].nil?, !@property_flush[:categories].nil?, !@property_flush[:service_traps].nil?, !@property_flush[:host_templates].nil?) # rubocop:disable LineLength
  end

  # Getter and setter

  def name=(value)
    @property_flush[:name] = value
  end

  def description=(value)
    @property_flush[:description] = value
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

  def macros=(value)
    @property_flush[:macros] = value
  end

  def check_period=(value)
    @property_flush[:check_period] = value
  end

  def is_volatile=(value) # rubocop:disable PredicateName
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

  def host_templates=(value)
    @property_flush[:host_templates] = value
  end
end
