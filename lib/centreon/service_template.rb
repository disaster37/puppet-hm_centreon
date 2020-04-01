require_relative './centreon.rb'
require_relative './logger.rb'
require_relative './service_model.rb'
require_relative './macro.rb'
require_relative './host.rb'
require_relative './service_group.rb'

require 'net/http'

# Service template object
class Centreon::ServiceTemplate < Centreon::ServiceModel
  include Logging
  def initialize
    super()
    @description = nil
    @host_templates = []
  end

  attr_reader :description

  def description=(value)
    raise('wrong type: String required') unless value.is_a?(String)
    @description = value
  end

  def groups
    raise('Service group is not available in service template')
  end

  def add_group(_group)
    raise('Service group is not available in service template')
  end

  def valid
    !@name.nil? && !@name.empty?
  end
end
