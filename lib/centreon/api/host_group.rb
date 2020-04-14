require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../host_group.rb'

# Manage the host group API
class Centreon::APIClient::HostGroup
  include Logging

  def initialize(client)
    @client = client
  end

  def fetch(name = nil, lazzy = true)
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy

    r = if name.nil?
          @client.post({
            'action' => 'show',
            'object' => 'hg',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'hg',
            'values' => name,
          }.to_json)
        end

    host_groups = []
    JSON.parse(r)['result'].each do |data|
      host_group = Centreon::HostGroup.new
      host_group.id = data['id'].to_i
      host_group.name = data['name']
      host_group.description = data['alias']

      load(host_group) unless lazzy

      host_groups << host_group
    end

    return host_groups
  end

  def load(host_group)
    raise('wrong type: Centreon::HostGroup required') unless host_group.is_a?(::Centreon::HostGroup)
    raise('wrong value: host_group must be valid') unless host_group.valid

    get_param(host_group.name, 'comment|activate|notes|notes_url|action_url|icon_image').each do |data|
      logger.debug('Params: ' + data.to_s)
      host_group.comment = data['comment'] unless data['comment'].nil?
      host_group.activated = !data['activate'].to_i.zero? unless data['activate'].nil?
      host_group.note = data['notes'] unless data['notes'].nil?
      host_group.note_url = data['notes_url'] unless data['notes_url'].nil?
      host_group.action_url = data['action_url'] unless data['action_url'].nil?
      host_group.icon_image = data['icon_image'] unless data['icon_image'].nil?
    end
  end

  def add(host_group)
    raise('wrong type: Centreon::HostGroup required') unless host_group.is_a?(::Centreon::HostGroup)
    raise('wrong value: host group must be valid') unless host_group.valid

    @client.post({
      'action' => 'add',
      'object' => 'hg',
      'values' => '%s;%s' % [host_group.name, host_group.description],
    }.to_json)

    # Add optional item
    set_param(host_group.name, 'comment', host_group.comment) unless host_group.comment.nil?
    set_param(host_group.name, 'notes', host_group.note) unless host_group.note.nil?
    set_param(host_group.name, 'notes_url', host_group.note_url) unless host_group.note_url.nil?
    set_param(host_group.name, 'action_url', host_group.action_url) unless host_group.action_url.nil?
    set_param(host_group.name, 'icon_image', host_group.icon_image) unless host_group.icon_image.nil?
    set_param(host_group.name, 'activate', 0) unless host_group.activated
  end

  def delete(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'hg',
      'values' => name,
    }.to_json)
  end

  def update(host_group, activated = true)
    raise('wrong type: Centreon::HostGroup required') unless host_group.is_a?(::Centreon::HostGroup)
    raise('wrong value: host group must be valid') unless host_group.valid

    set_param(host_group.name, 'alias', host_group.description) unless host_group.description.nil?
    set_param(host_group.name, 'comment', host_group.comment) unless host_group.comment.nil?
    set_param(host_group.name, 'notes', host_group.note) unless host_group.note.nil?
    set_param(host_group.name, 'notes_url', host_group.note_url) unless host_group.note_url.nil?
    set_param(host_group.name, 'action_url', host_group.action_url) unless host_group.action_url.nil?
    set_param(host_group.name, 'icon_image', host_group.icon_image) unless host_group.icon_image.nil?

    return unless activated
    set_param(host_group.name, 'activate', 1) if host_group.activated
    set_param(host_group.name, 'activate', 0) unless host_group.activated
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
      'object' => 'hg',
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
      'object' => 'hg',
      'values' => '%s;%s' % [name, property],
    }.to_json)

    return JSON.parse(r)['result']
  end
end
