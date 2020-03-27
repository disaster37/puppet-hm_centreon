require_relative './logger.rb'


module Centreon
    class HostModel
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
            @address = address
            logger.debug("Address: " + address)
        end
        
        def set_poller(poller)
            raise("wrong type: string required") unless poller.is_a?(String)
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
        
        def to_s
           @name 
        end
        
    end
end