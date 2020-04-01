require 'puppet/property/boolean'
require_relative '../../puppet_x/centreon/macro_parser.rb'

Puppet::Type.newtype(:centreon_service) do
  @doc = 'Type representing a service.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the resource'
  end

  newparam(:service_name, namevar: true) do
    desc 'The name of the service'
    validate do |value|
      raise 'service name must have a name' if value == ''
      raise 'service name should be a String' unless value.is_a?(String)
    end
  end

  newparam(:host, namevar: true) do
    desc 'The host name associated with the service.'
    validate do |value|
      raise 'service must have a host name' if value == ''
      raise 'host should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:command) do
    desc 'The command of the service.'
    validate do |value|
      raise 'command should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:command_args, array_matching: :all) do
    desc 'The command argument of the service.'

    defaultto []

    def insync?(is)
      is.to_set == should.to_set
    end

    validate do |value|
      raise 'templates should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:enable, parent: Puppet::Property::Boolean) do
    desc 'The state of host'

    defaultto(:true)
    newvalues(:true, :false)
  end

  newproperty(:template) do
    desc 'The template of the service.'
    validate do |value|
      raise 'template should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:normal_check_interval) do
    desc 'The normal check interval of the service.'
    validate do |value|
      raise 'normal_check_interval should be a Interger' unless value.is_a?(Integer)
    end
  end

  newproperty(:retry_check_interval) do
    desc 'The retry check interval of the service.'
    validate do |value|
      raise 'retry_check_intervall should be a Interger' unless value.is_a?(Integer)
    end
  end

  newproperty(:max_check_attempts) do
    desc 'The max check attempts of the service.'
    validate do |value|
      raise 'max_check_attempts should be a Interger' unless value.is_a?(Integer)
    end
  end

  newproperty(:active_check) do
    desc 'The active check of the service.'

    defaultto('default')

    validate do |value|
      raise 'active_check should be a true, false or default' unless ['true', 'false', 'default'].include? value
    end
  end

  newproperty(:passive_check) do
    desc 'The passive check of the service.'

    defaultto('default')
    validate do |value|
      raise 'active_check should be a true, false or default' unless ['true', 'false', 'default'].include? value
    end
  end

  newproperty(:note_url) do
    desc 'The note url of the service.'
    validate do |value|
      raise 'note url should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:action_url) do
    desc 'The action url of the service.'
    validate do |value|
      raise 'action_url should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:comment) do
    desc 'The comment of the service.'
    validate do |value|
      raise 'comment should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:groups, array_matching: :all) do
    desc 'The groups of the service.'

    defaultto([])

    def insync?(is)
      is.to_set == should.to_set
    end

    validate do |value|
      raise 'group should be a String' unless value.is_a?(String)
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

  autorequire(:centreon_host) do
    self[:host]
  end

  autorequire(:centreon_service_group) do
    self[:groups]
  end

  autorequire(:centreon_service_template) do
    self[:template]
  end

  def self.title_patterns
    [
      [
        %r{^(([^\|]+)\|([^\|]+))$},
        [
          [:name],
          [:host],
          [:service_name],
        ],
      ],
    ]
  end
end
