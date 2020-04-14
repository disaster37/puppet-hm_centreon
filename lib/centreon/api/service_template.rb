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
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy

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
      service_template.check_command = data['check command']
      data['check command arg'].split('!').each do |arg|
        service_template.add_check_command_arg(arg) unless arg.empty?
      end
      service_template.normal_check_interval = data['normal check interval'].to_i unless data['normal check interval'].empty?
      service_template.retry_check_interval = data['retry check interval'].to_i unless data['retry check interval'].empty?
      service_template.max_check_attempts = data['max check attempts'].to_i unless data['max check attempts'].empty?

      case data['active checks enabled']
      when '0'
        service_template.active_checks_enabled = 'false'
      when '1'
        service_template.active_checks_enabled = 'true'
      when '2'
        service_template.active_checks_enabled = 'default'
      end

      case data['passive checks enabled']
      when '0'
        service_template.passive_checks_enabled = 'false'
      when '1'
        service_template.passive_checks_enabled = 'true'
      when '2'
        service_template.passive_checks_enabled = 'default'
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

    # Load catagories
    get_categories(service_template.name).each do |category|
        service_template.add_category(category)
    end

    # Load service traps
    get_service_traps(service_template.name).each do |service_trap|
        service_template.add_service_trap(service_trap)
    end

    # Load host templates
    get_host_templates(service_template.name).each do |host_template|
        service_template.add_host_template(host_template)
    end

    # Load extra params
    get_param(service_template.name, "activate|alias|template|notes_url|action_url|comment|notes|check_period|is_volatile|icon_image").each do |data|
        logger.debug("Params: " + data.to_s)
        service_template.description = data["alias"] unless data["alias"].nil?
        service_template.template = data["template"] unless data["template"].nil?
        service_template.comment = data["comment"] unless data["comment"].nil?
        service_template.note_url = data["notes_url"] unless data["notes_url"].nil?
        service_template.action_url = data["action_url"] unless data["action_url"].nil?
        service_template.check_period = data["check_period"] unless data["check_period"].nil?
        service_template.note = data["notes"] unless data["notes"].nil?
        service_template.icon_image = data["icon_image"] unless data["icon_image"].nil?
        case data['is_volatile']
        when '0'
            service_template.volatile_enabled = 'false'
        when '1'
            service_template.volatile_enabled = 'true'
        when '2'
            service_template.volatile_enabled = 'default'
        end
        case data['activate']
        when '0'
            service_template.activated = false
        when '1'
            service_template.activated = true
        end
    end
  end

  # Get one service template
  def get(service_template_name, lazzy = true)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy

    # Search if service template exist
    service_templates = fetch(service_template_name, lazzy)
    found_service_template = nil
    service_templates.each do |service_template|
      if service_template.name == service_template_name
        found_service_template = service_template
        break
      end
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
    set_param(service_template.name, 'check_command', service_template.check_command) unless service_template.check_command.nil?
    set_param(service_template.name, 'normal_check_interval', service_template.normal_check_interval) unless service_template.normal_check_interval.nil?
    set_param(service_template.name, 'retry_check_interval', service_template.retry_check_interval) unless service_template.retry_check_interval.nil?
    set_param(service_template.name, 'max_check_attempts', service_template.max_check_attempts) unless service_template.max_check_attempts.nil?
    set_param(service_template.name, 'notes_url', service_template.note_url) unless service_template.note_url.nil?
    set_param(service_template.name, 'action_url', service_template.action_url) unless service_template.action_url.nil?
    set_param(service_template.name, 'check_command_arguments', '!' + service_template.check_command_args.join('!')) unless service_template.check_command_args.empty?
    set_param(service_template.name, 'activate', '0') unless service_template.activated
    set_param(service_template.name, 'activate', '1') if service_template.activated
    active_check = case service_template.active_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service_template.name, 'active_checks_enabled', active_check) unless active_check.nil?
    passive_check = case service_template.passive_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service_template.name, 'passive_checks_enabled', passive_check) unless passive_check.nil?
    is_volatile = case service_template.volatile_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service_template.name, 'is_volatile', is_volatile) unless is_volatile.nil?
    set_param(service_template.name, 'check_period', service_template.check_period) unless service_template.check_period.nil?
    set_param(service_template.name, 'notes', service_template.note) unless service_template.note.nil?
    set_param(service_template.name, 'icon_image', service_template.icon_image) unless service_template.icon_image.nil?

    # Set macros
    service_template.macros.each do |macro|
      set_macro(service_template.name, macro)
    end

    # Set host templates
    if !service_template.host_templates.empty?
        set_host_templates(service_template.name, service_template.host_templates_to_s)
    end

    # Set categories
    if !service_template.categories.empty?
        set_categories(service_template.name, service_template.categories_to_s)
    end

    # Set service traps
    if !service_template.service_traps.empty?
        set_service_traps(service_template.name, service_template.service_traps_to_s)
    end
  end

  # Update service template
  def update(service_template, macros = true, activated = true, check_command_args = true, categories = true, traps = true, host_templates = true)
    raise('wrong type: Centreon::ServiceTemplate required') unless service_template.is_a?(::Centreon::ServiceTemplate)
    raise('wrong value: service template must be valid') unless service_template.valid

    set_param(service_template.name, 'alias', service_template.description) unless service_template.description.nil?
    set_param(service_template.name, 'template', service_template.template) unless service_template.template.nil?
    set_param(service_template.name, 'comment', service_template.comment) unless service_template.comment.nil?
    set_param(service_template.name, 'check_command', service_template.check_command) unless service_template.check_command.nil?
    set_param(service_template.name, 'normal_check_interval', service_template.normal_check_interval) unless service_template.normal_check_interval.nil?
    set_param(service_template.name, 'retry_check_interval', service_template.retry_check_interval) unless service_template.retry_check_interval.nil?
    set_param(service_template.name, 'max_check_attempts', service_template.max_check_attempts) unless service_template.max_check_attempts.nil?
    set_param(service_template.name, 'notes_url', service_template.note_url) unless service_template.note_url.nil?
    set_param(service_template.name, 'action_url', service_template.action_url) unless service_template.action_url.nil?
    set_param(service_template.name, 'activate', '0') if !service_template.activated && activated
    set_param(service_template.name, 'activate', '1') if service_template.activated && activated
    active_check = case service_template.active_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service_template.name, 'active_checks_enabled', active_check) unless active_check.nil?
    passive_check = case service_template.passive_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service_template.name, 'passive_checks_enabled', passive_check) unless passive_check.nil?
    is_volatile = case service_template.volatile_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service_template.name, 'is_volatile', is_volatile) unless is_volatile.nil?
    set_param(service_template.name, 'check_period', service_template.check_period) unless service_template.check_period.nil?
    set_param(service_template.name, 'notes', service_template.note) unless service_template.note.nil?
    set_param(service_template.name, 'icon_image', service_template.icon_image) unless service_template.icon_image.nil?

    if check_command_args
      if service_template.check_command_args.empty?
        set_param(service_template.name, 'check_command_arguments', '')
      else
        set_param(service_template.name, 'check_command_arguments', '!' + service_template.check_command_args.join('!'))
      end
    end

    # Set macros
    if macros
        current_macros = get_macros(service_template.name)
        service_template.macros.each do |macro|
            is_already_exist = false
            current_macros.each do |current_macro|
                next unless current_macro.name == macro.name

                if macro.compare(current_macro)
                is_already_exist = true
                end

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

    # Set categories
    if categories
        if service_template.categories.empty?
            service_template_tmp = Centreon::ServiceTemplate.new
            service_template_tmp.name = service_template.name
            get_categories(service_template.name).each do |category|
                service_template_tmp.add_category(category)
            end
            delete_categories(service_template.name, service_template_tmp.categories_to_s)
        else
            set_categories(service_template.name, service_template.categories_to_s)
        end
    end

    if traps
        if service_template.service_traps.empty?
            service_template_tmp = Centreon::ServiceTemplate.new
            service_template_tmp.name = service_template.name
            get_service_traps(service_template.name).each do |service_trap|
                service_template_tmp.add_service_trap(service_trap)
            end
            delete_service_traps(service_template.name, service_template_tmp.service_traps_to_s)

        else
            set_service_traps(service_template.name, service_template.service_traps_to_s)
        end
    end

    if host_templates
        if service_template.host_templates.empty?
            service_template_tmp = Centreon::ServiceTemplate.new
            service_template_tmp.name = service_template.name
            get_host_templates(service_template.name).each do |host_template|
                service_template_tmp.add_host_template(host_template)
            end
            delete_host_templates(service_template.name, service_template_tmp.host_templates_to_s)

        else
            set_host_templates(service_template.name, service_template.host_templates_to_s)
        end
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

  def get_macros(service_template_name)
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

      logger.debug(data)

      # Extract the human name
      macro.name = data['macro name'].scan(/^\$_SERVICE([^\$]+)\$$/).last.first
      macro.value = data['macro value']
      macro.password = !data['is_password'].to_i.zero?
      if data['description'] == '0'
        macro.description = ''
      else
        macro.description = data['description']
      end

      macros << macro
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

  def get_categories(service_template_name)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
  
    r = @client.post({
      'action' => 'getcategory',
      'object' => 'stpl',
      'values' => service_template_name,
    }.to_json)

    logger.debug("Categories: " + r)

    categories = []
    JSON.parse(r)['result'].each do |data|
      categories << data['name']
    end

    return categories
  end

  def set_categories(service_template_name, categories)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for categories') unless categories.is_a?(String)
    raise('wrong value: categories must be valid') unless !categories.nil? && !categories.empty?

    r = @client.post({
      'action' => 'setcategory',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, categories],
    }.to_json)
  end

  def delete_categories(service_template_name, categories)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for categories') unless categories.is_a?(String)
    raise('wrong value: categories must be valid') unless !categories.nil? && !categories.empty?

    r = @client.post({
      'action' => 'delcategory',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, categories],
    }.to_json)
  end

  def get_service_traps(service_template_name)
   raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?

    r = @client.post({
      'action' => 'gettrap',
      'object' => 'stpl',
      'values' => service_template_name,
    }.to_json)

    logger.debug("Traps: " + r)

    traps = []
    JSON.parse(r)['result'].each do |data|
      traps << data['name']
    end

    return traps
  end

  def set_service_traps(service_template_name, service_traps)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for service_traps') unless service_traps.is_a?(String)
    raise('wrong value: service_traps must be valid') unless !service_traps.nil? && !service_traps.empty?

    r = @client.post({
      'action' => 'settrap',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, service_traps],
    }.to_json)
  end

  def delete_service_traps(service_template_name, service_traps)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for service_traps') unless service_traps.is_a?(String)
    raise('wrong value: service_traps must be valid') unless !service_traps.nil? && !service_traps.empty?

    r = @client.post({
      'action' => 'deltrap',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, service_traps],
    }.to_json)
  end

  def get_host_templates(service_template_name)
   raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?

    r = @client.post({
      'action' => 'gethosttemplate',
      'object' => 'stpl',
      'values' => service_template_name,
    }.to_json)

    logger.debug("Host templates: " + r)

    host_templates = []
    JSON.parse(r)['result'].each do |data|
      host_template = Centreon::HostTemplate.new
      host_template.id = data['id'].to_i
      host_template.name = data['name']
      host_templates << host_template
    end

    return host_templates
  end

  def set_host_templates(service_template_name, host_template)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for host_template') unless host_template.is_a?(String)
    raise('wrong value: host_template must be valid') unless !host_template.nil? && !host_template.empty?

    r = @client.post({
      'action' => 'sethosttemplate',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, host_template],
    }.to_json)
  end

  def delete_host_templates(service_template_name, host_template)
    raise('wrong type: String required for service_template_name') unless service_template_name.is_a?(String)
    raise('wrong value: service_template_name must be valid') unless !service_template_name.nil? && !service_template_name.empty?
    raise('wrong type: String required for host_template') unless host_template.is_a?(String)
    raise('wrong value: host_template must be valid') unless !host_template.nil? && !host_template.empty?

    r = @client.post({
      'action' => 'delhosttemplate',
      'object' => 'stpl',
      'values' => '%s;%s' % [service_template_name, host_template],
    }.to_json)
  end
end
