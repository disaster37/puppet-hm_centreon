require_relative './centreon.rb'
require_relative './logger.rb'

# Host group object
class Centreon::HostGroup
  include Logging

  def initialize
    @id = nil
    @name = nil
    @description = nil
    @comment = nil
    @note = nil
    @note_url = nil
    @action_url = nil
    @icon_image = nil
    @activated = false
  end

  attr_reader :id

  attr_reader :name

  attr_reader :activated

  attr_reader :description

  attr_reader :comment

  attr_reader :note

  attr_reader :note_url

  attr_reader :action_url

  attr_reader :icon_image

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

  def activated=(activated)
    raise('wrong type: boolean required') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
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

  def note=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @note = value
    logger.debug('Note: ' + value)
  end

  def note_url=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @note_url = value
    logger.debug('Note URL: ' + value)
  end

  def action_url=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @action_url = value
    logger.debug('Action URL: ' + value)
  end

  def icon_image=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @icon_image = value
    logger.debug('Icon image: ' + value)
  end

  def valid
    !@name.nil? && !@name.empty?
  end

  def to_s
    @name
  end
end
