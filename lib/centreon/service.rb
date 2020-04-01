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
  end

  attr_reader :host

  def host=(host)
    raise('wrong type: Centreon::Host required') unless host.is_a?(::Centreon::Host)
    raise('wrong value: host must be valid') unless !host.name.nil? && !host.name.empty?
    @host = host
    logger.debug('Host: ' + host.to_s)
  end

  def valid
    !@name.nil? && !@name.empty? && !@host.nil? && !@host.name.nil? && !@host.name.empty?
  end
end
