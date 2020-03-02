require 'rest-client'

module centreon
    module clapi
        def initialize(url)
            user = ENV['CENTREON_USERNAME']
            password = ENV['CENTREON_PASSWORD']

            if user.empty? || password.empty?
                raise "You must provide `CENTREON_USERNAME` and `CENTREON_PASSWORD` environment variables"
            end
        end

        def initialize(url, user, password)
            self.class.clapi_client(url, user, password)
        end

        def self.clapi_client(url, user, password)

            if url.empty?
                raise "You must provider API URL"
            end
            if user.empty?
                raise "You must provider username to connect on API"
            end
            if password.empty?
                raise "You must provider password to connect on API"
            end
            r = ::RestClient.post(url, {params: {action: "authenticate"}}, {username: user, password: password})
            data = JSON.parse(r.body)
            if data["authToken"].empty?
                raise "Token is empty"
            end
            @client = ::RestClient::Resource.new(url, {headers: {"centreon-auth-token": data["authToken"]}, {params: {action: "action", object: "centreon_clapi"}}})
        end

        def self.get_hosts()
            r = @client.post({
                "action": "show",
                "object": "host"
            }.to_json)

            JSON.parse(r)
        end
    end
end