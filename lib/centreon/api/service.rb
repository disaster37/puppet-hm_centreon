require 'rest-client'
require 'json'

require_relative '../logger.rb'
require_relative '../host.rb'

module Centreon
    module APIClient
        class Service
            include Logging
            
            def initialize(client)
               @client = client 
            end
        
            
            private
            def set_param(host_name, service_name, name, value)
                raise("wrong type: String required for host_name") unless host_name.is_a?(String)
                raise("wrong value: host_name must be valid") unless !host_name.nil? && !host_name.empty?
                raise("wrong type: String required for service_name") unless service_name.is_a?(String)
                raise("wrong value: service_name must be valid") unless !service_name.nil? && !service_name.empty?
                raise("wrong type: String required for name") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong value: value be valid") if value.nil?
                
                @client.post({
                    "action": "setparam",
                    "object": "service",
                    "values": sprintf("%s;%s;%s;%s", host_name, service_name, name, value.to_s)
                }.to_json)
            end
            
            def get_param(host_name, service_name, name)
                raise("wrong type: String required for host_name") unless host_name.is_a?(String)
                raise("wrong value: host_name must be valid") unless !host_name.nil? && !host_name.empty?
                raise("wrong type: String required for service_name") unless service_name.is_a?(String)
                raise("wrong value: service_name must be valid") unless !service_name.nil? && !service_name.empty?
                raise("wrong type: String required for name") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                r = @client.post({
                    "action": "getparam",
                    "object": "service",
                    "values": sprintf("%s;%s;%s", host_name, service_name, name)
                }.to_json)
                
                return JSON.parse(r)["result"]
            end
            
            def set_host(host_name, service_name, new_host_name)
                raise("wrong type: String required for host_name") unless host_name.is_a?(String)
                raise("wrong value: host_name must be valid") unless !host_name.nil? && !host_name.empty?
                raise("wrong type: String required for service_name") unless service_name.is_a?(String)
                raise("wrong value: service_name must be valid") unless !service_name.nil? && !service_name.empty?
                raise("wrong type: String required for new_host_name") unless new_host_name.is_a?(String)
                raise("wrong value: new_host_name must be valid") unless !new_host_name.nil? && !new_host_name.empty?
                
                @client.post({
                    "action": "sethost",
                    "object": "service",
                    "values": sprintf("%s;%s;%s", host_name, service_name, new_host_name)
                }.to_json)
            end
            
            def get_macros(host_name, service_name, only_direct = true)
                raise("wrong type: String required for host_name") unless host_name.is_a?(String)
                raise("wrong value: host_name must be valid") unless !host_name.nil? && !host_name.empty?
                raise("wrong type: String required for service_name") unless service_name.is_a?(String)
                raise("wrong value: service_name must be valid") unless !service_name.nil? && !service_name.empty?
                
                r = @client.post({
                    "action": "getmacro",
                    "object": "service",
                    "values": sprintf("%s;%s", host_name, service_name)
                }.to_json)
                
    
                macros = []
                JSON.parse(r)["result"].each do |data|
                    macro = ::Centreon::Macro.new()
                    macro.set_name(data["macro name"])
                    macro.set_value(data["macro value"])
                    macro.set_is_password(!data["is_password"].to_i.zero?)
                    macro.set_description(data["description"])
                    macro.set_source(data["source"]) unless data["source"].nil?
                    
                    if only_direct
                        macros << macro if macro.source() == "direct"
                    else
                        macros << macro
                    end
                end
                
                return macros
            end
            
            def set_macro(host_name, service_name, macro)
                raise("wrong type: String required for host_name") unless host_name.is_a?(String)
                raise("wrong value: host_name must be valid") unless !host_name.nil? && !host_name.empty?
                raise("wrong type: String required for service_name") unless service_name.is_a?(String)
                raise("wrong value: service_name must be valid") unless !service_name.nil? && !service_name.empty?
                raise("wrong type: Centreon::Macro required") unless macro.is_a?(::Centreon::Macro)
                raise("wrong value: macro must be valid") unless macro.is_valid()
                
                case macro.description().nil?
                when true
                    description = ""
                when false
                    description = macro.description()
                end
                
                case macro.is_password()
                when true
                    is_password = "1"
                when false
                    is_password = "0"
                end
                
                @client.post({
                    "action": "setmacro",
                    "object": "service",
                    "values": sprintf("%s;%s;%s;%s;%s;%s",host_name, service_name, macro.name().upcase(), macro.value(), is_password, description)
                }.to_json)
            end
            
            def delete_macro(host_name, service_name, name)
                raise("wrong type: String required for host_name") unless host_name.is_a?(String)
                raise("wrong value: host_name must be valid") unless !host_name.nil? && !host_name.empty?
                raise("wrong type: String required for service_name") unless service_name.is_a?(String)
                raise("wrong value: service_name must be valid") unless !service_name.nil? && !service_name.empty?
                raise("wrong type: String required for name") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                r = @client.post({
                    "action": "delmacro",
                    "object": "service",
                    "values": sprintf("%s;%s;%s", host_name, service_name, name)
                }.to_json)
            end
        end
    end
end