require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
  confine feature: :centreon

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).host.fetch(resources[resource_name][:name], false).each do |host|
        hash = host_to_hash(host)

        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| c.name == resources[resource_name][:name] }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found host #{resources[resource_name][:name]}")
      end
    end
  end

  # Convert host to hash
  def self.host_to_hash(host)
    return {} if host.nil?

    {
      name: host.name,
      description: host.description,
      address: host.address,
      enable: host.activated,
      poller: host.poller,
      groups: host.groups.map { |host_group| host_group.name },
      templates: host.templates.map { |host_template| host_template.name },
      comment: host.comment,
      macros: host.macros.map { |macro|
                {
                  'name' => macro.name,
                  'value' => macro.value,
                  'is_password' => macro.password,
                  'description' => macro.description,
                }}.flatten.uniq.compact,
      snmp_community: host.snmp_community,
      snmp_version: host.snmp_version,
      timezone: host.timezone,
      check_command: host.check_command,
      check_command_args: host.check_command_args,
      check_interval: host.check_interval,
      retry_check_interval: host.retry_check_interval,
      max_check_attempts: host.max_check_attempts,
      check_period: host.check_period,
      active_check: host.active_checks_enabled,
      passive_check: host.passive_checks_enabled,
      note_url: host.note_url,
      action_url: host.action_url,
      note: host.note,
      icon_image: host.icon_image,
      ensure: :present,
    }
  end

  def exists?
    Puppet.info("Checking if host #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating host #{name}")

    host = ::Centreon::Host.new
    host.name = resource[:name]
    host.description = resource[:description] unless resource[:description].nil?
    host.activated = resource[:enable]
    host.address = resource[:address]
    host.poller = resource[:poller]
    host.comment = resource[:comment] unless resource[:comment].nil?
    unless resource[:groups].nil?
      resource[:groups].each do |name|
        host_group = Centreon::HostGroup.new
        host_group.name = name
        host.add_group(host_group)
      end
    end
    unless resource[:templates].nil?
      resource[:templates].each do |name|
        host_template = Centreon::HostTemplate.new
        host_template.name = name
        host.add_template(host_template)
      end
    end
    unless resource[:macros].nil?
      resource[:macros].each do |hash|
        macro = Centreon::Macro.new
        macro.name = hash['name']
        macro.value = hash['value']
        macro.description = hash['description'] unless hash['description'].nil?
        macro.password = hash['is_password'] unless hash['is_password'].nil?
        host.add_macro(macro)
      end
    end
    host.snmp_community = resource[:snmp_community] unless resource[:snmp_community].nil?
    host.snmp_version = resource[:snmp_version] unless resource[:snmp_version].nil?
    host.timezone = resource[:timezone] unless resource[:timezone].nil?
    host.check_command = resource[:check_command] unless resource[:check_command].nil?
    host.check_interval = resource[:check_interval] unless resource[:check_interval].nil?
    host.retry_check_interval = resource[:retry_check_interval] unless resource[:retry_check_interval].nil?
    host.max_check_attempts = resource[:max_check_attempts] unless resource[:max_check_attempts].nil?
    host.check_period = resource[:check_period] unless resource[:check_period].nil?
    host.active_checks_enabled = resource[:active_check] unless resource[:active_check].nil?
    host.passive_checks_enabled = resource[:passive_check] unless resource[:passive_check].nil?
    host.note_url = resource[:note_url] unless resource[:note_url].nil?
    host.action_url = resource[:action_url] unless resource[:action_url].nil?
    host.note = resource[:note] unless resource[:note].nil?
    host.icon_image = resource[:icon_image] unless resource[:icon_image].nil?
    unless resource[:check_command_args].nil?
      resource[:check_command_args].each do |value|
        host.add_check_command_arg(value)
      end
    end

    client(resource[:config]).host.add(host)
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting host #{name}")
    client(resource[:config]).host.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty?

    Puppet.info("Update host #{name}")

    host = Centreon::Host.new
    host.name = @property_hash[:name]
    host.description = @property_flush[:description] unless @property_flush[:description].nil?
    host.address = @property_flush[:address] unless @property_flush[:address].nil?
    host.poller = @property_flush[:poller] unless @property_flush[:poller].nil?
    host.comment = @property_flush[:comment] unless @property_flush[:comment].nil?
    host.activated = @property_flush[:enable] unless @property_flush[:enable].nil?
    host.snmp_community = @property_flush[:snmp_community] unless @property_flush[:snmp_community].nil?
    host.snmp_version = @property_flush[:snmp_version] unless @property_flush[:snmp_version].nil?
    host.timezone = @property_flush[:timezone] unless @property_flush[:timezone].nil?
    host.check_command = @property_flush[:check_command] unless @property_flush[:check_command].nil?
    host.check_interval = @property_flush[:check_interval] unless @property_flush[:check_interval].nil?
    host.retry_check_interval = @property_flush[:retry_check_interval] unless @property_flush[:retry_check_interval].nil?
    host.max_check_attempts = @property_flush[:max_check_attempts] unless @property_flush[:max_check_attempts].nil?
    host.check_period = @property_flush[:check_period] unless @property_flush[:check_period].nil?
    host.active_checks_enabled = @property_flush[:active_check] unless @property_flush[:active_check].nil?
    host.passive_checks_enabled = @property_flush[:passive_check] unless @property_flush[:passive_check].nil?
    host.note_url = @property_flush[:note_url] unless @property_flush[:note_url].nil?
    host.action_url = @property_flush[:action_url] unless @property_flush[:action_url].nil?
    host.note = @property_flush[:note] unless @property_flush[:note].nil?
    host.icon_image = @property_flush[:icon_image] unless @property_flush[:icon_image].nil?
    unless @property_flush[:check_command_args].nil?
      @property_flush[:check_command_args].each do |value|
        host.add_check_command_arg(value)
      end
    end

    unless @property_flush[:groups].nil?
      @property_flush[:groups].each do |name|
        host_group = Centreon::HostGroup.new
        host_group.name = name
        host.add_group(host_group)
      end
    end
    unless @property_flush[:templates].nil?
      @property_flush[:templates].each do |name|
        host_template = Centreon::HostTemplate.new
        host_template.name = name
        host.add_template(host_template)
      end
    end
    unless @property_flush[:macros].nil?
      @property_flush[:macros].each do |hash|
        macro = Centreon::Macro.new
        macro.name = hash['name']
        macro.value = hash['value']
        macro.description = hash['description'] unless hash['description'].nil?
        macro.password = hash['is_password'] unless hash['is_password'].nil?
        host.add_macro(macro)
      end
    end

    # Update host
    client(resource[:config]).host.update(host, !@property_flush[:groups].nil?, !@property_flush[:templates].nil?, !@property_flush[:macros].nil?, !@property_flush[:enable].nil?, !@property_flush[:check_command_args].nil?) # rubocop:disable LineLength
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

  def snmp_community=(value)
    @property_flush[:snmp_community] = value
  end

  def snmp_version=(value)
    @property_flush[:snmp_version] = value
  end

  def timezone=(value)
    @property_flush[:timezone] = value
  end

  def check_command=(value)
    @property_flush[:check_command] = value
  end

  def check_command_args=(value)
    @property_flush[:check_command_args] = value
  end

  def check_interval=(value)
    @property_flush[:check_interval] = value
  end

  def retry_check_interval=(value)
    @property_flush[:retry_check_interval] = value
  end

  def max_check_attempts=(value)
    @property_flush[:max_check_attempts] = value
  end

  def check_period=(value)
    @property_flush[:check_period] = value
  end

  def active_check=(value)
    @property_flush[:active_check] = value
  end

  def passive_check=(value)
    @property_flush[:passive_check] = value
  end

  def note_url=(value)
    @property_flush[:note_url] = value
  end

  def action_url=(value)
    @property_flush[:action_url] = value
  end

  def note=(value)
    @property_flush[:note] = value
  end

  def icon_image=(value)
    @property_flush[:icon_image] = value
  end
end
