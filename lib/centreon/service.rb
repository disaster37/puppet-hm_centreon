require_relative './logger.rb'
require_relative './macro.rb'

module Centreon
    class Service
        include Logging
        def initialize()
            @host = nil
            @id = nil
            @name = nil
            @command = nil
            @is_activated = false
            @template = nil
            @normal_check_interval = nil
            @retry_check_interval = nil
            @max_check_attempts = nil
            @active_check_enabled = false
            @passive_check_enabled = false
            @command_args = []
            @macros = []
            @groups = []
        end
        
        def host
           @host 
        end
        
        def id
           @id 
        end
        
        def name
            @name
        end
        
        def command
           @command 
        end
        
        def is_activated
            @is_activated
        end
        
        def template
            @template
        end
        
        def normal_check_interval
           @normal_check_interval 
        end
        
        def retry_check_interval
           @retry_check_interval 
        end
        
        def max_check_attempts
            @max_check_attempts
        end
        
        def active_check_enabled
            @active_check_enabled
        end
        
        def passive_check_enabled
            @passive_check_enabled
        end
        
        def command_args
            @command_args
        end
        
        def macros
            @macros
        end
        
        def groups
            @groups
        end
        
        def set_host(host)
            raise("wrong type: Host::centreon required") unless host.is_a?(::Centreon::Host)
            raise("wrong value: host must be valid") unless !host.name().nil? && !host.name().empty?
            @host = host
            logger.debug("Host: " + name)
        end
        
        def set_id(id)
           raise("wrong type: integer required") unless id.is_a?(Integer)
           @id = id
           logger.debug("ID: " + id.to_s)
        end
        
        def set_name(name)
            raise("wrong type: string required") unless name.is_a?(String)
            raise("wrong value: name can't be empty") if name.empty?
            @name = name
            logger.debug("Name: " + name)
        end
        
        def set_template(name)
            raise("wrong type: string required") unless name.is_a?(String)
            @template = name
            logger.debug("Template: " + name)
        end
        
        def set_is_activated(activated)
            raise("wrong type: boolean required") unless [true, false].include? activated
            @is_activated = activated
            logger.debug("Activated: " + activated.to_s)
        end
        
        def set_normal_check_interval(value)
            raise("wrong type: integer required") unless value.is_a?(Integer)
            @normal_check_interval = value
            logger.debug("Normal check interval: " + value.to_s)
        end
        
        def set_retry_check_interval(value)
            raise("wrong type: integer required") unless value.is_a?(Integer)
            @retry_check_interval = value
            logger.debug("Retry check interval: " + value.to_s)
        end
        
        def set_max_check_attempts(value)
            raise("wrong type: integer required") unless value.is_a?(Integer)
            @max_check_attempts = value
            logger.debug("Max check attemps: " + value.to_s)
        end
        
        def add_macro(macro)
            raise("wrong type: Centreon::Macro required") unless macro.is_a?(::Centreon::Macro)
            raise("wrong value: macro must be valid") unless macro.is_valid()
            @macros << macro
            logger.debug("Add macro: " + macro.to_s)
        end
        
        def is_valid()
            !@name.nil? && !@name.empty?
        end
        
        def to_s
            @name
        end
    end
end