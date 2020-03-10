require_relative './logger.rb'
require_relative './host_group.rb'
require_relative './host_template.rb'
require_relative './service_group.rb'
require_relative './service_template.rb'
require_relative './macro.rb'
require_relative './service.rb'

module Centreon
    class Host
        include Logging
        def initialize()
            @is_activated = false
            @id = nil
            @description = nil
            @name = nil
            @address = nil
            @poller = nil
            @comment = nil
            @groups = []
            @templates = []
            @macros = []
            @services = []
        end
        
        
        def id()
           @id 
        end
        
        def name()
            @name
        end
        
        def is_activated()
           @is_activated
        end
        
        def description()
           @description 
        end
        
        def address()
           @address
        end
        
        def poller()
           @poller 
        end
        
        def comment()
           @comment 
        end
        
        def groups()
            @groups
        end
        
        def groups_to_s()
            if @groups.length() > 0
                @groups.map{ |host_group| host_group.name()  }.join("|")
            else
                ""
            end
        end
        
        def templates()
           @templates
        end
        
        def templates_to_s()
            if @templates.length() > 0
                @templates.map{ |host_template| host_template.name()  }.join("|")
            else
                ""
            end
        end
        
        def macros()
           @macros
        end
        
        def services()
            @services
        end
        
        def set_is_activated(activated)
            raise("wrong type: boolean required") unless [true, false].include? activated
            @is_activated = activated
            logger.debug("Activated: " + activated.to_s)
        end
        
        def set_id(id)
           raise("wrong type: integer required") unless id.is_a?(Integer)
           @id = id
           logger.debug("ID: " + id.to_s)
        end
        
        def set_description(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @description = value
            logger.debug("Description: " + value)
        end
        
        def set_comment(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @comment = value
            logger.debug("Comment: " + value)
        end
        
        def set_name(name)
            raise("wrong type: string required") unless name.is_a?(String)
            raise("wrong value: name can't be empty") if name.empty?
            @name = name
            logger.debug("Name: " + name)
        end
        
        def set_address(address)
            raise("wrong type: string required") unless address.is_a?(String)
            raise("wrong value: address can't be empty") if address.empty?
            @address = address
            logger.debug("Address: " + address)
        end
        
        def set_poller(poller)
            raise("wrong type: string required") unless poller.is_a?(String)
            raise("wrong value: poller can't be empty") if poller.empty?
            @poller = poller
            logger.debug("Poller: " + poller)
        end
        
        def add_group(host_group)
            raise("wrong type: Centreon::HostGroup required") unless host_group.is_a?(::Centreon::HostGroup)
            raise("wrong value: host_group must be valid") unless host_group.is_valid()
            @groups << host_group
            logger.debug("Add host group: " + host_group.to_s)
        end
        
        def add_template(host_template)
            raise("wrong type: Centreon::HostTemplate required") unless host_template.is_a?(::Centreon::HostTemplate)
            raise("wrong value: host_template must be valid") unless host_template.is_valid()
            @templates << host_template
            logger.debug("Add host template: " + host_template.to_s)
        end
        
        def add_macro(macro)
            raise("wrong type: Centreon::Macro required") unless macro.is_a?(::Centreon::Macro)
            raise("wrong value: macro must be valid") unless macro.is_valid()
            @macros << macro
            logger.debug("Add macro: " + macro.to_s)
        end
        
        def add_service(service)
            raise("wrong type: Centreon::Service required") unless service.is_a?(::Centreon::Service)
            raise("wrong value: service must be valid") unless service.is_valid()
            @services << service
            logger.debug("Add service: " + service.to_s)
        end
        
        def is_valid()
           !@name.nil? && !@name.empty? && !@address.nil? && !@address.empty? && !@poller.nil? && !@poller.empty?
        end
        
        def is_valid_name()
            !@name.nil? && !@name.empty?
        end
        
        def to_s
           @name 
        end
        
        def to_obj()
           {
               name: name()
           } 
        end
    end
end