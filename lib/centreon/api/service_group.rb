require 'rest-client'
require 'json'

require_relative './apiclient.rb'
require_relative '../logger.rb'
require_relative '../service_group.rb'

# Manage the service group API
class Centreon::APIClient::ServiceGroup
  include Logging

  def initialize(client)
    @client = client
  end

  def fetch(name = nil)
    r = if name.nil?
          @client.post({
            'action' => 'show',
            'object' => 'sg',
          }.to_json)
        else
          @client.post({
            'action' => 'show',
            'object' => 'sg',
            'values' => name,
          }.to_json)
        end

    service_groups = []
    JSON.parse(r)['result'].each do |data|
      service_group = Centreon::ServiceGroup.new
      service_group.id = data['id'].to_i
      service_group.name = data['name']
      service_group.description = data['alias']
      service_groups << service_group
    end

    service_groups
  end

  def add(group)
    raise('wrong type: Centreon::ServiceGroup required') unless group.is_a?(::Centreon::ServiceGroup)
    raise('wrong value: service group must be valid') unless group.valid

    @client.post({
      'action' => 'add',
      'object' => 'sg',
      'values' => '%s;%s' % [group.name, group.description],
    }.to_json)

    # Add optional item
    set_param(group.name, 'comment', group.comment) unless group.comment.nil?
    set_param(group.name, 'activate', 0) unless group.activated
  end

  def delete(name)
    raise('wrong type: String required') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?

    @client.post({
      'action' => 'del',
      'object' => 'sg',
      'values' => name,
    }.to_json)
  end

  def update(group, activated = true)
    raise('wrong type: Centreon::ServiceGroup required') unless group.is_a?(::Centreon::ServiceGroup)
    raise('wrong value: service group must be valid') unless group.valid

    set_param(group.name, 'alias', group.description) unless group.description.nil?
    set_param(group.name, 'comment', group.comment) unless group.comment.nil?

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
      'object' => 'sg',
      'values' => '%s;%s;%s' % [name, property, value.to_s],
    }.to_json)
  end
end
