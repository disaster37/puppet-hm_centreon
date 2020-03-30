Puppet::Type.newtype(:centreon_host_with_macro) do
  @doc = 'Type representing association between host and macros.'

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
  
  newproperty(:macros, :array_matching => :all) do
    desc 'The macros of the host.'
    
    defaultto []
    
    def insync?(is)
      for_comparison = Marshal.load(Marshal.dump(should))
      parser = Hm::Centreon::MacroParser.new(for_comparison)
      to_create = parser.macros_to_create(is)
      to_create.empty?
    end
    
    validate do |value|
      fail 'macros should be a Hash' unless value.is_a?(Hash)
    end
    
    munge do |value|
      value["name"] = value["name"].upcase() if !value.nil? && !value["name"].nil?
      super(value)
    end
  end
  
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
  
  autorequire(:centreon_host) do
    self[:host]
  end

end