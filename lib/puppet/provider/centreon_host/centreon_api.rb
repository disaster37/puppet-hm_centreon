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
    client(resource[:config]).host.update(host, !@property_flush[:groups].nil?, !@property_flush[:templates].nil?, !@property_flush[:macros].nil?, !@property_flush[:enable].nil?)
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
