require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host_group).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
  confine feature: :centreon

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).host_group.fetch(resources[resource_name][:name], false).each do |host_group|
        hash = host_group_to_hash(host_group)
        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| c.name == resources[resource_name][:name] }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found host group #{resources[resource_name][:name]}")
      end
    end
  end

  # Convert host to hash
  def self.host_group_to_hash(host_group)
    return {} if host_group.nil?

    {
      name: host_group.name,
      description: host_group.description,
      comment: host_group.comment,
      note: host_group.note,
      note_url: host_group.note_url,
      action_url: host_group.action_url,
      icon_image: host_group.icon_image,
      enable: host_group.activated,
      ensure: :present,
    }
  end

  def exists?
    Puppet.info("Checking if host group #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating host group #{name}")

    host_group = ::Centreon::HostGroup.new
    host_group.name = resource[:name]
    host_group.activated = resource[:enable] unless resource[:enable].nil?
    host_group.description = resource[:description] unless resource[:description].nil?
    host_group.comment = resource[:comment] unless resource[:comment].nil?
    host_group.note = resource[:note] unless resource[:note].nil?
    host_group.note_url = resource[:note_url] unless resource[:note_url].nil?
    host_group.action_url = resource[:action_url] unless resource[:action_url].nil?
    host_group.icon_image = resource[:icon_image] unless resource[:icon_image].nil?

    # Create host group
    client(resource[:config]).host_group.add(host_group)
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting host group #{name}")
    client(resource[:config]).host_group.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty?
    Puppet.info("Update host group #{name}")

    host_group = Centreon::HostGroup.new
    host_group.name = @property_hash[:name]
    host_group.activated = @property_flush[:enable] unless @property_flush[:enable].nil?
    host_group.description = @property_flush[:description] unless @property_flush[:description].nil?
    host_group.comment = @property_flush[:comment] unless @property_flush[:comment].nil?
    host_group.note = @property_flush[:note] unless @property_flush[:note].nil?
    host_group.note_url = @property_flush[:note_url] unless @property_flush[:note_url].nil?
    host_group.action_url = @property_flush[:action_url] unless @property_flush[:action_url].nil?
    host_group.icon_image = @property_flush[:icon_image] unless @property_flush[:icon_image].nil?

    # Update host group
    client(resource[:config]).host_group.update(host_group, !@property_flush[:enable].nil?)
  end

  # Getter and setter
  def name=(value)
    @property_flush[:name] = value
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def enable=(value)
    @property_flush[:enable] = value
  end

  def comment=(value)
    @property_flush[:comment] = value
  end

  def note=(value)
    @property_flush[:note] = value
  end

  def note_url=(value)
    @property_flush[:note_url] = value
  end

  def action_url=(value)
    @property_flush[:action_url] = value
  end

  def icon_image=(value)
    @property_flush[:icon_image] = value
  end
end
