require_relative './centreon.rb'
require_relative './logger.rb'
require_relative './host_model.rb'
require_relative './host_group.rb'
require_relative './host_template.rb'
require_relative './macro.rb'
require_relative './service.rb'

# Host object
class Centreon::Host < Centreon::HostModel
  include Logging
  def initialize
    super()
    @groups = []
    @poller = nil
  end

  attr_reader :poller

  attr_reader :groups

  def poller=(poller)
    raise('wrong type: string required for poller') unless poller.is_a?(String)
    @poller = poller
    logger.debug('Poller: ' + poller)
  end

  def add_group(host_group)
    raise('wrong type: Centreon::HostGroup required') unless host_group.is_a?(::Centreon::HostGroup)
    raise('wrong value: host_group must be valid') unless host_group.valid
    @groups << host_group
    logger.debug('Add host group: ' + host_group.to_s)
  end

  def add_service(service)
    raise('wrong type: Centreon::Service required') unless service.is_a?(::Centreon::Service)
    raise('wrong value: service must be valid') unless !service.name.nil? && !service.name.empty?
    @services << service
    logger.debug('Add service: ' + service.to_s)
  end

  def valid
    !@name.nil? && !@name.empty? && !@address.nil? && !@address.empty? && !@poller.nil? && !@poller.empty?
  end

  def valid_name
    !@name.nil? && !@name.empty?
  end

  def groups_to_s
    if !@groups.empty?
      @groups.map { |host_group| host_group.name }.join('|')
    else
      ''
    end
  end
end
