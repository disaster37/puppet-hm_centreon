require_relative './centreon.rb'
require_relative './logger.rb'
require_relative './service_model.rb'
require_relative './macro.rb'
require_relative './host.rb'
require_relative './service_group.rb'

require 'net/http'

# Service object
class Centreon::Service < Centreon::ServiceModel
  include Logging
  def initialize
    super()
    @host = nil
    @groups = []
  end

  attr_reader :host

  attr_reader :groups

  def host=(host)
    raise('wrong type: Centreon::Host required') unless host.is_a?(::Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    @host = host
    logger.debug('Host: ' + host.to_s)
  end

  def add_group(group)
    raise('wrong type: Centreon::ServiceGroup required') unless group.is_a?(::Centreon::ServiceGroup)
    raise('wrong value: group must be valid') unless group.valid
    @groups << group
    logger.debug('Add group: ' + group.to_s)
  end

  def valid
    !@name.nil? && !@name.empty? && !@host.nil? && !@host.name.nil? && !@host.name.empty?
  end

  def groups_to_s
    if !@groups.empty?
      @groups.map { |service_group| service_group.name }.join('|')
    else
      ''
    end
  end
end
