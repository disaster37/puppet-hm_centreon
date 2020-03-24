Puppet::Type.newtype(:centreon_host_in_host_template) do
  @doc = 'Type representing association between host and templates.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the resource.'
  end
  
  newparam(:host) do
    desc 'The name of the host'
    validate do |value|
      fail 'resource must have a host' if value == ''
      fail 'host should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:templates, :array_matching => :all) do
    desc 'The templates of the host.'
    
    def insync?(is)
      is.to_set == should.to_set
    end
    
    validate do |value|
      fail 'templates should be a String' unless value.is_a?(String)
    end
  end
  
  autorequire(:centreon_host_template) do
    self[:templates]
  end
  
  autorequire(:centreon_host) do
    self[:host]
  end

end