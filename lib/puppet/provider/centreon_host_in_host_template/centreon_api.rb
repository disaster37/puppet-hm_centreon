require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host_in_host_template).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
  confine feature: :centreon

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).host.fetch(resources[resource_name][:host], false).each do |host|
        hash = host_to_hash(host, resources[resource_name][:templates])
        hash[:name] = resources[resource_name][:name]
        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| c.name == resources[resource_name][:name] }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found host #{resources[resource_name][:host]}")
      end
    end
  end

  # Convert host to hash
  def self.host_to_hash(host, expected_templates)
    return {} if host.nil?

    {
      host:  host.name,
      templates:  host.templates.select { |host_template| expected_templates.include? host_template.name }.map { |host_template| host_template.name },
      ensure: :present,
    }
  end

  def exists?
    Puppet.info("Checking if host #{host} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Adding templates on host #{host}")

    host = Centreon::Host.new
    host.name = resource[:host]
    resource[:templates].each do |template_name|
      host_template = Centreon::HostTemplate.new
      host_template.name = template_name
      host.add_template(host_template)
    end

    client(resource[:config]).host.add_templates(host)
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting templates on host #{host}")

    host = Centreon::Host.new
    host.name = @property_hash[:host]
    resource[:templates].each do |template_name|
      host_template = Centreon::HostTemplate.new
      host_template.name = template_name
      host.add_template(host_template)
    end

    client(resource[:config]).host.delete_templates(host)
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty? && !@property_flush[:templates].nil? && !@property_flush[:templates].empty?
    Puppet.info("Update templates on host #{host}")

    templates_to_create = @property_flush[:templates] - @property_hash[:templates]

    return if templates_to_create.empty?
    host = Centreon::Host.new
    host.name = @property_hash[:host]
    templates_to_create.each do |template_name|
      host_template = Centreon::HostTemplate.new
      host_template.name = template_name
      host.add_template(host_template)
    end
    client(resource[:config]).host.add_templates(host)
  end

  # Getter and setter
  def templates=(value)
    @property_flush[:templates] = value
  end
end
