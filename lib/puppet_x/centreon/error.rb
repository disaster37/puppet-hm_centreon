module PuppetX
  module Centreon
    # We purposefully inherit from Exception here due to PUP-3656
    # If we throw something based on StandardError prior to Puppet 4
    # the exception will prevent the prefetch, but the provider will
    # continue to run with incorrect data.
    class FetchingCentreonDataError < Exception
      def initialize(type, message=nil)
        @message = message
        @type = type
      end

      def to_s
        """Puppet detected a problem with the information returned from Centreon
when looking up #{@type}. The specific error was:
#{@message}
Rather than report on #{@type} resources in an inconsistent state we have exited.
This could be because some other process is modifying Centreon at the same time."""
      end
    end
  end
end