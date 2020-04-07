require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_service_group).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
  confine feature: :centreon

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).service_group.fetch(resources[resource_name][:name], false).each do |service_group|
        hash = service_group_to_hash(service_group)
        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| c.name == resources[resource_name][:name] }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found service group #{resources[resource_name][:name]}")
      end
    end
  end

  # Convert service group to hash
  def self.service_group_to_hash(service_group)
    return {} if service_group.nil?

    {
      name: service_group.name,
      description: service_group.description,
      comment: service_group.comment,
      enable: service_group.activated,
      ensure: :present,
    }
  end

  def exists?
    Puppet.info("Checking if service group #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating service group #{name}")

    service_group = ::Centreon::ServiceGroup.new
    service_group.name = resource[:name]
    service_group.activated = resource[:enable] unless resource[:enable].nil?
    service_group.description = resource[:description] unless resource[:description].nil?
    service_group.comment = resource[:comment] unless resource[:comment].nil?

    # Create host group
    client(resource[:config]).service_group.add(service_group)
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting service group #{name}")
    client(resource[:config]).service_group.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty?
    Puppet.info("Update service group #{name}")

    service_group = Centreon::ServiceGroup.new
    service_group.name = @property_hash[:name]
    service_group.activated = @property_flush[:enable] unless @property_flush[:enable].nil?
    service_group.description = @property_flush[:description] unless @property_flush[:description].nil?
    service_group.comment = @property_flush[:comment] unless @property_flush[:comment].nil?

    # Update host group
    client(resource[:config]).service_group.update(service_group, !@property_flush[:enable].nil?)
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
end
