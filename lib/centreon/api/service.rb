require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../host.rb'

# Manage the service API
class Centreon::APIClient::Service
  include Logging

  def initialize(client)
    @client = client
  end

  def delete(host_name, service_name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'service',
      'values' => '%s;%s' % [host_name, service_name],
    }.to_json)
  end

  def fetch(host_name = nil, service_name = nil, lazzy = true)
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy
    r = if service_name.nil? || service_name.empty?
          @client.post({
            'action' => 'show',
            'object' => 'service',
          }.to_json)
        elsif host_name.nil? || host_name.empty?
          @client.post({
            'action' => 'show',
            'object' => 'service',
            'values' => service_name,
          }.to_json)
        else
            @client.post({
            'action' => 'show',
            'object' => 'service',
            'values' => '%s;%s' % [host_name, service_name],
          }.to_json)
        end

    services = []
    JSON.parse(r)['result'].each do |data|
      host = Centreon::Host.new
      host.id = data['host id'].to_i
      host.name = data['host name']
      service = Centreon::Service.new
      service.host = host
      service.id = data['id'].to_i
      service.name = data['description']
      service.check_command = data['check command']
      data['check command arg'].split('!').each do |arg|
        service.add_check_command_arg(arg) unless arg.empty?
      end
      service.normal_check_interval = data['normal check interval'].to_i unless data['normal check interval'].empty?
      service.retry_check_interval = data['retry check interval'].to_i unless data['retry check interval'].empty?
      service.max_check_attempts = data['max check attempts'].to_i unless data['max check attempts'].empty?

      case data['active checks enabled']
      when '0'
        service.active_checks_enabled = 'false'
      when '1'
        service.active_checks_enabled = 'true'
      when '2'
        service.active_checks_enabled = 'default'
      end

      case data['passive checks enabled']
      when '0'
        service.passive_checks_enabled = 'false'
      when '1'
        service.passive_checks_enabled = 'true'
      when '2'
        service.passive_checks_enabled = 'default'
      end

      case data['activate']
      when '0'
        service.activated = false
      when '1'
        service.activated = true
      end

      load(service) unless lazzy

      services << service
    end

    return services
  end

  # Load additional data for given service
  def load(service)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless service.valid

    # Load macros
    get_macros(service.host.name, service.name).each do |macro|
      service.add_macro(macro)
    end

    # Load catagories
    get_categories(service.host.name, service.name).each do |category|
        service.add_category(category)
    end

    # Load services groups
    get_service_groups(service.host.name, service.name).each do |service_group|
        service.add_group(service_group)
    end

    # Load service traps
    get_service_traps(service.host.name, service.name).each do |service_trap|
        service.add_service_trap(service_trap)
    end

    # Load extra params
    get_param(service.host.name, service.name, "template|notes_url|action_url|comment|notes|check_period|is_volatile|icon_image").each do |data|
        logger.debug("Params: " + data.to_s)
        service.template = data["template"] unless data["template"].nil?
        service.comment = data["comment"] unless data["comment"].nil?
        service.note_url = data["notes_url"] unless data["notes_url"].nil?
        service.action_url = data["action_url"] unless data["action_url"].nil?
        service.check_period = data["check_period"] unless data["check_period"].nil?
        service.note = data["notes"] unless data["notes"].nil?
        service.icon_image = data["icon_image"] unless data["icon_image"].nil?
        case data['is_volatile']
        when '0'
            service.volatile_enabled = 'false'
        when '1'
            service.volatile_enabled = 'true'
        when '2'
            service.volatile_enabled = 'default'
        end
    end
  end

  # Get one host from monitoring
  def get(host_name, service_name, lazzy = true)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy
    
    # Search if host exist
    services = fetch(host_name, service_name)
    found_service = nil
    services.each do |service|
      if service.host.name == host_name && service.name == service_name
        found_service = service
        break
      end
    end

    if !found_service.nil? && !lazzy
      load(found_service)
    end

    return found_service
  end

  def add(service)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless service.valid
    @client.post({
      'action' => 'add',
      'object' => 'service',
      'values' => '%s;%s;%s' % [service.host.name, service.name, service.template],
    }.to_json)

    # Set extra parameters
    set_param(service.host.name, service.name, 'comment', service.comment) unless service.comment.nil?
    set_param(service.host.name, service.name, 'check_command', service.check_command) unless service.check_command.nil?
    set_param(service.host.name, service.name, 'normal_check_interval', service.normal_check_interval) unless service.normal_check_interval.nil?
    set_param(service.host.name, service.name, 'retry_check_interval', service.retry_check_interval) unless service.retry_check_interval.nil?
    set_param(service.host.name, service.name, 'max_check_attempts', service.max_check_attempts) unless service.max_check_attempts.nil?
    set_param(service.host.name, service.name, 'notes_url', service.note_url) unless service.note_url.nil?
    set_param(service.host.name, service.name, 'action_url', service.action_url) unless service.action_url.nil?
    set_param(service.host.name, service.name, 'check_command_arguments', '!' + service.check_command_args.join('!')) unless service.check_command_args.empty?
    set_param(service.host.name, service.name, 'activate', '0') unless service.activated
    set_param(service.host.name, service.name, 'activate', '1') if service.activated
    active_check = case service.active_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service.host.name, service.name, 'active_checks_enabled', active_check) unless active_check.nil?
    passive_check = case service.passive_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service.host.name, service.name, 'passive_checks_enabled', passive_check) unless passive_check.nil?
    is_volatile = case service.volatile_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service.host.name, service.name, 'is_volatile', is_volatile) unless is_volatile.nil?
    set_param(service.host.name, service.name, 'check_period', service.check_period) unless service.check_period.nil?
    set_param(service.host.name, service.name, 'notes', service.note) unless service.note.nil?
    set_param(service.host.name, service.name, 'icon_image', service.icon_image) unless service.icon_image.nil?

    # Set macros
    service.macros.each do |macro|
      set_macro(service.host.name, service.name, macro)
    end

    # Set services groups
    if !service.groups.empty?
        set_service_groups(service.host.name, service.name, service.groups_to_s)
    end

    # Set categories
    if !service.categories.empty?
        set_categories(service.host.name, service.name, service.categories_to_s)
    end

    # Set service traps
    if !service.service_traps.empty?
        set_service_traps(service.host.name, service.name, service.service_traps_to_s)
    end
  end

  def update(service, groups = true, macros = true, activated = true, check_command_args = true, categories = true, traps = true)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless service.valid

    set_param(service.host.name, service.name, 'template', service.template) unless service.template.nil?
    set_param(service.host.name, service.name, 'comment', service.comment) unless service.comment.nil?
    set_param(service.host.name, service.name, 'check_command', service.check_command) unless service.check_command.nil?
    set_param(service.host.name, service.name, 'normal_check_interval', service.normal_check_interval) unless service.normal_check_interval.nil?
    set_param(service.host.name, service.name, 'retry_check_interval', service.retry_check_interval) unless service.retry_check_interval.nil?
    set_param(service.host.name, service.name, 'max_check_attempts', service.max_check_attempts) unless service.max_check_attempts.nil?
    set_param(service.host.name, service.name, 'notes_url', service.note_url) unless service.note_url.nil?
    set_param(service.host.name, service.name, 'action_url', service.action_url) unless service.action_url.nil?
    set_param(service.host.name, service.name, 'activate', '0') if !service.activated && activated
    set_param(service.host.name, service.name, 'activate', '1') if service.activated && activated
    active_check = case service.active_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service.host.name, service.name, 'active_checks_enabled', active_check) unless active_check.nil?
    passive_check = case service.passive_checks_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service.host.name, service.name, 'passive_checks_enabled', passive_check) unless passive_check.nil?
    is_volatile = case service.volatile_enabled
    when 'false'
        '0'
    when 'true'
        '1'
    when 'default'
        '2'
    else
        nil
    end
    set_param(service.host.name, service.name, 'is_volatile', is_volatile) unless is_volatile.nil?
    set_param(service.host.name, service.name, 'check_period', service.check_period) unless service.check_period.nil?
    set_param(service.host.name, service.name, 'notes', service.note) unless service.note.nil?
    set_param(service.host.name, service.name, 'icon_image', service.icon_image) unless service.icon_image.nil?

    if check_command_args
      if service.check_command_args.empty?
        set_param(service.host.name, service.name, 'check_command_arguments', '')
      else
        set_param(service.host.name, service.name, 'check_command_arguments', '!' + service.check_command_args.join('!'))
      end
    end

    # Set macros
    if macros
        current_macros = get_macros(service.host.name, service.name)
        service.macros.each do |macro|
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
                set_macro(service.host.name, service.name, macro)
            end
        end

        # Remove old macros
        current_macros.each do |current_macro|
            delete_macro(service.host.name, service.name, current_macro.name)
        end
    end

    # Set categories
    if categories
        if service.categories.empty?
            service_tmp = Centreon::Service.new
            service_tmp.host = service.host
            service_tmp.name = service.name
            get_categories(service.host.name, service.name).each do |category|
                service_tmp.add_category(category)
            end
            delete_categories(service.host.name, service.name, service_tmp.categories_to_s)
        else
            set_categories(service.host.name, service.name, service.categories_to_s)
        end
    end

    if traps
        if service.service_traps.empty?
            service_tmp = Centreon::Service.new
            service_tmp.host = service.host
            service_tmp.name = service.name
            get_service_traps(service.host.name, service.name).each do |service_trap|
                service_tmp.add_service_trap(service_trap)
            end
            delete_service_traps(service.host.name, service.name, service_tmp.service_traps_to_s)

        else
            set_service_traps(service.host.name, service.name, service.service_traps_to_s)
        end
    end

    # Set service groups
    return unless groups
    if service.groups.empty?
        service_tmp = Centreon::Service.new
        service_tmp.host = service.host
        service_tmp.name = service.name
        get_service_groups(service.host.name, service.name).each do |service_group|
            service_tmp.add_group(service_group)
        end
        delete_service_groups(service.host.name, service.name, service_tmp.groups_to_s)
    else
        set_service_groups(service.host.name, service.name, service.groups_to_s)
    end
  end

  private

  def set_param(host_name, service_name, name, value)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong value: value be valid') if value.nil?

    @client.post({
      'action' => 'setparam',
      'object' => 'service',
      'values' => '%s;%s;%s;%s' % [host_name, service_name, name, value.to_s],
    }.to_json)
  end

  def get_param(host_name, service_name, name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    r = @client.post({
      'action' => 'getparam',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, name],
    }.to_json)

    return JSON.parse(r)['result']
  end

  def set_host(host_name, service_name, new_host_name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for new_host_name') unless new_host_name.is_a?(String)
    raise('wrong value: new_host_name must be valid') unless !new_host_name.nil? && !new_host_name.empty?

    @client.post({
      'action' => 'sethost',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, new_host_name],
    }.to_json)
  end

  def get_macros(host_name, service_name, only_direct = true)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?

    r = @client.post({
      'action' => 'getmacro',
      'object' => 'service',
      'values' => '%s;%s' % [host_name, service_name],
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

    return macros
  end

  def set_macro(host_name, service_name, macro)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
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
      'object' => 'service',
      'values' => '%s;%s;%s;%s;%s;%s' % [host_name, service_name, macro.name.upcase, macro.value, password, description],
    }.to_json)
  end

  def delete_macro(host_name, service_name, name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'delmacro',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, name],
    }.to_json)
  end

  def get_categories(host_name, service_name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
  
    r = @client.post({
      'action' => 'getcategory',
      'object' => 'service',
      'values' => '%s;%s' % [host_name, service_name],
    }.to_json)

    logger.debug("Categories: " + r)

    categories = []
    JSON.parse(r)['result'].each do |data|
      categories << data['name']
    end

    return categories
  end

  def set_categories(host_name, service_name, categories)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for categories') unless categories.is_a?(String)
    raise('wrong value: categories must be valid') unless !categories.nil? && !categories.empty?

    r = @client.post({
      'action' => 'setcategory',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, categories],
    }.to_json)
  end

  def delete_categories(host_name, service_name, categories)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for categories') unless categories.is_a?(String)
    raise('wrong value: categories must be valid') unless !categories.nil? && !categories.empty?

    r = @client.post({
      'action' => 'delcategory',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, categories],
    }.to_json)
  end

  def get_service_groups(host_name, service_name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?

    r = @client.post({
      'action' => 'getservicegroup',
      'object' => 'service',
      'values' => '%s;%s' % [host_name, service_name],
    }.to_json)

    logger.debug("Service group: " + r)

    service_groups = []
    JSON.parse(r)['result'].each do |data|
        service_group = Centreon::ServiceGroup.new
        service_group.id = data['id'].to_i
        service_group.name = data['name']
        service_groups << service_group
    end

    return service_groups
  end

  def set_service_groups(host_name, service_name, service_groups)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for service_groups') unless service_groups.is_a?(String)
    raise('wrong value: service_groups must be valid') unless !service_groups.nil? && !service_groups.empty?

    r = @client.post({
      'action' => 'setservicegroup',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, service_groups],
    }.to_json)
  end

  def delete_service_groups(host_name, service_name, service_groups)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for service_groups') unless service_groups.is_a?(String)
    raise('wrong value: service_groups must be valid') unless !service_groups.nil? && !service_groups.empty?

    r = @client.post({
      'action' => 'delservicegroup',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, service_groups],
    }.to_json)
  end

  def get_service_traps(host_name, service_name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?

    r = @client.post({
      'action' => 'gettrap',
      'object' => 'service',
      'values' => '%s;%s' % [host_name, service_name],
    }.to_json)

    logger.debug("Traps: " + r)

    traps = []
    JSON.parse(r)['result'].each do |data|
      traps << data['name']
    end

    return traps
  end

  def set_service_traps(host_name, service_name, service_traps)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for service_traps') unless service_traps.is_a?(String)
    raise('wrong value: service_traps must be valid') unless !service_traps.nil? && !service_traps.empty?

    r = @client.post({
      'action' => 'settrap',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, service_traps],
    }.to_json)
  end

  def delete_service_traps(host_name, service_name, service_traps)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for service_traps') unless service_traps.is_a?(String)
    raise('wrong value: service_traps must be valid') unless !service_traps.nil? && !service_traps.empty?

    r = @client.post({
      'action' => 'deltrap',
      'object' => 'service',
      'values' => '%s;%s;%s' % [host_name, service_name, service_traps],
    }.to_json)
  end
end
