require_relative './logger.rb'
require_relative './host_model.rb'
require_relative './host_group.rb'
require_relative './host_template.rb'
require_relative './macro.rb'
require_relative './service.rb'

module Centreon
    class Host < HostModel
        include Logging
        def initialize()
            super()
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
        
        def add_service(service)
            raise("wrong type: Centreon::Service required") unless service.is_a?(::Centreon::Service)
            raise("wrong value: service must be valid") unless !service.name().nil? && !service.name().empty?
            @services << service
            logger.debug("Add service: " + service.to_s)
        end
        
        def is_valid()
           !@name.nil? && !@name.empty? && !@address.nil? && !@address.empty? && !@poller.nil? && !@poller.empty?
        end
        
        def is_valid_name()
            !@name.nil? && !@name.empty?
        end
        
    end
end