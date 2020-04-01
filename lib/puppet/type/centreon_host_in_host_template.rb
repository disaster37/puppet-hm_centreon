Puppet::Type.newtype(:centreon_host_in_host_template) do
  @doc = 'Type representing association between host and templates.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the resource.'
  end

  newparam(:host) do
    desc 'The name of the host'
    validate do |value|
      raise 'resource must have a host' if value == ''
      raise 'host should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:templates, array_matching: :all) do
    desc 'The templates of the host.'

    def insync?(is)
      is.to_set == should.to_set
    end

    validate do |value|
      raise 'templates should be a String' unless value.is_a?(String)
    end
  end

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

  autorequire(:centreon_host_template) do
    self[:templates]
  end

  autorequire(:centreon_host) do
    self[:host]
  end
end
