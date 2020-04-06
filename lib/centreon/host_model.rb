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
    @note = nil
    @note_url = nil
    @action_url = nil
    @icon_image = nil
    @snmp_community = nil
    @snmp_version = nil
    @timezone = nil
    @check_command = nil
    @check_command_args = []
    @check_interval = nil
    @retry_check_interval = nil
    @max_check_attempts = nil
    @check_period = nil
    @active_check = nil
    @passive_check = nil
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

  attr_reader :note

  attr_reader :note_url

  attr_reader :action_url

  attr_reader :icon_image

  attr_reader :snmp_community

  attr_reader :snmp_version

  attr_reader :timezone

  attr_reader :check_command

  attr_reader :check_command_args

  attr_reader :check_interval

  attr_reader :retry_check_interval

  attr_reader :max_check_attempts

  attr_reader :check_period

  attr_reader :active_check

  attr_reader :passive_check


  def templates_to_s
    if !@templates.empty?
      @templates.map { |host_template| host_template.name }.join('|')
    else
      ''
    end
  end

  def activated=(activated)
    raise('wrong type: boolean required for activated') unless [true, false].include? activated
    @activated = activated
    logger.debug('Activated: ' + activated.to_s)
  end

  def id=(id)
    raise('wrong type: integer required for id') unless id.is_a?(Integer)
    @id = id
    logger.debug('ID: ' + id.to_s)
  end

  def description=(value)
    raise('wrong type: string required for description') unless value.is_a?(String)
    @description = value
    logger.debug('Description: ' + value)
  end

  def comment=(value)
    raise('wrong type: string required for comment') unless value.is_a?(String)
    @comment = value
    logger.debug('Comment: ' + value)
  end

  def name=(name)
    raise('wrong type: string required for name') unless name.is_a?(String)
    raise("wrong value: name can't be empty") if name.empty?
    @name = name
    logger.debug('Name: ' + name)
  end

  def address=(address)
    raise('wrong type: string required for address') unless address.is_a?(String)
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

  def note=(value)
    raise('wrong type: string required for note') unless value.is_a?(String)
    @note = value
    logger.debug('Note: ' + value)
  end

  def note_url=(value)
    raise('wrong type: string required for note_url') unless value.is_a?(String)
    @note_url = value
    logger.debug('Note URL: ' + value)
  end

  def action_url=(value)
    raise('wrong type: string required for action_url') unless value.is_a?(String)
    @action_url = value
    logger.debug('Action URL: ' + value)
  end

  def icon_image=(value)
    raise('wrong type: string required for icon_image') unless value.is_a?(String)
    @icon_image = value
    logger.debug('Icon image: ' + value)
  end

  def snmp_community=(value)
    raise('wrong type: string required for snmp_community') unless value.is_a?(String)
    @snmp_community = value
    logger.debug('snmp_community: ' + value)
  end

  def snmp_version=(value)
    raise('wrong type: string required for snmp_version') unless value.is_a?(String)
    @snmp_version = value
    logger.debug('snmp_version: ' + value)
  end

  def timezone=(value)
    raise('wrong type: string required for timezone') unless value.is_a?(String)
    @timezone = value
    logger.debug('timezone: ' + value)
  end

  def check_command=(value)
    raise('wrong type: string required for check_command') unless value.is_a?(String)
    @check_command = value
    logger.debug('check_command: ' + value)
  end

  def check_interval=(value)
    raise('wrong type: integer required for check_interval') unless value.is_a?(Integer)
    @check_interval = value
    logger.debug('check_interval: ' + value.to_s)
  end

  def retry_check_interval=(value)
    raise('wrong type: integer required for retry_check_interval') unless value.is_a?(Integer)
    @retry_check_interval = value
    logger.debug('retry_check_interval: ' + value.to_s)
  end

  def max_check_attempts=(value)
    raise('wrong type: integer required for max_check_attempts') unless value.is_a?(Integer)
    @max_check_attempts = value
    logger.debug('max_check_attempts: ' + value.to_s)
  end

  def check_period=(value)
    raise('wrong type: string required for check_period') unless value.is_a?(String)
    @check_period = value
    logger.debug('check_period: ' + value)
  end

  def active_check=(value)
    raise('wrong type: string required for active_check (true, false or default)') unless ['true', 'false', 'default'].include? value
    @active_check = value
    logger.debug('active_check: ' + value)
  end

  def passive_check=(value)
    raise('wrong type: string required for passive_check (true, false or default') unless ['true', 'false', 'default'].include? value
    @passive_check = value
    logger.debug('passive_check: ' + value)
  end

  def add_check_command_arg(arg)
    raise('wrong type: string required for add_check_command_arg') unless arg.is_a?(String)
    raise('wrong value: arg must be valid') if arg.empty?
    @check_command_args << arg
    logger.debug('Add check command arg: ' + arg)
  end

  def to_s
    @name
  end
end
