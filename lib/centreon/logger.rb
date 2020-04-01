require 'logger'

# Logger module
module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= MyLogger.new(STDOUT)
  end

  # Logger class
  class MyLogger < Logger
    def <<(msg)
      debug(msg.strip)
    end
  end
end
