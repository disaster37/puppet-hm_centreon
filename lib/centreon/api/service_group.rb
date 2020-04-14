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

  def fetch(name = nil, lazzy = true)
    raise('wrong type: boolean required for lazzy') unless [true, false].include? lazzy
    
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

      load(service_group) unless lazzy

      service_groups << service_group
    end

    return service_groups
  end

  def load(service_group)
    raise('wrong type: Centreon::ServiceGroup required') unless service_group.is_a?(::Centreon::ServiceGroup)
    raise('wrong value: service group must be valid') unless service_group.valid

    get_param(service_group.name, 'comment|activate').each do |data|
      logger.debug('Params: ' + data.to_s)
      service_group.comment = data['comment'] unless data['comment'].nil?
      service_group.activated = !data['activate'].to_i.zero? unless data['activate'].nil?
    end
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

  def get_param(name, property)
    raise('wrong type: String required for name') unless name.is_a?(String)
    raise('wrong value: name must be valid') unless !name.nil? && !name.empty?
    raise('wrong type: String required for property') unless property.is_a?(String)
    raise('wrong value: property must be valid') unless !property.nil? && !property.empty?

    r = @client.post({
      'action' => 'getparam',
      'object' => 'sg',
      'values' => '%s;%s' % [name, property],
    }.to_json)

    return JSON.parse(r)['result']
  end

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
