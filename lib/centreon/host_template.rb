require_relative './centreon.rb'
require_relative './logger.rb'
require_relative './host_model.rb'
require_relative './host_group.rb'
require_relative './macro.rb'
require_relative './service_template.rb'

# Host template object
class Centreon::HostTemplate < Centreon::HostModel
  include Logging
  def initialize
    super()
  end

  def add_service(service)
    raise('wrong type: Centreon::ServiceTemplate required') unless service.is_a?(::Centreon::ServiceTemplate)
    raise('wrong value: service must be valid') unless !service.name.nil? && !service.name.empty?
    @services << service
    logger.debug('Add service: ' + service.to_s)
  end

  def valid
    !@name.nil? && !@name.empty?
  end

  def to_s
    @name
  end
end
