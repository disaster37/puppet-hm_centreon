require 'puppet/resource_api/transport/wrapper'

# Initialize the NetworkDevice module if necessary
module Puppet::Util::NetworkDevice; end

# The Centreon module only contains the Device class to bridge from puppet's internals to the Transport.
# All the heavy lifting is done bye the Puppet::ResourceApi::Transport::Wrapper
module Puppet::Util::NetworkDevice::Centreon # rubocop:disable Style/ClassAndModuleCamelCase
  # Bridging from puppet to the centreon transport
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def initialize(url_or_config, _options = {})
      super('centreon', url_or_config)
    end
  end
end
