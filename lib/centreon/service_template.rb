require_relative './centreon.rb'
require_relative './logger.rb'
require_relative './service_model.rb'
require_relative './macro.rb'
require_relative './host.rb'
require_relative './service_group.rb'

require 'net/http'

# Service template object
class Centreon::ServiceTemplate < Centreon::ServiceModel
  include Logging
  def initialize
    super()
    @description = nil
    @host_templates = []
  end

  attr_reader :description

  attr_reader :host_templates

  def description=(value)
    raise('wrong type: String required') unless value.is_a?(String)
    @description = value
    logger.debug('Description: ' + value)
  end

  def add_host_template(host_template)
    raise('wrong type: Centreon::HostTemplate required') unless host_template.is_a?(::Centreon::HostTemplate)
    raise('wrong value: host_template must be valid') unless host_template.valid
    @host_templates << host_template
    logger.debug('Add host template: ' + host_template.to_s)
  end

  def host_templates_to_s
    if !@host_templates.empty?
      @host_templates.map { |host_template| host_template.name }.join('|')
    else
      ''
    end
  end

  def valid
    !@name.nil? && !@name.empty?
  end
end
