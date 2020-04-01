require_relative '../../centreon/api.rb'
require_relative '../../centreon/logger.rb'

module PuppetX
  module Centreon
    # We purposefully inherit from Exception here due to PUP-3656
    # If we throw something based on StandardError prior to Puppet 4
    # the exception will prevent the prefetch, but the provider will
    # continue to run with incorrect data.
    class FetchingClapiDataError < RuntimeError
      def initialize(url, type, message = nil)
        @message = message
        @url = url
        @type = type
      end

      def to_s
        ''"Puppet detected a problem with the information returned from Centreon
when looking up #{@type} in #{@url}. The specific error was:
#{@message}
Rather than report on #{@type} resources in an inconsistent state we have exited.
This could be because some other process is modifying AWS at the same time."''
      end
    end

    class Client < Puppet::Provider
      initvars

      class << self
        attr_accessor :configs
      end

      def self.client(config_name)
        config = if !configs.nil? && !configs[config_name].nil?
                   configs[config_name]
                 else
                   {}
                 end
        debug = config['debug'] || ENV['CENTREON_DEBUG']
        unless debug
          ::Logging.logger.level = Logger::INFO
        end

        if @client.nil?
          url = config['url'] || ENV['CENTREON_URL']
          username = config['username'] || ENV['CENTREON_USERNAME']
          password = config['password'] || ENV['CENTREON_PASSWORD']
          use_proxy = config['use_proxy'] || false
          raise('You must provide Centreon URL') unless !url.nil? && !url.empty?
          raise('You must provide Centreon username') unless !username.nil? && !username.empty?
          raise('You must provide Centreon password') unless !password.nil? && !password.empty?
          @client = ::Centreon::Client.new(
            url,
            username,
            password,
            use_proxy,
          )
          @hosts = []
          @services = []
        end

        @client
      end

      def client(config_name)
        self.class.client(config_name)
      end
    end
  end
end
