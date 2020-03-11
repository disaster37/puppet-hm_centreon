require_relative './logger.rb'

module Centreon
    class ServiceGroup
        include Logging
        def initialize()
            @id = nil
            @name = nil
            @descriptiion = nil
            @services = []
        end
        
        def id
           @id 
        end
        
        def name
            @name
        end
        
        def description
            @description
        end
        
        def services
            @services
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
        
        def set_description(value)
            raise("wrong type: string required") unless value.is_a?(String)
            @description = value
            logger.debug("Description: " + value)
        end
        
        def add_service(service)
           raise("wrong type: Centreon::Service required") unless service.is_a?(::Centreon::Service)
            raise("wrong value: service must be valid") unless service.is_valid()
           @services << service 
           logger.debug("Add service: " + service.to_s)
        end
        
        def is_valid()
            !@name.nil? && !@name.empty?
        end
        
        def to_s
            @name
        end
    end
end