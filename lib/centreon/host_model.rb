require_relative './centreon.rb'
require_relative './logger.rb'

# Host model object
class Centreon::HostModel
  include Logging
  def initialize
    @activated = false
    @id = nil
    @description = nil
    @name = nil
    @address = nil
    @comment = nil
    @templates = []
    @macros = []
    @services = []
  end

  attr_reader :id

  attr_reader :name

  attr_reader :activated

  attr_reader :description

  attr_reader :address

  attr_reader :comment

  attr_reader :templates

  attr_reader :macros

  attr_reader :services

  def templates_to_s
    if !@templates.empty?
      @templates.map { |host_template| host_template.name }.join('|')
    else
      ''
    end
  end

  def activated=(activated)
    raise('wrong type: boolean required') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
  end

  def id=(id)
    raise('wrong type: integer required') unless id.is_a?(Integer)
    @id = id
    logger.debug('ID: ' + id.to_s)
  end

  def description=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @description = value
    logger.debug('Description: ' + value)
  end

  def comment=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @comment = value
    logger.debug('Comment: ' + value)
  end

  def name=(name)
    raise('wrong type: string required') unless name.is_a?(String)
    raise("wrong value: name can't be empty") if name.empty?
    @name = name
    logger.debug('Name: ' + name)
  end

  def address=(address)
    raise('wrong type: string required') unless address.is_a?(String)
    @address = address
    logger.debug('Address: ' + address)
  end

  def add_template(host_template)
    raise('wrong type: Centreon::HostTemplate required') unless host_template.is_a?(::Centreon::HostTemplate)
    raise('wrong value: host_template must be valid') unless host_template.valid
    @templates << host_template
    logger.debug('Add host template: ' + host_template.to_s)
  end

  def add_macro(macro)
    raise('wrong type: Centreon::Macro required') unless macro.is_a?(::Centreon::Macro)
    raise('wrong value: macro must be valid') unless macro.valid
    @macros << macro
    logger.debug('Add macro: ' + macro.to_s)
  end

  def to_s
    @name
  end
end
