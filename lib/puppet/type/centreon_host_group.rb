require 'puppet/property/boolean'

Puppet::Type.newtype(:centreon_host_group) do
  @doc = 'Type representing a host group.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the host group.'
    validate do |value|
      raise 'host group must have a name' if value == ''
      raise 'name should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:description) do
    desc 'The description of the host group.'
    validate do |value|
      raise 'description should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:comment) do
    desc 'The comment of the host group.'
    validate do |value|
      raise 'comment should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:note) do
    desc 'The note of the host group.'
    validate do |value|
      raise 'note should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:note_url) do
    desc 'The note url of the host group.'
    validate do |value|
      raise 'note_url should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:action_url) do
    desc 'The action url of the host group.'
    validate do |value|
      raise 'action_url should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:icon_image) do
    desc 'The icon image of the host group.'
    validate do |value|
      raise 'icon image should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:enable, parent: Puppet::Property::Boolean) do
    desc 'The state of host group'

    defaultto(:true)
    newvalues(:true, :false)
  end

  newproperty(:id)

  newparam(:config) do
    desc 'The Centreon configuration to use'

    defaultto('default')

    validate do |value|
      raise 'host must have a config' if value == ''
      raise 'config should be a String' unless value.is_a?(String)
    end
  end

  autorequire(:centreon) do
    self[:config]
  end
end
