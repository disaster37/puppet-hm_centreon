require_relative './centreon.rb'
require_relative './logger.rb'

# Service group object
class Centreon::ServiceGroup
  include Logging
  def initialize
    @id = nil
    @name = nil
    @descriptiion = nil
    @comment = nil
    @activated = false
    @services = []
  end

  attr_reader :id

  attr_reader :name

  attr_reader :description

  attr_reader :services
  
  attr_reader :comment
  
  attr_reader :activated

  def id=(id)
    raise('wrong type: integer required') unless id.is_a?(Integer)
    @id = id
    logger.debug('ID: ' + id.to_s)
  end

  def name=(name)
    raise('wrong type: string required') unless name.is_a?(String)
    raise("wrong value: name can't be empty") if name.empty?
    @name = name
    logger.debug('Name: ' + name)
  end

  def description=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @description = value
    logger.debug('Description: ' + value)
  end

  def add_service(service)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless service.valid
    @services << service
    logger.debug('Add service: ' + service.to_s)
  end
  
  def comment=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @comment = value
    logger.debug('Comment: ' + value)
  end
  
  def activated=(activated)
    raise('wrong type: boolean required') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
  end

  def valid
    !@name.nil? && !@name.empty?
  end

  def to_s
    @name
  end
end
