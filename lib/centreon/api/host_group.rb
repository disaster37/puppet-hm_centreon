require 'rest-client'
require 'json'

require_relative '../logger.rb'
require_relative '../host_group.rb'

module Centreon
    module APIClient
        class HostGroup
            include Logging
            
            def initialize(client)
               @client = client 
            end
            
            def fetch(name = nil)
                if name.nil?
                    r = @client.post({
                        "action": "show",
                        "object": "hg"
                    }.to_json)
                else
                    r = @client.post({
                        "action": "show",
                        "object": "hg",
                        "values": name,
                    }.to_json)
                end
    
                host_groups = []
                JSON.parse(r)["result"].each do |data|
                   host_group = Centreon::HostGroup.new()
                   host_group.set_id(data['id'].to_i)
                   host_group.set_name(data['name'])
                   host_group.set_description(data['alias'])
                   host_groups << host_group
                end
                
                return host_groups
            end
            
            def add(group)
                raise("wrong type: Centreon::HostGroup required") unless group.is_a?(::Centreon::HostGroup)
                raise("wrong value: host group must be valid") unless group.is_valid()
                
                @client.post({
                    "action": "add",
                    "object": "hg",
                    "values": sprintf("%s;%s", group.name(), group.description())
                }.to_json)
                
                fetch(group.name()).each do |data|
                   group.set_id(data.id()) 
                end
            end
            
            def delete(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                @client.post({
                    "action": "del",
                    "object": "hg",
                    "values": name
                }.to_json)
            end
            
            def update(group)
                raise("wrong type: Centreon::HostGroup required") unless group.is_a?(::Centreon::HostGroup)
                raise("wrong value: host group must be valid") unless group.is_valid()
                
                set_param(group.name(), "alias", group.description()) unless group.description().nil?
            end
            
            private
            def set_param(name, property, value)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required for property") unless property.is_a?(String)
                raise("wrong value: property must be valid") unless !property.nil? && !property.empty?
                raise("wrong value: value be valid") if value.nil?
                
                r = @client.post({
                    "action": "setparam",
                    "object": "hg",
                    "values": sprintf("%s;%s;%s", name, property, value.to_s)
                }.to_json)
            end
        end
    end
end