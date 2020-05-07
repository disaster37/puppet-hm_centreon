require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_command).provide(:centreon_api, parent: ::PuppetX::Centreon::Client) do
  confine feature: :centreon

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).command.fetch(resources[resource_name][:name], false).each do |command|
        hash = command_to_hash(command)
        filters << new(hash) unless hash.empty?
      end

      provider = filters.find { |c| c.name == resources[resource_name][:name] }
      if provider
        resources[resource_name].provider = provider
        Puppet.info("Found command #{resources[resource_name][:name]}")
      end
    end
  end

  # Convert host to hash
  def self.command_to_hash(command)
    return {} if command.nil?

    {
      name: command.name,
      type: command.type,
      line: command.line,
      graph: command.graph,
      example: command.example,
      comment: command.comment,
      enable: command.activated,
      enable_shell: command.enable_shell,
      ensure: :present,
    }
  end

  def exists?
    Puppet.info("Checking if command #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating command #{name}")

    command = ::Centreon::Command.new
    command.name = resource[:name]
    command.type = resource[:type]
    command.line = resource[:line]
    command.activated = resource[:enable]
    command.enable_shell = resource[:enable_shell]
    command.graph = resource[:graph] unless resource[:graph].nil?
    command.example = resource[:example] unless resource[:example].nil?
    command.comment = resource[:comment] unless resource[:comment].nil?

    # Create command
    client(resource[:config]).command.add(command)
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting command #{name}")
    client(resource[:config]).command.delete(@property_hash[:name])
    @property_hash[:ensure] = :absent
  end

  def flush
    return unless @property_hash[:ensure] != :absent && !@property_flush.empty?
    Puppet.info("Update command #{name}")

    command = ::Centreon::Command.new
    command.name = @property_hash[:name]
    command.type = @property_flush[:type] unless @property_flush[:type].nil?
    command.line = @property_flush[:line] unless @property_flush[:line].nil?
    command.activated = @property_flush[:enable] unless @property_flush[:enable].nil?
    command.enable_shell = @property_flush[:enable_shell] unless @property_flush[:enable_shell].nil?
    command.graph = @property_flush[:graph] unless @property_flush[:graph].nil?
    command.example = @property_flush[:example] unless @property_flush[:example].nil?
    command.comment = @property_flush[:comment] unless @property_flush[:comment].nil?

    # Update command
    client(resource[:config]).command.update(command, !@property_flush[:enable].nil?, @property_flush[:enable_shell].nil?)
  end

  # Getter and setter
  def name=(value)
    @property_flush[:name] = value
  end

  def type=(value)
    @property_flush[:type] = value
  end

  def line=(value)
    @property_flush[:line] = value
  end

  def comment=(value)
    @property_flush[:comment] = value
  end

  def graph=(value)
    @property_flush[:graph] = value
  end

  def example=(value)
    @property_flush[:example] = value
  end

  def enable=(value)
    @property_flush[:enable] = value
  end

  def enable_shell=(value)
    @property_flush[:enable_shell] = value
  end
end
