require 'rest-client'
require 'json'

require_relative './logger.rb'
require_relative './host.rb'
require_relative './api/host.rb'

module Centreon
    class Client
        include Logging
        
        # Constructor that get credential from environment variable
        def initialize(url)
            user = ENV['CENTREON_USERNAME']
            password = ENV['CENTREON_PASSWORD']

            if user.empty? || password.empty?
                raise "You must provide `CENTREON_USERNAME` and `CENTREON_PASSWORD` environment variables"
            end
            
            initialize(user, password, url)
        end

        # Constructor that initialize rest client with token
        def initialize(url, user, password)
            
            # Disable proxy
            RestClient.proxy = nil
            RestClient.log = logger
            

            # Checks parameters
            if url.nil? || url.empty?
                raise("You must provider API URL")
            end
            if user.nil? || user.empty?
                raise("You must provider username to connect on API")
            end
            if password.nil? || password.empty?
                raise("You must provider password to connect on API")
            end
            
            # Authenticate
            r  = ::RestClient::Resource.new(
                url + "?action=authenticate",
                :verify_ssl => OpenSSL::SSL::VERIFY_NONE
            ).post(
                {
                    username: user,
                    password: password
                }
            )
            data = JSON.parse(r.body)
            if data["authToken"].empty?
                raise "Token is empty"
            end
            
            # Create client
            @client = ::RestClient::Resource.new(
                url + "?action=action&object=centreon_clapi",
                :headers => {"centreon-auth-token": data["authToken"]},
                :verify_ssl => OpenSSL::SSL::VERIFY_NONE
            )
            
            @host = Centreon::APIClient::Host.new(@client)
        end
        
        def host()
           @host 
        end
       
    end
end