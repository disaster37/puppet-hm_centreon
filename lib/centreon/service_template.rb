require_relative './logger.rb'
require_relative './service_model.rb'
require_relative './macro.rb'
require_relative './host.rb'
require_relative './service_group.rb'

require 'net/http'


module Centreon
    class ServiceTemplate < ServiceModel
        include Logging
        def initialize()
            super()
        end
        
        def groups
            raise("Service group is not available in service template")
        end
        
        def add_group(group)
            raise("Service group is not available in service template")
        end
        
        def set_host(host)
            raise("wrong type: Centreon::HostTemplate required") unless host.is_a?(::Centreon::HostTemplate)
            raise("wrong value: host must be valid") unless !host.name().nil? && !host.name().empty?
            @host = host
            logger.debug("Host: " + host.to_s)
        end
        
        
        def is_valid()
            !@name.nil? && !@name.empty?
        end
        
    end
end