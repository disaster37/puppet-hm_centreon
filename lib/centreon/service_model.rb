require_relative './centreon.rb'
require_relative './logger.rb'

# Service model object
class Centreon::ServiceModel
  include Logging
  def initialize
    @id = nil
    @name = nil
    @check_command = nil
    @activated = false
    @template = nil
    @normal_check_interval = nil
    @retry_check_interval = nil
    @max_check_attempts = nil
    @active_checks_enabled = nil
    @passive_checks_enabled = nil
    @check_command_args = []
    @macros = []
    @service_traps = []
    @categories = []
    @check_period = nil
    @volatile_enabled = nil
    @comment = nil
    @note = nil
    @note_url = nil
    @action_url = nil
    @icon_image = nil
  end

  attr_reader :id

  attr_reader :name

  attr_reader :check_command

  attr_reader :activated

  attr_reader :template

  attr_reader :normal_check_interval

  attr_reader :retry_check_interval

  attr_reader :max_check_attempts

  attr_reader :active_checks_enabled

  attr_reader :passive_checks_enabled

  attr_reader :check_command_args

  attr_reader :macros

  attr_reader :note_url

  attr_reader :action_url

  attr_reader :comment

  attr_reader :service_traps

  attr_reader :categories

  attr_reader :check_period

  attr_reader :volatile_enabled

  attr_reader :note

  attr_reader :icon_image

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

  def check_command=(value)
    raise('wrong type: string required for check_command') unless value.is_a?(String)
    @check_command = value
    logger.debug('Command: ' + value)
  end

  def template=(name)
    raise('wrong type: string required for template') unless name.is_a?(String)
    @template = name
    logger.debug('Template: ' + name)
  end

  def activated=(activated)
    raise('wrong type: boolean required for activated') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
  end

  def normal_check_interval=(value)
    raise('wrong type: integer required for normal_check_interval') unless value.is_a?(Integer)
    @normal_check_interval = value
    logger.debug('Normal check interval: ' + value.to_s)
  end

  def retry_check_interval=(value)
    raise('wrong type: integer required for retry_check_interval') unless value.is_a?(Integer)
    @retry_check_interval = value
    logger.debug('Retry check interval: ' + value.to_s)
  end

  def max_check_attempts=(value)
    raise('wrong type: integer required for max_chack_attempts') unless value.is_a?(Integer)
    @max_check_attempts = value
    logger.debug('Max check attemps: ' + value.to_s)
  end

  def active_checks_enabled=(value)
    raise('wrong type: boolean required for active_check_enabled') unless ['true', 'false', 'default'].include? value
    @active_checks_enabled = value
    logger.debug('Active check enabled: ' + value)
  end

  def passive_checks_enabled=(value)
    raise('wrong type: boolean required for passive_check_enabled') unless ['true', 'false', 'default'].include? value
    @passive_checks_enabled = value
    logger.debug('Passive check enabled: ' + value)
  end

  def note_url=(value)
    raise('wrong type: string required for note_url') unless value.is_a?(String)

    unless value.empty?
      uri = URI.parse(value) unless value.empty?
      raise('URL must be valid') unless uri.is_a?(URI::HTTP) && !uri.host.nil?
    end
    @note_url = value
    logger.debug('Note URL: ' + value)
  end

  def action_url=(value)
    raise('wrong type: string required for action_url') unless value.is_a?(String)

    unless value.empty?
      uri = URI.parse(value) unless value.empty?
      raise('URL must be valid') unless uri.is_a?(URI::HTTP) && !uri.host.nil?
    end

    @action_url = value
    logger.debug('Action URL: ' + value)
  end

  def comment=(value)
    raise('wrong type: string required for macro') unless value.is_a?(String)
    @comment = value
    logger.debug('Comment: ' + value)
  end

  def add_macro(macro)
    raise('wrong type: Centreon::Macro required') unless macro.is_a?(::Centreon::Macro)
    raise('wrong value: macro must be valid') unless macro.valid
    @macros << macro
    logger.debug('Add macro: ' + macro.to_s)
  end

  def add_check_command_arg(arg)
    raise('wrong type: string required for check_command_arg') unless arg.is_a?(String)
    raise('wrong value: arg must be valid') if arg.empty?
    @check_command_args << arg
    logger.debug('Add command arg: ' + arg)
  end

  def add_service_trap(arg)
    raise('wrong type: string required for service trap') unless arg.is_a?(String)
    raise('wrong value: arg must be valid') if arg.empty?
    @service_traps << arg
    logger.debug('Add service trap: ' + arg)
  end

  def add_category(arg)
    raise('wrong type: string required for category') unless arg.is_a?(String)
    raise('wrong value: arg must be valid') if arg.empty?
    @categories << arg
    logger.debug('Add category: ' + arg)
  end

  def check_period=(value)
    raise('wrong type: string required for check_period') unless value.is_a?(String)
    @check_period = value
    logger.debug('check_period: ' + value)
  end

  def volatile_enabled=(value)
     raise('wrong type: boolean required for volatile_enabled') unless ['true', 'false', 'default'].include? value
    @volatile_enabled = value
    logger.debug('volatile_enabled: ' + value)
  end

  def note=(value)
    raise('wrong type: string required for note') unless value.is_a?(String)
    @note = value
    logger.debug('note: ' + value)
  end

  def icon_image=(value)
    raise('wrong type: string required for icon_image') unless value.is_a?(String)
    @icon_image = value
    logger.debug('icon_image: ' + value)
  end

  def to_s
    @name
  end

  def categories_to_s
    if !@categories.empty?
      @categories.join('|')
    else
      ''
    end
  end

  def service_traps_to_s
    if !@service_traps.empty?
      @service_traps.join('|')
    else
      ''
    end
  end
end
