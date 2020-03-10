require_relative './logger.rb'

module Centreon
    class Macro
        include Logging
        def initialize()
            @name = nil
            @value = nil
            @is_password = false
            @description = nil
            @source = nil
        end
        
        def name
            @name
        end
        
        def value
           @value 
        end
        
        def is_password
           @is_password
        end
        
        def description
            @description
        end
        
        def source
            @source
        end
        
        def set_name(name)
            raise("wrong type: string required") unless name.is_a?(String)
            raise("wrong value: name can't be empty") if name.empty?
            @name = name
            logger.debug("Name: " + name)
        end
        
        def set_value(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @value = value
            logger.debug("Value: " + value)
        end
        
        def set_description(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @description = value
            logger.debug("Description: " + value)
        end
        
        def set_is_password(value)
            raise("wrong type: boolean required") unless [true, false].include? value
            @is_password = value
            logger.debug("Value: " + value.to_s)
        end
        
        def set_source(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @source = value
            logger.debug("Source: " + value)
        end
        
        def is_valid()
           return !@name.nil? && !@name.empty? && !@value.nil? 
        end
        
        def compare(macro)
            raise("wrong type: Centreon::Macro required") unless macro.is_a?(::Centreon::Macro)
            return macro.name() == name() && macro.value() == value() && macro.is_password() == is_password() && macro.description() == description()
        end
        
        def to_s
            @name
        end
    end
end