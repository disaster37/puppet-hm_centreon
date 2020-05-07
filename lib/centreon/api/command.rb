require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../command.rb'

# Manage the command API
class Centreon::APIClient::Command
  include Logging

  def initialize(client)
    @client = client
  end

  def fetch(name = nil, lazzy = true)
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy

    r = if name.nil?
          @client.post({
            'action' => 'show',
            'object' => 'cmd',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'cmd',
            'values' => name,
          }.to_json)
        end

    commands = []
    JSON.parse(r)['result'].each do |data|
      command = Centreon::Command.new
      command.id = data['id'].to_i
      command.name = data['name']
      command.type = data['type']
      command.line = data['line']

      load(command) unless lazzy

      commands << command
    end

    commands
  end

  def load(command)
    raise('wrong type: Centreon::Command required') unless command.is_a?(::Centreon::Command)
    raise('wrong value: command must be valid') unless command.valid

    get_param(command.name, 'graph|example|comment|activate|enable_shell').each do |data|
      logger.debug('Params: ' + data.to_s)
      command.comment = data['comment'] unless data['comment'].nil?
      command.graph = data['graph'] unless data['graph'].nil?
      command.example = data['example'] unless data['example'].nil?
      command.activated = !data['activate'].to_i.zero? unless data['activate'].nil?
      command.enable_shell = !data['enable_shell'].to_i.zero? unless data['enable_shell'].nil?
    end
  end

  def add(command)
    raise('wrong type: Centreon::Command required') unless command.is_a?(::Centreon::Command)
    raise('wrong value: command must be valid') unless command.valid

    @client.post({
      'action' => 'add',
      'object' => 'cmd',
      'values' => '%s;%s;%s' % [command.name, command.type, command.line],
    }.to_json)

    # Add optional item
    set_param(command.name, 'comment', command.comment) unless command.comment.nil?
    set_param(command.name, 'graph', command.graph) unless command.graph.nil?
    set_param(command.name, 'example', command.example) unless command.example.nil?
    set_param(command.name, 'activate', 0) unless command.activated
    set_param(command.name, 'activate', 1) if command.activated
    set_param(command.name, 'enable_shell', 0) unless command.enable_shell
    set_param(command.name, 'enable_shell', 1) if command.enable_shell
  end

  def delete(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'cmd',
      'values' => name,
    }.to_json)
  end

  def update(command, activated = true, enable_shell = true)
    raise('wrong type: Centreon::Command required') unless command.is_a?(::Centreon::Command)
    raise('wrong value: command must be valid') unless command.valid

    set_param(command.name, 'line', command.line) unless command.line.nil?
    set_param(command.name, 'comment', command.comment) unless command.comment.nil?
    set_param(command.name, 'type', command.type) unless command.type.nil?
    set_param(command.name, 'graph', command.graph) unless command.graph.nil?
    set_param(command.name, 'example', command.example) unless command.example.nil?

    if activated
      set_param(command.name, 'activate', 0) unless command.activated
      set_param(command.name, 'activate', 1) if command.activated
    end

    return unless enable_shell
    set_param(command.name, 'enable_shell', 0) unless command.enable_shell
    set_param(command.name, 'enable_shell', 1) if command.enable_shell
  end

  private

  def set_param(name, property, value)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required for property') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?
    raise('wrong value: value be valid') if value.nil?

    @client.post({
      'action' => 'setparam',
      'object' => 'cmd',
      'values' => '%s;%s;%s' % [name, property, value.to_s],
    }.to_json)
  end

  def get_param(name, property)
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required for property') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?

    r = @client.post({
      'action' => 'getparam',
      'object' => 'cmd',
      'values' => '%s;%s' % [name, property],
    }.to_json)

    JSON.parse(r)['result']
  end
end
