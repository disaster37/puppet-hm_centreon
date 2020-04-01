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

  def fetch(name = nil)
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
      host_groups << host_group
    end

    host_groups
  end

  def add(group)
    raise('wrong type: Centreon::HostGroup required') unless group.is_a?(::Centreon::HostGroup)
    raise('wrong value: host group must be valid') unless group.valid

    @client.post({
      'action' => 'add',
      'object' => 'hg',
      'values' => '%s;%s' % [group.name, group.description],
    }.to_json)

    # Add optional item
    set_param(group.name, 'comment', group.comment) unless group.comment.nil?
    set_param(group.name, 'notes', group.note) unless group.note.nil?
    set_param(group.name, 'notes_url', group.note_url) unless group.note_url.nil?
    set_param(group.name, 'action_url', group.action_url) unless group.action_url.nil?
    set_param(group.name, 'icon_image', group.icon_image) unless group.icon_image.nil?
    set_param(group.name, 'activate', 1) if group.activated
    set_param(group.name, 'activate', 0) unless group.activated
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

  def update(group, activated = true)
    raise('wrong type: Centreon::HostGroup required') unless group.is_a?(::Centreon::HostGroup)
    raise('wrong value: host group must be valid') unless group.valid

    set_param(group.name, 'alias', group.description) unless group.description.nil?
    set_param(group.name, 'comment', group.comment) unless group.comment.nil?
    set_param(group.name, 'notes', group.note) unless group.note.nil?
    set_param(group.name, 'notes_url', group.note_url) unless group.note_url.nil?
    set_param(group.name, 'action_url', group.action_url) unless group.action_url.nil?
    set_param(group.name, 'icon_image', group.icon_image) unless group.icon_image.nil?

    return unless activated
    set_param(group.name, 'activate', 1) if group.activated
    set_param(group.name, 'activate', 0) unless group.activated
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
end
