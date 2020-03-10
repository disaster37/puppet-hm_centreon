require_relative './logger.rb'

module Centreon
    class HostTemplate
        include Logging
        def initialize()
            @id = nil
            @name = nil
        end
        
        def id
           @id 
        end
        
        def name
            @name
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
        
        def is_valid()
            !@name.nil? && !@name.empty?
        end
        
        def to_s
            @name
        end
    end
end