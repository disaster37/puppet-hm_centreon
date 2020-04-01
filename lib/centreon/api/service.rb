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

  def fetch(service_name = nil, lazzy = true)
    r = if service_name.nil? || service_name.empty?
          @client.post({
            'action' => 'show',
            'object' => 'service',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'service',
            'values' => service_name,
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
      service.command = data['check command']
      data['check command arg'].split('!').each do |arg|
        service.add_command_arg(arg) unless arg.empty?
      end
      service.normal_check_interval = data['normal check interval'].to_i unless data['normal check interval'].empty?
      service.retry_check_interval = data['retry check interval'].to_i unless data['retry check interval'].empty?
      service.max_check_attempts = data['max check attempts'].to_i unless data['max check attempts'].empty?

      case data['active checks enabled']
      when '0'
        service.active_check_enabled = 'false'
      when '1'
        service.active_check_enabled = 'true'
      when '2'
        service.active_check_enabled = 'default'
      end

      case data['passive checks enabled']
      when '0'
        service.passive_check_enabled = 'false'
      when '1'
        service.passive_check_enabled = 'true'
      when '2'
        service.passive_check_enabled = 'default'
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

    fetch_service_group(nil, services) unless lazzy

    services
  end

  def fetch_service_group(service_group_name = nil, services = [])
    r = if service_group_name.nil?
          @client.post({
            'action' => 'show',
            'object' => 'sg',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'sg',
            'values' => service_group_name,
          }.to_json)
        end

    service_groups = []
    JSON.parse(r)['result'].each do |data|
      service_group = Centreon::ServiceGroup.new
      service_group.id = data['id'].to_i
      service_group.name = data['name']
      service_group.description = data['alias']

      # Load services associated to current sg
      r = @client.post({
        'action' => 'getservice',
        'object' => 'sg',
        'values' => service_group.name,
      }.to_json)

      JSON.parse(r)['result'].each do |data2|
        is_service_found = false
        services.each do |service|
          next unless data2['host name'] == service.host.name && data2['service description'] == service.name
          service_group.add_service(service)
          service.add_group(service_group)
          is_service_found = true
          logger.debug('Found service group: ' + service_group.to_s)
          break
        end
        next if is_service_found
        host = Centreon::Host.new
        host.id = data2['host id'].to_i
        host.name = data2['host name']
        service = Centreon::Service.new
        service.id = data2['service id'].to_i
        service.name = data2['service description']
        service.host = host
        service_group.add_service(service)
      end

      service_groups << service_group
    end

    service_groups
  end

  # Load additional data for given service
  def load(service)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless service.valid

    # Load macros
    get_macros(service.host.name, service.name).each do |macro|
      service.add_macro(macro)
    end

    # Load extra params
    # BUG Centreon, not yet implemented
    # get_param(service.host.name, service.name, "template|notes_url|action_url|comment").each do |data|
    #    service.template = data["template"] unless data["template"].nil?
    #    service.comment = data["comment"] unless data["comment"].nil?
    #    service.note_url = data["notes_url"] unless data["notes_url"].nil?
    #    service.action_url = data["action_url"] unless data["action_url"].nil?
    # end
  end

  # Get one host from monitoring
  def get(host_name, service_name, lazzy = true)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?

    # Search if host exist
    services = fetch(service_name)
    found_service = nil
    services.each do |service|
      if service.host.name == host_name && service.name == service_name
        found_service = service
        break
      end
    end

    if !found_service.nil? && !lazzy
      load(found_service)
      fetch_service_group(nil, [found_service])
    end

    found_service
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
    set_param(service.host.name, service.name, 'check_command', service.command) unless service.command.nil?
    set_param(service.host.name, service.name, 'normal_check_interval', service.normal_check_interval) unless service.normal_check_interval.nil?
    set_param(service.host.name, service.name, 'retry_check_interval', service.retry_check_interval) unless service.retry_check_interval.nil?
    set_param(service.host.name, service.name, 'max_check_attempts', service.max_check_attempts) unless service.max_check_attempts.nil?
    set_param(service.host.name, service.name, 'active_checks_enabled', '0') if !service.active_check_enabled.nil? && service.active_check_enabled == 'false'
    set_param(service.host.name, service.name, 'active_checks_enabled', '1') if !service.active_check_enabled.nil? && service.active_check_enabled == 'true'
    set_param(service.host.name, service.name, 'active_checks_enabled', '2') if !service.active_check_enabled.nil? && service.active_check_enabled == 'default'
    set_param(service.host.name, service.name, 'passive_checks_enabled', '0') if !service.passive_check_enabled.nil? && service.passive_check_enabled == 'false'
    set_param(service.host.name, service.name, 'passive_checks_enabled', '1') if !service.passive_check_enabled.nil? && service.passive_check_enabled == 'true'
    set_param(service.host.name, service.name, 'passive_checks_enabled', '2') if !service.passive_check_enabled.nil? && service.passive_check_enabled == 'default'
    set_param(service.host.name, service.name, 'notes_url', service.note_url) unless service.note_url.nil?
    set_param(service.host.name, service.name, 'action_url', service.action_url) unless service.action_url.nil?
    set_param(service.host.name, service.name, 'check_command_arguments', '!' + service.command_args.join('!'))
    set_param(service.host.name, service.name, 'activate', '0') unless service.activated
    set_param(service.host.name, service.name, 'activate', '1') if service.activated

    # Set macros
    service.macros.each do |macro|
      set_macro(service.host.name, service.name, macro)
    end

    # Set services groups
    service.groups.each do |service_group|
      set_service_group(service.host.name, service.name, service_group.name)
    end
  end

  def update(service, groups = true, macros = true, activated = true, check_command_arguments = true)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless service.valid

    set_param(service.host.name, service.name, 'template', service.template) unless service.template.nil?
    set_param(service.host.name, service.name, 'comment', service.comment) unless service.comment.nil?
    set_param(service.host.name, service.name, 'check_command', service.command) unless service.command.nil?
    set_param(service.host.name, service.name, 'normal_check_interval', service.normal_check_interval) unless service.normal_check_interval.nil?
    set_param(service.host.name, service.name, 'retry_check_interval', service.retry_check_interval) unless service.retry_check_interval.nil?
    set_param(service.host.name, service.name, 'max_check_attempts', service.max_check_attempts) unless service.max_check_attempts.nil?
    set_param(service.host.name, service.name, 'active_checks_enabled', '0') if !service.active_check_enabled.nil? && service.active_check_enabled == 'false'
    set_param(service.host.name, service.name, 'active_checks_enabled', '1') if !service.active_check_enabled.nil? && service.active_check_enabled == 'true'
    set_param(service.host.name, service.name, 'active_checks_enabled', '2') if !service.active_check_enabled.nil? && service.active_check_enabled == 'default'
    set_param(service.host.name, service.name, 'passive_checks_enabled', '0') if !service.passive_check_enabled.nil? && service.passive_check_enabled == 'false'
    set_param(service.host.name, service.name, 'passive_checks_enabled', '1') if !service.passive_check_enabled.nil? && service.passive_check_enabled == 'true'
    set_param(service.host.name, service.name, 'passive_checks_enabled', '2') if !service.passive_check_enabled.nil? && service.passive_check_enabled == 'default'
    set_param(service.host.name, service.name, 'notes_url', service.note_url) unless service.note_url.nil?
    set_param(service.host.name, service.name, 'action_url', service.action_url) unless service.action_url.nil?
    set_param(service.host.name, service.name, 'activate', '0') if !service.activated && activated
    set_param(service.host.name, service.name, 'activate', '1') if service.activated && activated

    if check_command_arguments
      set_param(service.host.name, service.name, 'check_command_arguments', '!' + service.command_args.join('!')) unless service.command_args.empty?
    end

    # Set macros
    if macros
      current_macros = get_macros(service.host.name, service.name)
      service.macros.each do |macro|
        is_already_exist = false
        current_macros.each do |current_macro|
          next unless current_macro.name == macro.name
          unless macro.compare(current_macro)
            set_macro(service.host.name, service.name, macro)
          end
          is_already_exist = true
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

    # Set service groups
    return unless groups

    service_tmp = Centreon::Service.new
    service_tmp.host = service.host
    service_tmp.name = service.name
    fetch_service_group(nil, [service_tmp])
    current_groups = service_tmp.groups
    service.groups.each do |group|
      is_already_exist = false
      current_groups.each do |current_group|
        next unless current_group.name == group.name
        is_already_exist = true
        current_groups.delete(current_group)
        break
      end

      unless is_already_exist
        set_service_group(service.host.name, service.name, group.name)
      end
    end

    # Remove old groups
    current_groups.each do |current_group|
      delete_service_group(service.host.name, service.name, current_group.name)
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

    JSON.parse(r)['result']
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

    macros
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

  def set_service_group(host_name, service_name, name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'addservice',
      'object' => 'sg',
      'values' => '%s;%s,%s' % [name, host_name, service_name],
    }.to_json)
  end

  def delete_service_group(host_name, service_name, name)
    raise('wrong type: String required for host_name') unless host_name.is_a?(String)
    raise('wrong value: host_name must be valid') unless !host_name.nil? && !host_name.empty?
    raise('wrong type: String required for service_name') unless service_name.is_a?(String)
    raise('wrong value: service_name must be valid') unless !service_name.nil? && !service_name.empty?
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'delservice',
      'object' => 'sg',
      'values' => '%s;%s;%s' % [host_name, service_name, name],
    }.to_json)
  end
end
