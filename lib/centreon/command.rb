require_relative './centreon.rb'
require_relative './logger.rb'

# Command object
class Centreon::Command
  include Logging
  def initialize
    @id = nil
    @name = nil
    @type = nil
    @line = nil
    @graph = nil
    @example = nil
    @comment = nil
    @activated = false
    @enable_shell = false
  end

  attr_reader :id

  attr_reader :name

  attr_reader :type

  attr_reader :line

  attr_reader :graph

  attr_reader :example

  attr_reader :comment

  attr_reader :activated

  attr_reader :enable_shell

  def id=(id)
    raise('wrong type: integer required for id') unless id.is_a?(Integer)
    @id = id
    logger.debug('ID: ' + id.to_s)
  end

  def name=(name)
    raise('wrong type: string required for name') unless name.is_a?(String)
    raise("wrong value: name can't be empty") if name.empty?
    @name = name
    logger.debug('Name: ' + name)
  end

  def type=(value)
    raise('wrong type: string required for type') unless value.is_a?(String)
    raise("wrong value: type can't be empty") if value.empty?
    @type = value
    logger.debug('Type: ' + value)
  end

  def line=(value)
    raise('wrong type: string required for line') unless value.is_a?(String)
    raise("wrong value: line can't be empty") if value.empty?
    @line = value
    logger.debug('Line: ' + value)
  end

  def graph=(value)
    raise('wrong type: string required for graph') unless value.is_a?(String)
    @graph = value
    logger.debug('Graph: ' + value)
  end

  def example=(value)
    raise('wrong type: string required for example') unless value.is_a?(String)
    @example = value
    logger.debug('Example: ' + value)
  end

  def comment=(value)
    raise('wrong type: string required for comment') unless value.is_a?(String)
    @comment = value
    logger.debug('Comment: ' + value)
  end

  def activated=(activated)
    raise('wrong type: boolean required for activated') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
  end

  def enable_shell=(value)
    raise('wrong type: boolean required for enable_shell') unless [true, false].include? value
    @enable_shell = value
    logger.debug('enable_shell: ' + value.to_s)
  end

  def valid
    !@name.nil? && !@name.empty?
  end

  def to_s
    @name
  end
end
