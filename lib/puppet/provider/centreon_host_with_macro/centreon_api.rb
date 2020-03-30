require_relative '../../../puppet_x/centreon/client.rb'

Puppet::Type.type(:centreon_host_with_macro).provide(:centreon_api, :parent => ::PuppetX::Centreon::Client) do

  confine feature: :centreon

  mk_resource_methods
  
  def initialize(value={})
    super(value)
    @property_flush = {}
  end


  def self.prefetch(resources)
    resources.keys.each do |resource_name|
      filters = []
      client(resources[resource_name][:config]).host().fetch(resources[resource_name][:host], false).each do |host|
        hash = host_to_hash(host, resources[resource_name][:macros])
        hash[:name] = resources[resource_name][:name]
        filters << new(hash) unless hash.empty?
      end
      
      if provider = filters.find { |c| c.name == resources[resource_name][:name] }
        resources[resource_name].provider = provider
        Puppet.info("Found resource #{resources[resource_name][:name]}")
      end
    end
  end
  
  # Convert host to hash
  def self.host_to_hash(host, expected_macros)
    return {} if host.nil?
    
    {
      host:  host.name(),
      macros: host.macros().select { |macro|
        is_found = false
        expected_macros.each do |expected_macro|
          if macro.name() == expected_macro["name"]
            is_found = true
            break
          end
        end
        is_found
        }.map{ |macro| 
          {
            "name" => macro.name(),
            "value"=> macro.value(),
            "is_password" => macro.is_password(),
            "description" => macro.description()
          }
        }.flatten.uniq.compact,
      ensure: :present,
    }
  
  end

  def exists?
    Puppet.info("Checking if resource #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Adding macro on host #{host}")
    
    host = Centreon::Host.new()
    host.set_name(resource[:host])
    resource[:macros].each do |hash|
      macro = Centreon::Macro.new()
      macro.set_name(hash["name"])
      macro.set_value(hash["value"])
      macro.set_description(hash["description"]) unless hash["description"].nil?
      macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
      host.add_macro(macro)
    end
    
    client(resource[:config]).host().add_macros(host)
    @property_hash[:ensure] = :present
    
  end

  def destroy
    Puppet.info("Deleting macros on host #{host}")
    
    host = Centreon::Host.new()
    host.set_name(@property_hash[:host])
    resource[:macros].each do |hash|
      macro = Centreon::Macro.new()
      macro.set_name(hash["name"])
      macro.set_value(hash["value"])
      macro.set_description(hash["description"]) unless hash["description"].nil?
      macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
      host.add_macro(macro)
    end
    
    client(resource[:config]).host().delete_macros(host)
    @property_hash[:ensure] = :absent
  end
  
  def flush
    
    if @property_hash[:ensure] != :absent && !@property_flush.empty? && !@property_flush[:macros].nil? && !@property_flush[:macros].empty?
      Puppet.info("Update macros on host #{host}")
      
      puts @property_flush[:macros]
      puts @property_hash[:macros]
      
      macros_to_create = @property_flush[:macros].select { |macro|
        is_found = false
        @property_hash[:macros].each do |existing_macro|
          if macro["name"] == existing_macro["name"] &&  macro["value"] == existing_macro["value"] &&  macro["description"] == existing_macro["description"] && macro["is_password"].to_s == existing_macro["is_password"].to_s
            puts "found"
            is_found = true
            break
          end
        end
        
        !is_found
      }
      
     
      
      if macros_to_create.length() > 0
        host = Centreon::Host.new()
        host.set_name(@property_hash[:host])
        macros_to_create.each do |hash|
          macro = Centreon::Macro.new()
          macro.set_name(hash["name"])
          macro.set_value(hash["value"])
          macro.set_description(hash["description"]) unless hash["description"].nil?
          macro.set_is_password(hash["is_password"]) unless hash["is_password"].nil?
          host.add_macro(macro)
        end
        client(resource[:config]).host().add_macros(host)
      end
      
    end
  end
  
  
  # Getter and setter
  def macros=(value)
    @property_flush[:macros] = value
  end
  
end