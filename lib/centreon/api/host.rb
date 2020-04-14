require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../host.rb'

# Manage the host API
class Centreon::APIClient::Host
  include Logging

  def initialize(client)
    @client = client
  end

  # Return all hosts in centreon
  def fetch(name = nil, lazzy = true)
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy
    r = if name.nil?
          @client.post({
            'action' => 'show',
            'object' => 'host',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'host',
            'values' => name,
          }.to_json)
        end

    hosts = []
    JSON.parse(r)['result'].each do |data|
      host = ::Centreon::Host.new
      host.id = data['id'].to_i unless data['id'].nil?
      host.name = data['name'] unless data['name'].nil?

      # Fix bug
      if data['alias'].is_a?(Array)
        data['alias'] = data['alias'].join('|')
      end

      host.description = data['alias'] unless data['alias'].nil?
      host.address = data['address'] unless data['address'].nil?
      host.activated = !data['activate'].to_i.zero? unless data['activate'].nil?

      # Load all properties if lazzy is false
      load(host) unless lazzy

      hosts << host
    end

    hosts
  end

  # Load additional data for given host
  def load(host)
    raise('wrong type: Centreon::Host required') unless host.is_a?(::Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?

    # Load host_templates
    get_templates(host.name).each do |host_template|
      host.add_template(host_template)
    end

    # Load host groups
    get_groups(host.name).each do |host_group|
      host.add_group(host_group)
    end

    # Load macros
    get_macros(host.name).each do |macro|
      host.add_macro(macro)
    end

    # Load poller
    get_poller(host.name).each do |data|
      host.poller = data['name']
    end

    # Load extra params
    get_param(host.name, 'comment|action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone').each do |data| # rubocop:disable LineLength
      host.comment = data['comment'] unless data['comment'].nil?
      host.snmp_community = data['snmp_community'] unless data['snmp_community'].nil?
      host.snmp_version = data['snmp_version'] unless data['snmp_version'].nil?
      host.timezone = data['timezone'] unless data['timezone'].nil?
      host.check_command = data['check_command'] unless data['check_command'].nil?
      unless data['check_command_arguments'].nil?
        data['check_command_arguments'].split('!').each do |arg|
          host.add_check_command_arg(arg) unless arg.empty?
        end
      end
      host.check_interval = data['check_interval'].to_i unless data['check_interval'].nil?
      host.retry_check_interval = data['retry_check_interval'].to_i unless data['retry_check_interval'].nil?
      host.max_check_attempts = data['max_check_attempts'].to_i unless data['max_check_attempts'].nil?
      host.check_period = data['check_period'] unless data['check_period'].nil?
      host.note_url = data['notes_url'] unless data['notes_url'].nil?
      host.action_url = data['action_url'] unless data['action_url'].nil?
      host.note = data['notes'] unless data['notes'].nil?
      host.icon_image = data['icon_image'] unless data['icon_image'].nil?

      case data['active_checks_enabled']
      when '0'
        host.active_checks_enabled = 'false'
      when '1'
        host.active_checks_enabled = 'true'
      when '2'
        host.active_checks_enabled = 'default'
      end

      case data['passive_checks_enabled']
      when '0'
        host.passive_checks_enabled = 'false'
      when '1'
        host.passive_checks_enabled = 'true'
      when '2'
        host.passive_checks_enabled = 'default'
      end
    end
  end

  # Get one host from monitoring
  def get(name, lazzy = true)
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy
    # Search if host exist
    hosts = fetch(name, lazzy)

    unless hosts.empty?
      return hosts[0]
    end

    nil
  end

  # Create new host on monitoring
  def add(host)
    raise('wrong type: Centreon::Host required') unless host.is_a?(::Centreon::Host)
    raise('wrong value: host must be valid') unless host.valid
    @client.post({
      'action' => 'add',
      'object' => 'host',
      'values' => '%s;%s;%s;%s;%s;%s' % [host.name, host.description, host.address, host.templates_to_s, host.poller, host.groups_to_s],
    }.to_json)

    # Set extra parameters
    # Set extra parameters
    set_param(host.name, 'comment', host.comment) unless host.comment.nil?
    set_param(host.name, 'snmp_community', host.snmp_community) unless host.snmp_community.nil?
    set_param(host.name, 'snmp_version', host.snmp_version) unless host.snmp_version.nil?
    set_param(host.name, 'timezone', host.timezone) unless host.timezone.nil?
    set_param(host.name, 'check_command', host.check_command) unless host.check_command.nil?
    set_param(host.name, 'check_command_arguments', '!' + host.check_command_args.join('!')) unless host.check_command_args.empty?
    set_param(host.name, 'check_interval', host.check_interval) unless host.check_interval.nil?
    set_param(host.name, 'retry_check_interval', host.retry_check_interval) unless host.retry_check_interval.nil?
    set_param(host.name, 'max_check_attempts', host.max_check_attempts) unless host.max_check_attempts.nil?
    set_param(host.name, 'check_period', host.check_period) unless host.check_period.nil?
    active_check = case host.active_checks_enabled
                   when 'false'
                     '0'
                   when 'true'
                     '1'
                   when 'default'
                     '2'
                   else
                     nil
                   end
    set_param(host.name, 'active_checks_enabled', active_check) unless active_check.nil?
    passive_check = case host.passive_checks_enabled
                    when 'false'
                      '0'
                    when 'true'
                      '1'
                    when 'default'
                      '2'
                    else
                      nil
                    end
    set_param(host.name, 'passive_checks_enabled', passive_check) unless passive_check.nil?
    set_param(host.name, 'notes_url', host.note_url) unless host.note_url.nil?
    set_param(host.name, 'action_url', host.action_url) unless host.action_url.nil?
    set_param(host.name, 'notes', host.note) unless host.note.nil?
    set_param(host.name, 'icon_image', host.icon_image) unless host.icon_image.nil?

    # Disable it if needed
    disable(host.name) unless host.activated

    # Set macros
    host.macros.each do |macro|
      set_macro(host.name, macro)
    end

    # Apply template if needed
    apply_template(host.name) unless host.templates.empty?
  end

  def update(host, groups = true, templates = true, macros = true, activated = true, check_command_args = true)
    raise('wrong type: Centreon::Host required') unless host.is_a?(::Centreon::Host)
    raise('wrong value: host must be valid') unless host.valid_name

    set_param(host.name, 'alias', host.description) unless host.description.nil?
    set_param(host.name, 'address', host.address) unless host.address.nil?
    set_param(host.name, 'comment', host.comment) unless host.comment.nil?
    set_poller(host.name, host.poller) unless host.poller.nil?
    if activated
      enable(host.name) if host.activated
      disable(host.name) unless host.activated
    end
    set_param(host.name, 'snmp_community', host.snmp_community) unless host.snmp_community.nil?
    set_param(host.name, 'snmp_version', host.snmp_version) unless host.snmp_version.nil?
    set_param(host.name, 'timezone', host.timezone) unless host.timezone.nil?
    set_param(host.name, 'check_command', host.check_command) unless host.check_command.nil?
    set_param(host.name, 'check_interval', host.check_interval) unless host.check_interval.nil?
    set_param(host.name, 'retry_check_interval', host.retry_check_interval) unless host.retry_check_interval.nil?
    set_param(host.name, 'max_check_attempts', host.max_check_attempts) unless host.max_check_attempts.nil?
    set_param(host.name, 'check_period', host.check_period) unless host.check_period.nil?
    active_check = case host.active_checks_enabled
                   when 'false'
                     '0'
                   when 'true'
                     '1'
                   when 'default'
                     '2'
                   else
                     nil
                   end
    set_param(host.name, 'active_checks_enabled', active_check) unless active_check.nil?
    passive_check = case host.passive_checks_enabled
                    when 'false'
                      '0'
                    when 'true'
                      '1'
                    when 'default'
                      '2'
                    else
                      nil
                    end
    set_param(host.name, 'passive_checks_enabled', passive_check) unless passive_check.nil?
    set_param(host.name, 'notes_url', host.note_url) unless host.note_url.nil?
    set_param(host.name, 'action_url', host.action_url) unless host.action_url.nil?
    set_param(host.name, 'notes', host.note) unless host.note.nil?
    set_param(host.name, 'icon_image', host.icon_image) unless host.icon_image.nil?

    if groups
      # Set groups if needed or remove all groups
      if host.groups.empty?
        host_tmp = Centreon::Host.new
        host_tmp.name = host.name
        get_groups(host.name).each do |host_group|
          host_tmp.add_group(host_group)
        end
        delete_groups(host_tmp)
      else
        set_groups(host.name, host.groups_to_s)
      end
    end

    if templates
      # Set templates if needed or remove all templates
      if host.templates.empty?
        host_tmp = Centreon::Host.new
        host_tmp.name = host.name
        get_templates(host.name).each do |host_template|
          host_tmp.add_template(host_template)
        end
        delete_templates(host_tmp)
      elsif templates
        set_templates(host.name, host.templates_to_s)
      end

      apply_template(host.name)
    end

    if check_command_args
      if host.check_command_args.empty?
        set_param(host.name, 'check_command_arguments', '')
      else
        set_param(host.name, 'check_command_arguments', '!' + host.check_command_args.join('!'))
      end
    end

    return unless macros
    current_macros = get_macros(host.name)
    host.macros.each do |macro|
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
        set_macro(host.name, macro)
      end
    end

    # Remove old macros
    current_macros.each do |current_macro|
      delete_macro(host.name, current_macro.name)
    end
  end

  def delete(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'host',
      'values' => name,
    }.to_json)
  end

  def add_templates(host)
    raise('wrong type: Centreon:Host required') unless host.is_a?(Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    raise("wrong value: templates can't be empty") if host.templates.empty?

    @client.post({
      'action' => 'addtemplate',
      'object' => 'host',
      'values' => '%s;%s' % [host.name, host.templates_to_s],
    }.to_json)
  end

  def delete_templates(host)
    raise('wrong type: Centreon:Host required') unless host.is_a?(Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    raise("wrong value: templates can't be empty") if host.templates.empty?

    @client.post({
      'action' => 'deltemplate',
      'object' => 'host',
      'values' => '%s;%s' % [host.name, host.templates_to_s],
    }.to_json)
  end

  def add_groups(host)
    raise('wrong type: Centreon:Host required') unless host.is_a?(Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    raise("wrong value: groups can't be empty") if host.groups.empty?

    @client.post({
      'action' => 'addhostgroup',
      'object' => 'host',
      'values' => '%s;%s' % [host.name, host.groups_to_s],
    }.to_json)
  end

  def delete_groups(host)
    raise('wrong type: Centreon:Host required') unless host.is_a?(Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    raise("wrong value: groups can't be empty") if host.groups.empty?

    @client.post({
      'action' => 'delhostgroup',
      'object' => 'host',
      'values' => '%s;%s' % [host.name, host.groups_to_s],
    }.to_json)
  end

  def add_macros(host)
    raise('wrong type: Centreon:Host required') unless host.is_a?(Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    raise("wrong value: macros can't be empty") if host.macros.empty?

    host.macros.each do |macro|
      set_macro(host.name, macro)
    end
  end

  def delete_macros(host)
    raise('wrong type: Centreon:Host required') unless host.is_a?(Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    raise("wrong value: macros can't be empty") if host.macros.empty?

    host.macros.each do |macro|
      delete_macro(host.name, macro.name)
    end
  end

  private

  def get_param(name, property)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?

    r = @client.post({
      'action' => 'getparam',
      'object' => 'host',
      'values' => '%s;%s' % [name, property],
    }.to_json)

    JSON.parse(r)['result']
  end

  # Get all host template on given host name
  def get_templates(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    r = @client.post({
      'action' => 'gettemplate',
      'object' => 'host',
      'values' => name,
    }.to_json)

    templates = []
    JSON.parse(r)['result'].each do |data|
      host_template = ::Centreon::HostTemplate.new
      host_template.id = data['id'].to_i
      host_template.name = data['name']
      templates << host_template
    end

    return templates
  end

  # Get all host group on given host name
  def get_groups(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    r = @client.post({
      'action' => 'gethostgroup',
      'object' => 'host',
      'values' => name,
    }.to_json)

    groups = []
    JSON.parse(r)['result'].each do |data|
      host_group = ::Centreon::HostGroup.new
      host_group.id = data['id'].to_i
      host_group.name = data['name']
      groups << host_group
    end

    groups
  end

  # Get all macro on given host name
  def get_macros(name, only_direct = true)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    r = @client.post({
      'action' => 'getmacro',
      'object' => 'host',
      'values' => name,
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

  def delete_macro(name, macro_name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless macro_name.is_a?(String)
    raise('wrong value: nmacro_name must be valid') unless !macro_name.nil? && !macro_name.empty?

    @client.post({
      'action' => 'delmacro',
      'object' => 'host',
      'values' => '%s;%s' % [name, macro_name],
    }.to_json)
  end

  def get_poller(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    r = @client.post({
      'action' => 'showinstance',
      'object' => 'host',
      'values' => name,
    }.to_json)

    JSON.parse(r)['result']
  end

  # Modify list of host param
  def set_param(name, property, value)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required for property') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?
    raise('wrong value: value be valid') if value.nil?

    @client.post({
      'action' => 'setparam',
      'object' => 'host',
      'values' => '%s;%s;%s' % [name, property, value.to_s],
    }.to_json)
  end

  # Modify poller
  def set_poller(name, poller)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless poller.is_a?(String)
    raise('wrong value: poller must be valid') unless !poller.nil? && !poller.empty?

    @client.post({
      'action' => 'setinstance',
      'object' => 'host',
      'values' => '%s;%s' % [name, poller],
    }.to_json)
  end

  # Modify templates
  def set_templates(name, templates)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless templates.is_a?(String)
    raise('wrong value: templates must be valid') unless !templates.nil? && !templates.empty?

    @client.post({
      'action' => 'settemplate',
      'object' => 'host',
      'values' => '%s;%s' % [name, templates],
    }.to_json)
  end

  # Modify groups
  def set_groups(name, groups)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless groups.is_a?(String)
    raise('wrong value: groups must be valid') unless !groups.nil? && !groups.empty?

    @client.post({
      'action' => 'sethostgroup',
      'object' => 'host',
      'values' => '%s;%s' % [name, groups],
    }.to_json)
  end

  # Modify macros
  def set_macro(name, macro)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: Centreon::Macro required') unless macro.is_a?(Centreon::Macro)
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
      'object' => 'host',
      'values' => '%s;%s;%s;%s;%s' % [name, macro.name.upcase, macro.value, password, description],
    }.to_json)
  end

  # Apply host templates
  def apply_template(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'applytpl',
      'object' => 'host',
      'values' => name,
    }.to_json)
  end

  def disable(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'disable',
      'object' => 'host',
      'values' => name,
    }.to_json)
  end

  def enable(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'enable',
      'object' => 'host',
      'values' => name,
    }.to_json)
  end
end
