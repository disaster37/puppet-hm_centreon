require 'puppet/property/boolean'

Puppet::Type.newtype(:centreon) do
  @doc = 'Type representing how to connect on centreon'


  newparam(:name, namevar: true) do
    desc 'The name of the resource'
  end
  
  newparam(:url) do
    desc 'Centreon API URL'
    validate do |value|
      fail 'url should be a String' unless value.is_a?(String)
    end
  end
  
  newparam(:username) do
    desc 'Centreon API username'
    validate do |value|
      fail 'username should be a String' unless value.is_a?(String)
    end
  end
  
  newparam(:password) do
    desc 'Centreon API password'
    
    validate do |value|
      fail 'password should be a String' unless value.is_a?(String)
    end
  end
  
  newparam(:debug, :parent => Puppet::Property::Boolean) do
    desc 'Debug mode'
    
    newvalues(:true, :false)
    defaultto(:false)
  end
  
  
  # Inject credential in all centreon resources
  def generate
    centreon_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/centreon_*/centreon_api.rb')].each do |file|
      type = File.basename(File.dirname(file))
      centreon_types << type.to_sym
    end
    centreon_types.each do |type|
      provider_class = Puppet::Type.type(type).provider(:centreon_api)
      provider_class.configs = {} unless provider_class.configs.is_a?(Hash)
      provider_class.configs[self[:name]] = {
        'url'      => self[:url],
        'username' => self[:username],
        'password' => self[:password],
        'debug'    => self[:debug]
      }
    end
    []
  end

end