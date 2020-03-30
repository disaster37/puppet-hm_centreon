require 'puppet/property/boolean'
require_relative '../../puppet_x/centreon/macro_parser.rb'

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
  
  newproperty(:enable, :parent => Puppet::Property::Boolean) do
    desc 'The state of host'
    
    
    defaultto(:true)
    newvalues(:true, :false)
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
  
  newproperty(:groups, :array_matching => :all) do
    desc 'The groups of the host.'
    
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
      parser = PuppetX::Centreon::MacroParser.new(for_comparison)
      to_create = parser.macros_to_create(is)
      to_delete = parser.macros_to_delete(is)
      to_create.empty? && to_delete.empty?
    end
    
    validate do |value|
      fail 'macros should be a Hash' unless value.is_a?(Hash)
    end
    
    munge do |value|
      value["name"] = value["name"].upcase() if !value.nil? && !value["name"].nil?
      super(value)
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
  
  autorequire(:centreon_host_group) do
    self[:groups]
  end
  
  autorequire(:centreon_host_template) do
    self[:templates]
  end
  
  

end