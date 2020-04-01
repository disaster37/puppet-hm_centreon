require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../host_template.rb'

# Manage the service template API
class Centreon::APIClient::ServiceTemplate
  include Logging

  def initialize(client)
    @client = client
  end

  # Delete service template
  def delete(service_template_name)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'stpl',
      'values' => service_template_name,
    }.to_json)
  end

  # Fetch service_templates
  def fetch(service_template_name = nil, lazzy = true)
    r = if service_template_name.nil? || service_template_name.empty?
          @client.post({
            'action' => 'show',
            'object' => 'stpl',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'stpl',
            'values' => service_template_name,
          }.to_json)
        end

    service_templates = []
    JSON.parse(r)['result'].each do |data|
      service_template = Centreon::ServiceTemplate.new
      service_template.id = data['id'].to_i
      service_template.name = data['description']
      service_template.command = data['check command']
      data['check command arg'].split('!').each do |arg|
        service_template.add_command_arg(arg) unless arg.empty?
      end
      service_template.normal_check_interval = data['normal check interval'].to_i unless data['normal check interval'].empty?
      service_template.retry_check_interval = data['retry check interval'].to_i unless data['retry check interval'].empty?
      service_template.max_check_attempts = data['max check attempts'].to_i unless data['max check attempts'].empty?

      case data['active checks enabled']
      when '0'
        service_template.active_check_enabled = 'false'
      when '1'
        service_template.active_check_enabled = 'true'
      when '2'
        service_template.active_check_enabled = 'default'
      end

      case data['passive checks enabled']
      when '0'
        service_template.passive_check_enabled = 'false'
      when '1'
        service_template.passive_check_enabled = 'true'
      when '2'
        service_template.passive_check_enabled = 'default'
      end

      load(service_template) unless lazzy

      service_templates << service_template
    end

    service_templates
  end

  # Load additional data for given service template
  def load(service_template)
    raise('wrong type: Centreon::ServiceTemplate required') unless service_template.is_a?(::Centreon::ServiceTemplate)
    raise('wrong value: service must be valid') unless service_template.valid

    # Load macros
    get_macros(service_template.name).each do |macro|
      service_template.add_macro(macro)
    end

    # Load extra params
    # BUG Centreon, not yet implemented
    # get_param(service_template.name, "activate|alias|template|notes_url|action_url|comment").each do |data|
    #    service_template.description = data["alias"] unless data["alias"].nil?
    #    service_template.activated = true if data["activate"] == 1
    #    service_template.activated = false unless data["activate"] == 1
    #    service_template.template = data["template"] unless data["template"].nil?
    #    service_template.comment = data["comment"] unless data["comment"].nil?
    #    service_template.note_url = data["notes_url"] unless data["notes_url"].nil?
    #    service_template.action_url = data["action_url"] unless data["action_url"].nil?
    # end
  end

  # Get one service template
  def get(service_template_name, lazzy = true)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?

    # Search if service template exist
    service_templates = fetch(service_template_name)
    found_service_template = nil
    service_templates.each do |service_template|
      if service_template.name == service_template_name
        found_service_template = service_template
        break
      end
    end

    if !found_service_template.nil? && !lazzy
      load(found_service_template)
    end

    found_service_template
  end

  # Add service template
  def add(service_template)
    raise('wrong type: Centreon::ServiceTemplate required') unless service_template.is_a?(::Centreon::ServiceTemplate)
    raise('wrong value: service must be valid') unless service_template.valid
    @client.post({
      'action' => 'add',
      'object' => 'stpl',
      'values' => '%s;%s;%s' % [service_template.name, service_template.description, service_template.template],
    }.to_json)

    # Set extra parameters
    set_param(service_template.name, 'comment', service_template.comment) unless service_template.comment.nil?
    set_param(service_template.name, 'check_command', service_template.command) unless service_template.command.nil?
    set_param(service_template.name, 'normal_check_interval', service_template.normal_check_interval) unless service_template.normal_check_interval.nil?
    set_param(service_template.name, 'retry_check_interval', service_template.retry_check_interval) unless service_template.retry_check_interval.nil?
    set_param(service_template.name, 'max_check_attempts', service_template.max_check_attempts) unless service_template.max_check_attempts.nil?
    set_param(service_template.name, 'active_checks_enabled', '0') if !service_template.active_check_enabled.nil? && service_template.active_check_enabled == 'false'
    set_param(service_template.name, 'active_checks_enabled', '1') if !service_template.active_check_enabled.nil? && service_template.active_check_enabled == 'true'
    set_param(service_template.name, 'active_checks_enabled', '2') if !service_template.active_check_enabled.nil? && service_template.active_check_enabled == 'default'
    set_param(service_template.name, 'passive_checks_enabled', '0') if !service_template.passive_check_enabled.nil? && service_template.passive_check_enabled == 'false'
    set_param(service_template.name, 'passive_checks_enabled', '1') if !service_template.passive_check_enabled.nil? && service_template.passive_check_enabled == 'true'
    set_param(service_template.name, 'passive_checks_enabled', '2') if !service_template.passive_check_enabled.nil? && service_template.passive_check_enabled == 'default'
    set_param(service_template.name, 'notes_url', service_template.note_url) unless service_template.note_url.nil?
    set_param(service_template.name, 'action_url', service_template.action_url) unless service_template.action_url.nil?
    set_param(service_template.name, 'check_command_arguments', '!' + service_template.command_args.join('!'))
    set_param(service_template.name, 'activate', '0') unless service_template.activated
    set_param(service_template.name, 'activate', '1') if service_template.activated

    # Set macros
    service_template.macros.each do |macro|
      set_macro(service_template.name, macro)
    end
  end

  # Update service template
  def update(service_template, macros = true, activated = true, check_command_arguments = true)
    raise('wrong type: Centreon::ServiceTemplate required') unless service_template.is_a?(::Centreon::ServiceTemplate)
    raise('wrong value: service must be valid') unless service_template.valid

    set_param(service_template.name, 'alias', service_template.description) unless service_template.description.nil?
    set_param(service_template.name, 'template', service_template.template) unless service_template.template.nil?
    set_param(service_template.name, 'comment', service_template.comment) unless service_template.comment.nil?
    set_param(service_template.name, 'check_command', service_template.command) unless service_template.command.nil?
    set_param(service_template.name, 'normal_check_interval', service_template.normal_check_interval) unless service_template.normal_check_interval.nil?
    set_param(service_template.name, 'retry_check_interval', service_template.retry_check_interval) unless service_template.retry_check_interval.nil?
    set_param(service_template.name, 'max_check_attempts', service_template.max_check_attempts) unless service_template.max_check_attempts.nil?
    set_param(service_template.name, 'active_checks_enabled', '0') if !service_template.active_check_enabled.nil? && service_template.active_check_enabled == 'false'
    set_param(service_template.name, 'active_checks_enabled', '1') if !service_template.active_check_enabled.nil? && service_template.active_check_enabled == 'true'
    set_param(service_template.name, 'active_checks_enabled', '2') if !service_template.active_check_enabled.nil? && service_template.active_check_enabled == 'default'
    set_param(service_template.name, 'passive_checks_enabled', '0') if !service_template.passive_check_enabled.nil? && service_template.passive_check_enabled == 'false'
    set_param(service_template.name, 'passive_checks_enabled', '1') if !service_template.passive_check_enabled.nil? && service_template.passive_check_enabled == 'true'
    set_param(service_template.name, 'passive_checks_enabled', '2') if !service_template.passive_check_enabled.nil? && service_template.passive_check_enabled == 'default'
    set_param(service_template.name, 'notes_url', service_template.note_url) unless service_template.note_url.nil?
    set_param(service_template.name, 'action_url', service_template.action_url) unless service_template.action_url.nil?
    set_param(service_template.name, 'activate', '0') if !service_template.activated && activated
    set_param(service_template.name, 'activate', '1') if service_template.activated && activated

    if check_command_arguments
      set_param(service_template.name, 'check_command_arguments', '!' + service_template.command_args.join('!')) unless service_template.command_args.empty?
    end

    # Set macros
    return unless macros
    current_macros = get_macros(service_template.name)
    service_template.macros.each do |macro|
      is_already_exist = false
      current_macros.each do |current_macro|
        next unless current_macro.name == macro.name
        unless macro.compare(current_macro)
          set_macro(service_template.name, macro)
        end
        is_already_exist = true
        current_macros.delete(current_macro)
        break
      end

      unless is_already_exist
        set_macro(service_template.name, macro)
      end
    end

    # Remove old macros
    current_macros.each do |current_macro|
      delete_macro(service_template.name, current_macro.name)
    end
  end

  private

  def set_param(service_template_name, name, value)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong value: value be valid') if value.nil?

    @client.post({
      'action' => 'setparam',
      'object' => 'stpl',
      'values' => '%s;%s;%s' % [service_template_name, name, value.to_s],
    }.to_json)
  end

  def get_param(service_template_name, name)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    r = @client.post({
      'action' => 'getparam',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, name],
    }.to_json)

    JSON.parse(r)['result']
  end

  def get_macros(service_template_name, only_direct = true)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?

    r = @client.post({
      'action' => 'getmacro',
      'object' => 'stpl',
      'values' => service_template_name,
    }.to_json)

    macros = []
    JSON.parse(r)['result'].each do |data|
      macro = ::Centreon::Macro.new
      macro.name = data['macro name']
      macro.value = data['macro value']
      macro.password = !data['is_password'].to_i.zero?
      macro.description = data['description']
      macro.source = data['source'] unless data['source'].nil?

      if only_direct
        macros << macro if macro.source == 'direct'
      else
        macros << macro
      end
    end

    macros
  end

  def set_macro(service_template_name, macro)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: Centreon::Macro required') unless macro.is_a?(::Centreon::Macro)
    raise('wrong value: macro must be valid') unless macro.valid

    case macro.description.nil?
    when true
      description = ''
    when false
      description = macro.description
    end

    case macro.password
    when true
      password = '1'
    when false
      password = '0'
    end

    @client.post({
      'action' => 'setmacro',
      'object' => 'stpl',
      'values' => '%s;%s;%s;%s;%s' % [service_template_name, macro.name.upcase, macro.value, password, description],
    }.to_json)
  end

  def delete_macro(service_template_name, name)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'delmacro',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, name],
    }.to_json)
  end
end
