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
      client(resources[resource_name][:config]).service_template.fetch(resources[resource_name][:name], true).each do |service_template|
        # Don't update unmanaged properties
        service_template.template = resources[resource_name][:template] unless resources[resource_name][:template].nil?
        service_template.note_url = resources[resource_name][:note_url] unless resources[resource_name][:note_url].nil?
        service_template.action_url = resources[resource_name][:action_url] unless resources[resource_name][:action_url].nil?
        service_template.set_comment = resources[resource_name][:comment] unless resources[resource_name][:comment].nil?

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

  def load
    return unless @is_loaded == false

    service_template = Centreon::ServiceTemplate.new
    service_template.set_name(@property_hash[:name])

    # Load extra properties
    client(resource[:config]).service_template.load(service_template)

    @property_hash[:macros] = service_template.macros.map { |macro|
                                {
                                  'name' => macro.name,
                                  'value' => macro.value,
                                  'is_password' => macro.password,
                                  'description' => macro.description,
                                }}.flatten.uniq.compact,

                              @is_loaded = true
  end

  # Convert service template to hash
  def self.service_template_to_hash(service_template)
    return {} if service_template.nil?
    {
      name: service_template.name,
      command: service_template.command,
      command_args: service_template.command_args,
      enable: service_template.activated,
      normal_check_interval: service_template.normal_check_interval,
      retry_check_interval: service_template.retry_check_interval,
      max_check_attempts: service_template.max_check_attempts,
      active_check: service_template.active_check_enabled,
      passive_check: service_template.passive_check_enabled,
      template: service_template.template,
      note_url: service_template.note_url,
      action_url: service_template.action_url,
      comment: service_template.comment,
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
    service_template.activated = resource[:enable]
    service_template.command = resource[:command] unless resource[:command].nil?
    service_template.template = resource[:template] unless resource[:template].nil?
    service_template.normal_check_interval = resource[:normal_check_interval] unless resource[:normal_check_interval].nil?
    service_template.retry_check_interval = resource[:retry_check_interval] unless resource[:retry_check_interval].nil?
    service_template.max_check_attempts = resource[:max_check_attempts] unless resource[:max_check_attempts].nil?
    service_template.active_check_enabled = resource[:active_check] unless resource[:active_check].nil?
    service_template.passive_check_enabled = resource[:passive_check] unless resource[:passive_check].nil?
    service_template.note_url = resource[:note_url] unless resource[:note_url].nil?
    service_template.action_url = resource[:action_url] unless resource[:action_url].nil?
    service_template.set_comment = resource[:comment] unless resource[:comment].nil?

    resource[:command_args].each do |arg|
      service_template.add_command_arg(arg)
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
    client(resource[:config]).service_template.add(service_template, false)

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
    service_template.activate = @property_flush[:enable] unless @property_flush[:enable].nil?
    service_template.command = @property_flush[:command] unless @property_flush[:command].nil?
    service_template.template = @property_flush[:template] unless @property_flush[:template].nil?
    service_template.normal_check_interval = @property_flush[:normal_check_interval] unless @property_flush[:normal_check_interval].nil?
    service_template.retry_check_interval = @property_flush[:retry_check_interval] unless @property_flush[:retry_check_interval].nil?
    service_template.max_check_attempts = @property_flush[:max_check_attempts] unless @property_flush[:max_check_attempts].nil?
    service_template.active_check_enabled = @property_flush[:active_check] unless @property_flush[:active_check].nil?
    service_template.passive_check_enabled = @property_flush[:passive_check] unless @property_flush[:passive_check].nil?
    service_template.note_url = @property_flush[:note_url] unless @property_flush[:note_url].nil?
    service_template.action_url = @property_flush[:action_url] unless @property_flush[:action_url].nil?
    service_template.comment = @property_flush[:comment] unless @property_flush[:comment].nil?

    unless @property_flush[:command_args].nil?
      @property_flush[:command_args].each do |arg|
        service_template.add_command_arg(arg)
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
    client(resource[:config]).service_template.update(service_template, !@property_flush[:macros].nil?, !@property_flush[:enable].nil?, !@property_flush[:command_args].nil?)
  end

  # Getter and setter

  def name=(value)
    @property_flush[:name] = value
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

  def macros
    load
    resource[:macros]
  end
end
