require_relative '../../hm/centreon/macro_parser.rb'

Puppet::Type.newtype(:centreon_host) do
  @doc = 'Type representing a host.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the host.'
    validate do |value|
      fail 'host must have a name' if value == ''
      fail 'name should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:description) do
    desc 'The description of the host.'
    validate do |value|
      fail 'description should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:comment) do
    desc 'The comment of the host.'
    validate do |value|
      fail 'comment should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:address) do
    desc 'The IP/DNS of the host.'
    validate do |value|
      fail 'host must have an address' if value == ''
      fail 'address should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:poller) do
    desc 'The poller of the host.'
    validate do |value|
      fail 'host must have an poller' if value == ''
      fail 'poller should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:enable) do
    desc 'The state of host'
    
    defaultto true
    
    validate do |value|
      fail 'enable should be a String' unless [true, false].include? value
    end
  end
  
  newproperty(:templates, :array_matching => :all) do
    desc 'The templates of the host.'
    
    defaultto []
    
    def insync?(is)
      is.to_set == should.to_set
    end
    
    validate do |value|
      fail 'templates should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:groups, :array_matching => :all) do
    desc 'The groups of the host.'
    
    defaultto []
    
    def insync?(is)
      is.to_set == should.to_set
    end
    
    validate do |value|
      fail 'groups should be a String' unless value.is_a?(String)
    end
  end
  
  newproperty(:macros, :array_matching => :all) do
    desc 'The macros of the host.'
    
    def insync?(is)
      for_comparison = Marshal.load(Marshal.dump(should))
      parser = Hm::Centreon::MacroParser.new(for_comparison)
      to_create = parser.macros_to_create(is)
      to_delete = parser.macros_to_delete(is)
      to_create.empty? && to_delete.empty?
    end
    
    validate do |value|
      fail 'macros should be a Hash' unless value.is_a?(Hash)
    end
  end


  newproperty(:id)

end