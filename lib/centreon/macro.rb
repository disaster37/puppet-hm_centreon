require_relative './centreon.rb'
require_relative './logger.rb'

# Macro object
class Centreon::Macro
  include Logging
  def initialize
    @name = nil
    @value = nil
    @password = false
    @description = nil
    @source = nil
  end

  attr_reader :name

  attr_reader :value

  attr_reader :password

  attr_reader :description

  attr_reader :source

  def name=(name)
    raise('wrong type: string required') unless name.is_a?(String)
    raise("wrong value: name can't be empty") if name.empty?
    @name = name
    logger.debug('Name: ' + name)
  end

  def value=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @value = value
    logger.debug('Value: ' + value)
  end

  def description=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @description = value
    logger.debug('Description: ' + value)
  end

  def password=(value)
    raise('wrong type: boolean required') unless [true, false].include? value
    @password = value
    logger.debug('Value: ' + value.to_s)
  end

  def source=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @source = value
    logger.debug('Source: ' + value)
  end

  def valid
    !@name.nil? && !@name.empty? && !@value.nil?
  end

  def compare(macro)
    raise('wrong type: Centreon::Macro required') unless macro.is_a?(::Centreon::Macro)
    macro.name == name && macro.value == value && macro.password == password && macro.description == description
  end

  def to_s
    @name
  end
end
