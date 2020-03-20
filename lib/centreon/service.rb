require_relative './logger.rb'
require_relative './service_model.rb'
require_relative './macro.rb'
require_relative './host.rb'
require_relative './service_group.rb'

require 'net/http'

module Centreon
    class Service < ServiceModel
        include Logging
        def initialize()
            super()
        end
        
        def set_host(host)
            raise("wrong type: Centreon::Host required") unless host.is_a?(::Centreon::Host)
            raise("wrong value: host must be valid") unless !host.name().nil? && !host.name().empty?
            @host = host
            logger.debug("Host: " + host.to_s)
        end
        
        def is_valid()
            !@name.nil? && !@name.empty? && !@host.nil? && !@host.name().nil? && !@host.name().empty?
        end
        
    end
end