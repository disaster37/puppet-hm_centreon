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
  
end