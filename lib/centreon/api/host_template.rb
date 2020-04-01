require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../host_template.rb'

# Manage Host Template API
class Centreon::APIClient::HostTemplate
  include Logging

  def initialize(client)
    @client = client
  end

  # Return all hosts templates from centreon
  def fetch(name = nil, lazzy = true)
    host_templates = []
    show(name).each do |data|
      host_template = ::Centreon::HostTemplate.new
      host_template.id = data['id'].to_i unless data['id'].nil?
      host_template.name = data['name'] unless data['name'].nil?

      # Fix bug
      if data['alias'].is_a?(Array)
        data['alias'] = data['alias'].join('|')
      end

      host_template.description = data['alias'] unless data['alias'].nil?
      host_template.address = data['address'] unless data['address'].nil?
      host_template.activated = !data['activate'].to_i.zero? unless data['activate'].nil?

      # Load all properties if lazzy is false
      load(host_template) unless lazzy

      host_templates << host_template
    end

    host_templates
  end

  # Load additional data for given host template
  def load(host_template)
    raise('wrong type: Centreon::HostTemplate required') unless host_template.is_a?(::Centreon::HostTemplate)
    raise('wrong value: host must be valid') unless !host_template.name.nil? && !host_template.name.empty?

    # Load host_templates
    get_templates(host_template.name).each do |ht|
      host_template.add_template(ht)
    end

    # Load macros
    get_macros(host_template.name).each do |macro|
      host_template.add_macro(macro)
    end

    # Load extra params
    # BUG centreon: the field comment can't be call from API, only clapi
    # get_param(host_template.name "comment").each do |data|
    #    host_template.comment = data["comment"] unless data["comment"].nil?
    # end
  end

  # Get one host template from monitoring
  def get(name, lazzy = true)
    # Search if host exist
    host_templates = fetch(name, lazzy)

    unless host_templates.empty?
      return host_templates[0]
    end

    nil
  end

  # Create new host template on monitoring
  def add(host_template)
    raise('wrong type: Centreon::HostTemplate required') unless host_template.is_a?(::Centreon::HostTemplate)
    raise('wrong value: host template must be valid') unless host_template.valid
    @client.post({
      'action' => 'add',
      'object' => 'htpl',
      'values' => '%s;%s;%s;%s;;' % [host_template.name, host_template.description, host_template.address, host_template.templates_to_s],
    }.to_json)

    # Set extra parameters
    set_param(host_template.name, 'comment', host_template.comment) unless host_template.comment.nil?

    # Disable it if needed
    disable(host_template.name) unless host_template.activated

    # Set macros
    host_template.macros.each do |macro|
      set_macro(host_template.name, macro)
    end
  end

  # Update host template on centreon
  def update(host_template, templates = true, macros = true, activated = true)
    raise('wrong type: Centreon::HostTemplate required') unless host_template.is_a?(::Centreon::HostTemplate)
    raise('wrong value: host template must be valid') unless host_template.valid

    set_param(host_template.name, 'alias', host_template.description) unless host_template.description.nil?
    set_param(host_template.name, 'address', host_template.address) unless host_template.address.nil?
    set_param(host_template.name, 'comment', host_template.comment) unless host_template.comment.nil?
    if activated
      enable(host_template.name) if host_template.activated
      disable(host_template.name) unless host_template.activated
    end

    if templates
      # Set templates if needed or remove all templates
      if host_template.templates.empty?
        host_template_tmp = Centreon::HostTemplate.new
        host_template_tmp.name = host_template.name
        get_templates(host_template.name).each do |ht|
          host_template_tmp.add_template(ht)
        end
        delete_templates(host_template_tmp)
      elsif templates
        set_templates(host_template.name, host_template.templates_to_s)
      end
    end

    return unless macros
    current_macros = get_macros(host_template.name)
    host_template.macros.each do |macro|
      is_already_exist = false
      current_macros.each do |current_macro|
        next unless current_macro.name == macro.name
        unless macro.compare(current_macro)
          set_macro(host_template.name, macro)
          break
        end
        is_already_exist = true
        current_macros.delete(current_macro)
        break
      end

      unless is_already_exist
        set_macro(host_template.name, macro)
      end
    end

    # Remove old macros
    current_macros.each do |current_macro|
      delete_macro(host_template.name, current_macro.name)
    end
  end

  # Delete host template on Centreon
  def delete(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'htpl',
      'values' => name,
    }.to_json)
  end

  # Add host templates in host template on Centreon
  def add_templates(host_template)
    raise('wrong type: Centreon:HostTemplate required') unless host_template.is_a?(Centreon::HostTemplate)
    raise('wrong value: host template must be valid') unless !host_template.name.nil? && !host_template.name.empty?
    raise("wrong value: templates can't be empty") if host_template.templates.empty?

    @client.post({
      'action' => 'addtemplate',
      'object' => 'htpl',
      'values' => '%s;%s' % [host_template.name, host_template.templates_to_s],
    }.to_json)
  end

  # Delete host template in host template on Centreon
  def delete_templates(host_template)
    raise('wrong type: Centreon:HostTemplate required') unless host_template.is_a?(Centreon::HostTemplate)
    raise('wrong value: host template must be valid') unless !host_template.name.nil? && !host_template.name.empty?
    raise("wrong value: templates can't be empty") if host_template.templates.empty?

    @client.post({
      'action' => 'deltemplate',
      'object' => 'htpl',
      'values' => '%s;%s' % [host_template.name, host_template.templates_to_s],
    }.to_json)
  end

  # Add macro in host template on Centreon
  def add_macros(host_template)
    raise('wrong type: Centreon:HostTemplate required') unless host_template.is_a?(Centreon::HostTemplate)
    raise('wrong value: host template must be valid') unless !host_template.name.nil? && !host_template.name.empty?
    raise("wrong value: macros can't be empty") if host_template.macros.empty?

    host_template.macros.each do |macro|
      set_macro(host_template.name, macro)
    end
  end

  # Delete macro in host template on Centreon
  def delete_macros(host_template)
    raise('wrong type: Centreon:HostTemplate required') unless host_template.is_a?(Centreon::HostTemplate)
    raise('wrong value: host template must be valid') unless !host_template.name.nil? && !host_template.name.empty?
    raise("wrong value: macros can't be empty") if host_template.macros.empty?

    host_template.macros.each do |macro|
      delete_macro(host_template.name, macro.name)
    end
  end

  private

  # Show host templates
  def show(name = nil)
    r = if name.nil?
          @client.post({
            'action' => 'show',
            'object' => 'htpl',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'htpl',
            'values' => name,
          }.to_json)
        end

    JSON.parse(r)['result']
  end

  # Get param for host template from Centreon
  def get_param(name, property)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?

    r = @client.post({
      'action' => 'getparam',
      'object' => 'htpl',
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
      'object' => 'htpl',
      'values' => name,
    }.to_json)

    templates = []
    JSON.parse(r)['result'].each do |data|
      host_template = ::Centreon::HostTemplate.new
      host_template.id = data['id'].to_i
      host_template.name = data['name']
      templates << host_template
    end

    templates
  end

  # Get all macro on given host name
  def get_macros(name, only_direct = true)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    r = @client.post({
      'action' => 'getmacro',
      'object' => 'htpl',
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

  # Delete macro in host template
  def delete_macro(name, macro_name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless macro_name.is_a?(String)
    raise('wrong value: nmacro_name must be valid') unless !macro_name.nil? && !macro_name.empty?
    @client.post({
      'action' => 'delmacro',
      'object' => 'htpl',
      'values' => '%s;%s' % [name, macro_name],
    }.to_json)
  end

  # set param for host template
  def set_param(name, property, value)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required for property') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?
    raise('wrong value: value be valid') if value.nil?

    @client.post({
      'action' => 'setparam',
      'object' => 'htpl',
      'values' => '%s;%s;%s' % [name, property, value.to_s],
    }.to_json)
  end

  # Set hosts templates for host templates
  def set_templates(name, templates)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required') unless templates.is_a?(String)
    raise('wrong value: templates must be valid') unless !templates.nil? && !templates.empty?

    @client.post({
      'action' => 'settemplate',
      'object' => 'htpl',
      'values' => '%s;%s' % [name, templates],
    }.to_json)
  end

  # Set macro for host template
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
      'object' => 'htpl',
      'values' => '%s;%s;%s;%s;%s' % [name, macro.name.upcase, macro.value, password, description],
    }.to_json)
  end

  # Disable host template
  def disable(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'disable',
      'object' => 'htpl',
      'values' => name,
    }.to_json)
  end

  # Enable host template
  def enable(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'enable',
      'object' => 'htpl',
      'values' => name,
    }.to_json)
  end
end
