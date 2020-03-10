require 'rest-client'
require 'json'

require_relative '../logger.rb'
require_relative '../host.rb'

module Centreon
    module APIClient
        class Service
            include Logging
            
            def initialize(client)
               @client = client 
            end
        
            # Return all hosts in centreon
            def fetch(lazzy = true)
                r = @client.post({
                    "action": "show",
                    "object": "host"
                }.to_json)
    
                hosts = []
                JSON.parse(r)["result"].each do |data|
                
                    host = ::Centreon::Host.new()
                    host.set_id(data['id'].to_i) unless data['id'].nil?
                    host.set_name(data['name']) unless data['name'].nil?
                    
                    # Fix bug
                    if data['alias'].is_a?(Array)
                        data['alias'] = data['alias'].join('|')
                    end
                    
                    host.set_description(data['alias']) unless data['alias'].nil?
                    host.set_address(data['address']) unless data['address'].nil?
                    host.set_is_activated(!data['activate'].to_i.zero?) unless data['activate'].nil?
                   
                    # Load all properties if lazzy is false
                    if !lazzy
                        load(host)
                    end
                       
                    
                    hosts << host
                end
                
                hosts
            end
        end
    end
end