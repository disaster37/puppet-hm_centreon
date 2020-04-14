require 'puppet/property/boolean'
require_relative '../../puppet_x/centreon/macro_parser.rb'

Puppet::Type.newtype(:centreon_host) do
  @doc = 'Type representing a host.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the host.'
    validate do |value|
      raise 'host must have a name' if value == ''
      raise 'name should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:description) do
    desc 'The description of the host.'
    validate do |value|
      raise 'description should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:comment) do
    desc 'The comment of the host.'
    validate do |value|
      raise 'comment should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:address) do
    desc 'The IP/DNS of the host.'
    validate do |value|
      raise 'host must have an address' if value == ''
      raise 'address should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:poller) do
    desc 'The poller of the host.'
    validate do |value|
      raise 'host must have an poller' if value == ''
      raise 'poller should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:enable, parent: Puppet::Property::Boolean) do
    desc 'The state of host'

    defaultto(:true)
    newvalues(:true, :false)
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

  newproperty(:groups, array_matching: :all) do
    desc 'The groups of the host.'

    def insync?(is)
      is.to_set == should.to_set
    end

    validate do |value|
      raise 'groups should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:macros, array_matching: :all) do
    desc 'The macros of the host.'

    def insync?(is)
      for_comparison = Marshal.load(Marshal.dump(should))
      parser = PuppetX::Centreon::MacroParser.new(for_comparison)
      to_create = parser.macros_to_create(is)
      to_delete = parser.macros_to_delete(is)
      to_create.empty? && to_delete.empty?
    end

    validate do |value|
      raise 'macros should be a Hash' unless value.is_a?(Hash)
    end

    munge do |value|
      value['name'] = value['name'].upcase if !value.nil? && !value['name'].nil?
      super(value)
    end
  end

  newproperty(:snmp_community) do
    desc 'The SNMP community of the host.'
    validate do |value|
      raise 'SNMP community should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:snmp_version) do
    desc 'The SNMP version of the host.'

    validate do |value|
      raise 'SNMP version should be 1, 2c or 3' unless ['1', '2c', '3'].include? value
    end
  end

  newproperty(:timezone) do
    desc 'The timezone of the host.'
    validate do |value|
      raise 'timezone should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:check_command) do
    desc 'The check_command of the host.'
    validate do |value|
      raise 'Check command should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:check_command_args, array_matching: :all) do
    desc 'The check command argument of the host.'

    defaultto []

    def insync?(is)
      is.to_set == should.to_set
    end

    validate do |value|
      raise 'Argument should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:check_interval) do
    desc 'The check_interval of the host.'
    validate do |value|
      raise 'Check interval should be a Integer' unless value.is_a?(Integer)
    end
  end

  newproperty(:retry_check_interval) do
    desc 'The retry_check_interval of the host.'
    validate do |value|
      raise 'Retry check interval should be a Integer' unless value.is_a?(Integer)
    end
  end

  newproperty(:max_check_attempts) do
    desc 'The max_check_attempts of the host.'
    validate do |value|
      raise 'max_check_attempts should be a Integer' unless value.is_a?(Integer)
    end
  end

  newproperty(:check_period) do
    desc 'The check_period of the host.'
    validate do |value|
      raise 'Check period should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:active_check) do
    desc 'The active check of the host.'

    defaultto('default')

    validate do |value|
      raise 'active_check should be a true, false or default' unless ['true', 'false', 'default'].include? value
    end
  end

  newproperty(:passive_check) do
    desc 'The passive check of the host.'

    defaultto('default')
    validate do |value|
      raise 'active_check should be a true, false or default' unless ['true', 'false', 'default'].include? value
    end
  end

  newproperty(:note_url) do
    desc 'The note url of the host.'
    validate do |value|
      raise 'note url should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:action_url) do
    desc 'The action url of the host.'
    validate do |value|
      raise 'action_url should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:note) do
    desc 'The note of the host.'
    validate do |value|
      raise 'note should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:icon_image) do
    desc 'The icon image of the host.'
    validate do |value|
      raise 'icon image should be a String' unless value.is_a?(String)
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

  autorequire(:centreon_host_group) do
    self[:groups]
  end

  autorequire(:centreon_host_template) do
    self[:templates]
  end

  autorequire(:centreon_command) do
    self[:check_command]
  end
end
