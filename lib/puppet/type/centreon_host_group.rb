Puppet::Type.newtype(:centreon_host_group) do
  @doc = 'Type representing a host group.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the host group.'
    validate do |value|
      fail 'host group must have a name' if value == ''
      fail 'name should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:description) do
    desc 'The description of the host group.'
    validate do |value|
      fail 'description should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:id)
  
  newparam(:config) do
    desc 'The Centreon configuration to use'
    
    defaultto("default")
    
    validate do |value|
      fail 'host must have a config' if value == ''
      fail 'config should be a String' unless value.is_a?(String)
    end
  end
  
  autorequire(:centreon) do
    self[:config]
  end
  
end