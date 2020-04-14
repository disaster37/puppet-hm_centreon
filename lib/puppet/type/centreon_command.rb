require 'puppet/property/boolean'

Puppet::Type.newtype(:centreon_command) do
  @doc = 'Type representing a command.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the command.'
    validate do |value|
      raise 'command must have a name' if value == ''
      raise 'command should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:type) do
    desc 'The type of the command.'
    validate do |value|
      raise 'type should be a String' unless value.is_a?(String)
      raise 'command must have a type' if value == ''
    end
  end

  newproperty(:comment) do
    desc 'The comment of the command.'
    validate do |value|
      raise 'comment should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:line) do
    desc 'The line of the command.'
    validate do |value|
      raise 'line should be a String' unless value.is_a?(String)
      raise 'command must have a line' if value == ''
    end
  end

  newproperty(:graph) do
    desc 'The graph of command.'
    validate do |value|
      raise 'graph should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:example) do
    desc 'The example of the command.'
    validate do |value|
      raise 'example should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:enable, parent: Puppet::Property::Boolean) do
    desc 'The state of command'

    defaultto(:true)
    newvalues(:true, :false)
  end

  newproperty(:enable_shell, parent: Puppet::Property::Boolean) do
    desc 'To enable shell on command'

    defaultto(:false)
    newvalues(:true, :false)
  end

  newparam(:config) do
    desc 'The Centreon configuration to use'

    defaultto('default')

    validate do |value|
      raise 'command must have a config' if value == ''
      raise 'config should be a String' unless value.is_a?(String)
    end
  end

  autorequire(:centreon) do
    self[:config]
  end
end
