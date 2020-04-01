require_relative './centreon.rb'
require_relative './logger.rb'

# Service model object
class Centreon::ServiceModel
  include Logging
  def initialize
    @id = nil
    @name = nil
    @command = nil
    @activated = false
    @template = nil
    @normal_check_interval = nil
    @retry_check_interval = nil
    @max_check_attempts = nil
    @active_check_enabled = nil
    @passive_check_enabled = nil
    @note_url = nil
    @action_url = nil
    @comment = nil
    @command_args = []
    @macros = []
    @groups = []
  end

  attr_reader :id

  attr_reader :name

  attr_reader :command

  attr_reader :activated

  attr_reader :template

  attr_reader :normal_check_interval

  attr_reader :retry_check_interval

  attr_reader :max_check_attempts

  attr_reader :active_check_enabled

  attr_reader :passive_check_enabled

  attr_reader :command_args

  attr_reader :macros

  attr_reader :groups

  attr_reader :note_url

  attr_reader :action_url

  attr_reader :comment

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

  def command=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @command = value
    logger.debug('Command: ' + value)
  end

  def template=(name)
    raise('wrong type: string required') unless name.is_a?(String)
    @template = name
    logger.debug('Template: ' + name)
  end

  def activated=(activated)
    raise('wrong type: boolean required') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
  end

  def normal_check_interval=(value)
    raise('wrong type: integer required') unless value.is_a?(Integer)
    @normal_check_interval = value
    logger.debug('Normal check interval: ' + value.to_s)
  end

  def retry_check_interval=(value)
    raise('wrong type: integer required') unless value.is_a?(Integer)
    @retry_check_interval = value
    logger.debug('Retry check interval: ' + value.to_s)
  end

  def max_check_attempts=(value)
    raise('wrong type: integer required') unless value.is_a?(Integer)
    @max_check_attempts = value
    logger.debug('Max check attemps: ' + value.to_s)
  end

  def active_check_enabled=(value)
    raise('wrong type: boolean required') unless ['true', 'false', 'default'].include? value
    @active_check_enabled = value
    logger.debug('Active check enabled: ' + value)
  end

  def passive_check_enabled=(value)
    raise('wrong type: boolean required') unless ['true', 'false', 'default'].include? value
    @passive_check_enabled = value
    logger.debug('Passive check enabled: ' + value)
  end

  def note_url=(value)
    raise('wrong type: string required') unless value.is_a?(String)

    unless value.empty?
      uri = URI.parse(value) unless value.empty?
      raise('URL must be valid') unless uri.is_a?(URI::HTTP) && !uri.host.nil?
    end
    @note_url = value
    logger.debug('Note URL: ' + value)
  end

  def action_url=(value)
    raise('wrong type: string required') unless value.is_a?(String)

    unless value.empty?
      uri = URI.parse(value) unless value.empty?
      raise('URL must be valid') unless uri.is_a?(URI::HTTP) && !uri.host.nil?
    end

    @action_url = value
    logger.debug('Action URL: ' + value)
  end

  def comment=(value)
    raise('wrong type: string required') unless value.is_a?(String)
    @comment = value
    logger.debug('Comment: ' + value)
  end

  def add_macro(macro)
    raise('wrong type: Centreon::Macro required') unless macro.is_a?(::Centreon::Macro)
    raise('wrong value: macro must be valid') unless macro.valid
    @macros << macro
    logger.debug('Add macro: ' + macro.to_s)
  end

  def add_group(group)
    raise('wrong type: Centreon::ServiceGroup required') unless group.is_a?(::Centreon::ServiceGroup)
    raise('wrong value: group must be valid') unless group.valid
    @groups << group
    logger.debug('Add group: ' + group.to_s)
  end

  def add_command_arg(arg)
    raise('wrong type: string required') unless arg.is_a?(String)
    raise('wrong value: arg must be valid') if arg.empty?
    @command_args << arg
    logger.debug('Add command arg: ' + arg)
  end

  def to_s
    @name
  end
end
