require 'rest-client'
require 'json'

require_relative './centreon.rb'
require_relative './logger.rb'
require_relative './api/host.rb'
require_relative './api/host_group.rb'
require_relative './api/service.rb'
require_relative './api/host_template.rb'
require_relative './api/service_template.rb'
require_relative './api/service_group.rb'

# API client for Centreon
class Centreon::Client
  include Logging

  # Constructor that initialize rest client with token
  def initialize(url, user = nil, password = nil, use_proxy = false)
    user = ENV['CENTREON_USERNAME'] if user.nil?
    password = ENV['CENTREON_PASSWORD'] if password.nil?

    # Disable proxy
    RestClient.proxy = if use_proxy
                         ENV['http_proxy']
                       else
                         nil
                       end
    RestClient.log = logger

    # Checks parameters
    if url.nil? || url.empty?
      raise('You must provider API URL')
    end
    if user.nil? || user.empty?
      raise('You must provider username to connect on API')
    end
    if password.nil? || password.empty?
      raise('You must provider password to connect on API')
    end

    # Authenticate
    r = ::RestClient::Resource.new(
      url + '?action=authenticate',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE,
    ).post(
      username: user,
      password: password,
    )
    data = JSON.parse(r.body)
    if data['authToken'].empty?
      raise 'Token is empty'
    end

    # Create client
    @client = ::RestClient::Resource.new(
      url + '?action=action&object=centreon_clapi',
      headers: { 'centreon-auth-token' => data['authToken'] },
      verify_ssl: OpenSSL::SSL::VERIFY_NONE,
    )

    @host = Centreon::APIClient::Host.new(@client)
    @host_group = Centreon::APIClient::HostGroup.new(@client)
    @service = Centreon::APIClient::Service.new(@client)
    @host_template = Centreon::APIClient::HostTemplate.new(@client)
    @service_template = Centreon::APIClient::ServiceTemplate.new(@client)
    @service_group = Centreon::APIClient::ServiceGroup.new(@client)
  end

  attr_reader :host

  attr_reader :service

  attr_reader :host_group

  attr_reader :host_template

  attr_reader :service_template

  attr_reader :service_group
end
