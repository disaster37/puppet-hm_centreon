require 'rest-client'
require 'json'

require_relative '../logger.rb'
require_relative '../host.rb'

module Centreon
    module APIClient
        class Host
            include Logging
            
            def initialize(client)
               @client = client 
            end
        
            # Return all hosts in centreon
            def fetch(name = nil, lazzy = true)
                
                if name.nil?
                    r = @client.post({
                        "action": "show",
                        "object": "host"
                    }.to_json)
                else
                    r = @client.post({
                        "action": "show",
                        "object": "host",
                        "values": name,
                    }.to_json)
                end
    
                hosts = []
                JSON.parse(r)["result"].each do |data|
                
                    host = ::Centreon::Host.new()
                    host.set_id(data['id'].to_i) unless data['id'].nil?
                    host.set_name(data['name']) unless data['name'].nil?
                    
                    # Fix bug
                    if data['alias'].is_a?(Array)
                        data['alias'] = data['alias'].join('|')
                    end
                    
                    host.set_description(data['alias']) unless data['alias'].nil?
                    host.set_address(data['address']) unless data['address'].nil?
                    host.set_is_activated(!data['activate'].to_i.zero?) unless data['activate'].nil?
                   
                    # Load all properties if lazzy is false
                    if !lazzy
                        load(host)
                    end
                       
                    
                    hosts << host
                end
                
                hosts
            end
            
            # Load additional data for given host
            def load(host)
                raise("wrong type: Centreon::Host required") unless host.is_a?(::Centreon::Host)
                raise("wrong value: host must be valid") unless !host.name().nil? && !host.name().empty?
                
                # Load host_templates
                get_templates(host.name()).each do |host_template|
                    host.add_template(host_template)
                end
                
                # Load host groups
                get_groups(host.name()).each do |host_group|
                    host.add_group(host_group)
                end
                
                # Load macros
                get_macros(host.name()).each do |macro|
                   host.add_macro(macro)
                end
                
                # Load poller
                get_poller(host.name()).each do |data|
                   host.set_poller(data["name"]) 
                end
                
                # Load extra params
                # BUG centreon: the field comment can't be call from API, only clapi
                #get_param(host.name(), "comment").each do |data|
                #    host.set_comment(data["comment"]) unless data["comment"].nil?
                #end
                 
            end
            
            
           
            # Get one host from monitoring
            def get(name, lazzy = true)
                
                # Search if host exist
                hosts = fetch(name = name, lazzy = lazzy)
                
                if hosts.length() > 0
                   return hosts[0] 
                end
                
                return nil
            end
            
            # Create new host on monitoring
            def add(host)
                raise("wrong type: Centreon::Host required") unless host.is_a?(::Centreon::Host)
                raise("wrong value: host must be valid") unless host.is_valid()
                @client.post({
                    "action": "add",
                    "object": "host",
                    "values": sprintf("%s;%s;%s;%s;%s;%s", host.name(), host.description(), host.address(), host.templates_to_s(), host.poller(), host.groups_to_s())
                }.to_json)
                
                # Set extra parameters
                set_param(host.name(), "comment", host.comment()) unless host.comment().nil?
                
                # Disable it if needed
                disable(host.name()) unless host.is_activated()
                
                # Set macros
                host.macros().each do |macro|
                   set_macro(host.name(), macro) 
                end
                
                # Apply template if needed
                apply_template(host.name()) unless host.templates().empty?
                
                # Get and set id
                host_tmp = get(host.name(), true)
                host.set_id(host_tmp.id())
            end
            
            def update(host, groups = true, templates = true, macros = true, activated = true)
                raise("wrong type: Centreon::Host required") unless host.is_a?(::Centreon::Host)
                raise("wrong value: host must be valid") unless host.is_valid_name()
                
                set_param(host.name(), "alias", host.description()) unless host.description().nil?
                set_param(host.name(), "address", host.address()) unless host.address().nil?
                set_param(host.name(), "comment", host.comment()) unless host.comment().nil?
                set_poller(host.name(), host.poller()) unless host.poller().nil?
                if activated
                    enable(host.name()) if host.is_activated()
                    disable(host.name()) unless host.is_activated()
                end
                
                
                if groups
                    # Set groups if needed or remove all groups
                    if host.groups().empty?
                        host_tmp = Centreon::Host.new()
                        host_tmp.set_name(host.name())
                        get_groups(host.name()).each do |host_group|
                           host_tmp.add_group(host_group) 
                        end
                        delete_groups(host_tmp)
                    else
                        set_groups(host.name(), host.groups_to_s())
                    end
                end
                
                if templates
                    # Set templates if needed or remove all templates
                    if host.templates().empty?
                        host_tmp = Centreon::Host.new()
                        host_tmp.set_name(host.name())
                        get_templates(host.name()).each do |host_template|
                           host_tmp.add_template(host_template) 
                        end
                        delete_templates(host_tmp)
                    else
                        set_templates(host.name(), host.templates_to_s()) if templates
                    end
                    
                    apply_template(host.name())
                end
               
                
                if macros
                    current_macros = get_macros(host.name())
                    host.macros().each do |macro|
                        isAlreadyExist = false
                        current_macros.each do |current_macro|
                            if current_macro.name() == macro.name()
                                if !macro.compare(current_macro)
                                    set_macro(host.name(), macro)
                                    break
                                end
                                isAlreadyExist = true
                                current_macros.delete(current_macro)
                                break
                            end
                        end
                        
                        if !isAlreadyExist
                            set_macro(host.name(), macro)
                        end
                    end
                    
                    # Remove old macros
                    current_macros.each do |current_macro|
                        delete_macro(host.name(), current_macro.name())
                    end
                end
            end
            
            def delete(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                r = @client.post({
                    "action": "del",
                    "object": "host",
                    "values": name,
                }.to_json)
            end
            
            
            def add_templates(host)
                raise("wrong type: Centreon:Host required") unless host.is_a?(Centreon::Host)
                raise("wrong value: host must be valid") unless !host.name().nil? && !host.name.empty?
                raise("wrong value: templates can't be empty") if host.templates().empty?
                
                
                 r = @client.post({
                    "action": "addtemplate",
                    "object": "host",
                    "values": sprintf("%s;%s", host.name, host.templates_to_s()),
                }.to_json)
            end
            
            def delete_templates(host)
                raise("wrong type: Centreon:Host required") unless host.is_a?(Centreon::Host)
                raise("wrong value: host must be valid") unless !host.name().nil? && !host.name.empty?
                raise("wrong value: templates can't be empty") if host.templates().empty?
                
                
                 r = @client.post({
                    "action": "deltemplate",
                    "object": "host",
                    "values": sprintf("%s;%s", host.name, host.templates_to_s()),
                }.to_json)
            end
            
            def add_groups(host)
                raise("wrong type: Centreon:Host required") unless host.is_a?(Centreon::Host)
                raise("wrong value: host must be valid") unless !host.name().nil? && !host.name.empty?
                raise("wrong value: groups can't be empty") if host.groups().empty?
                
                
                 r = @client.post({
                    "action": "addhostgroup",
                    "object": "host",
                    "values": sprintf("%s;%s", host.name, host.groups_to_s()),
                }.to_json)
            end
            
            def delete_groups(host)
                raise("wrong type: Centreon:Host required") unless host.is_a?(Centreon::Host)
                raise("wrong value: host must be valid") unless !host.name().nil? && !host.name.empty?
                raise("wrong value: groups can't be empty") if host.groups().empty?
                
                
                 r = @client.post({
                    "action": "delhostgroup",
                    "object": "host",
                    "values": sprintf("%s;%s", host.name, host.groups_to_s()),
                }.to_json)
            end
            
            
            private
            def get_param(name, property)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required") unless property.is_a?(String)
                raise("wrong value: property must be valid") unless !property.nil? && !property.empty?
                r = @client.post({
                    "action": "getparam",
                    "object": "host",
                    "values": sprintf("%s;%s", name, property),
                }.to_json)
    
                JSON.parse(r)["result"]
            end
            
            # Get all host template on given host name
            def get_templates(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                r = @client.post({
                    "action": "gettemplate",
                    "object": "host",
                    "values": name
                }.to_json)
    
                templates = []
                JSON.parse(r)["result"].each do |data|
                    host_template = ::Centreon::HostTemplate.new()
                    host_template.set_id(data["id"].to_i)
                    host_template.set_name(data["name"])
                    templates << host_template
                end
                
                return templates
            end
        
            # Get all host group on given host name
            def get_groups(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                r = @client.post({
                    "action": "gethostgroup",
                    "object": "host",
                    "values": name
                }.to_json)
    
                groups = []
                JSON.parse(r)["result"].each do |data|
                    host_group = ::Centreon::HostGroup.new()
                    host_group.set_id(data["id"].to_i)
                    host_group.set_name(data["name"])
                    groups << host_group
                end
                
                return groups
            end
        
            # Get all macro on given host name
            def get_macros(name, only_direct = true)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                r = @client.post({
                    "action": "getmacro",
                    "object": "host",
                    "values": name
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
            
            def delete_macro(name, macro_name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required") unless macro_name.is_a?(String)
                raise("wrong value: nmacro_name must be valid") unless !macro_name.nil? && !macro_name.empty?
                @client.post({
                    "action": "delmacro",
                    "object": "host",
                    "values": sprintf("%s;%s", name, macro_name)
                }.to_json)
            end
        
            def get_poller(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                r = @client.post({
                    "action": "showinstance",
                    "object": "host",
                    "values": name
                }.to_json)
                
                JSON.parse(r)["result"]
            end
            
            # Modify list of host param
            def set_param(name, property, value)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required for property") unless property.is_a?(String)
                raise("wrong value: property must be valid") unless !property.nil? && !property.empty?
                raise("wrong value: value be valid") if value.nil?
                
                r = @client.post({
                    "action": "setparam",
                    "object": "host",
                    "values": sprintf("%s;%s;%s", name, property, value.to_s)
                }.to_json)
            end
            
            # Modify poller
            def set_poller(name, poller)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required") unless poller.is_a?(String)
                raise("wrong value: poller must be valid") unless !poller.nil? && !poller.empty?
                
                r = @client.post({
                    "action": "setinstance",
                    "object": "host",
                    "values": sprintf("%s;%s", name, poller)
                }.to_json)
            end
            
            # Modify templates
            def set_templates(name, templates)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required") unless templates.is_a?(String)
                raise("wrong value: templates must be valid") unless !templates.nil? && !templates.empty?

                r = @client.post({
                    "action": "settemplate",
                    "object": "host",
                    "values": sprintf("%s;%s", name, templates)
                }.to_json)
            end
            
            # Modify groups
            def set_groups(name, groups)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: String required") unless groups.is_a?(String)
                raise("wrong value: groups must be valid") unless !groups.nil? && !groups.empty?
                
                r = @client.post({
                    "action": "sethostgroup",
                    "object": "host",
                    "values": sprintf("%s;%s", name, groups)
                }.to_json)
            end
            
            # Modify macros
            def set_macro(name, macro)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                raise("wrong type: Centreon::Macro required") unless macro.is_a?(Centreon::Macro)
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
                
                r = @client.post({
                    "action": "setmacro",
                    "object": "host",
                    "values": sprintf("%s;%s;%s;%s;%s", name, macro.name().upcase(), macro.value(), is_password, description)
                }.to_json)
            end
            
            # Apply host templates
            def apply_template(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                r = @client.post({
                    "action": "applytpl",
                    "object": "host",
                    "values": name
                }.to_json)
            end
            
            def disable(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                r = @client.post({
                    "action": "disable",
                    "object": "host",
                    "values": name
                }.to_json)
            end
            
            def enable(name)
                raise("wrong type: String required") unless name.is_a?(String)
                raise("wrong value: name must be valid") unless !name.nil? && !name.empty?
                
                r = @client.post({
                    "action": "enable",
                    "object": "host",
                    "values": name
                }.to_json)
            end
        end
    end
end