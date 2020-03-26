require_relative '../../centreon/api.rb'
require_relative '../../centreon/logger.rb'

module Hm
  module Centreon
    # We purposefully inherit from Exception here due to PUP-3656
    # If we throw something based on StandardError prior to Puppet 4
    # the exception will prevent the prefetch, but the provider will
    # continue to run with incorrect data.
    class FetchingClapiDataError < Exception
      def initialize(url, type, message=nil)
        @message = message
        @url = url
        @type = type
      end

      def to_s
        """Puppet detected a problem with the information returned from Centreon
when looking up #{@type} in #{@url}. The specific error was:
#{@message}
Rather than report on #{@type} resources in an inconsistent state we have exited.
This could be because some other process is modifying AWS at the same time."""
      end
    end

    class Client < Puppet::Provider
      
      initvars
      
      class << self
        attr_accessor :url
        attr_accessor :username
        attr_accessor :password
        attr_accessor :debug
      end

      def self.client()
        if !debug()
          ::Logging.logger.level = Logger::INFO
        end
        
        if @client.nil?
          raise("You must provide Centreon URL") unless !url().nil? && !url().empty?
          raise("You must provide Centreon username") unless !username().nil? && !username().empty?
          raise("You must provide Centreon password") unless !password().nil? && !password().empty?
            @client = ::Centreon::Client.new(
                url(),
                username(),
                password()
            )
            @hosts = []
            @services = []
        end
        
        return @client
      end
      
      def client()
        return self.class.client()
      end
      
    end
  end
end