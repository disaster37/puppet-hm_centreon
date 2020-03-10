require_relative './logger.rb'
require_relative './macro.rb'
require_relative './host.rb'
require_relative './service_group.rb'

require 'net/http'

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
            @active_check_enabled = nil
            @passive_check_enabled = nil
            @url = nil
            @action_url = nil
            @comment = nil
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
        
        def url
            @url
        end
        
        def action_url
            @action_url
        end
        
        def comment
            @comment
        end
        
        def set_host(host)
            raise("wrong type: Host::centreon required") unless host.is_a?(::Centreon::Host)
            raise("wrong value: host must be valid") unless !host.name().nil? && !host.name().empty?
            @host = host
            logger.debug("Host: " + host.to_s)
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
        
        def set_command(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @command = value
            logger.debug("Command: " + value)
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
        
        def set_active_check_enabled(value)
            raise("wrong type: boolean required") unless ["true", "false", "default"].include? value
            @active_check_enabled = value
            logger.debug("Active check enabled: " + value)
        end
        
        def set_passive_check_enabled(value)
            raise("wrong type: boolean required") unless ["true", "false", "default"].include? value
            @passive_check_enabled = value
            logger.debug("Passive check enabled: " + value)
        end
        
        def set_url(value)
            raise("wrong type: string required") unless value.is_a?(String)
            
            if !value.empty?
                uri = URI.parse(value) unless value.empty?
                raise("URL must be valid") unless uri.is_a?(URI::HTTP) && !uri.host.nil?
            end
            @url = value
            logger.debug("URL: " + value)
        end
        
        def set_action_url(value)
            raise("wrong type: string required") unless value.is_a?(String)
            
            if !value.empty?
                uri = URI.parse(value) unless value.empty?
                raise("URL must be valid") unless uri.is_a?(URI::HTTP) && !uri.host.nil?
            end
            
            @action_url = value
            logger.debug("Action URL: " + value)
        end
        
        def set_comment(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @comment = value
            logger.debug("Comment: " + value)
        end
        
        def add_macro(macro)
            raise("wrong type: Centreon::Macro required") unless macro.is_a?(::Centreon::Macro)
            raise("wrong value: macro must be valid") unless macro.is_valid()
            @macros << macro
            logger.debug("Add macro: " + macro.to_s)
        end
        
        def add_group(group)
            raise("wrong type: Centreon::ServiceGroup required") unless group.is_a?(::Centreon::ServiceGroup)
            raise("wrong value: group must be valid") unless group.is_valid()
            @groups << group
            logger.debug("Add group: " + group.to_s)
        end
        
        def add_command_arg(arg)
            raise("wrong type: string required") unless arg.is_a?(String)
            raise("wrong value: arg must be valid") if arg.empty?
            @command_args << arg
            logger.debug("Add command arg: " + arg)
        end
        
        def is_valid()
            !@name.nil? && !@name.empty? && !@host.nil? && !@host.name().nil? && !@host.name().empty?
        end
        
        def to_s
            @name
        end
    end
end