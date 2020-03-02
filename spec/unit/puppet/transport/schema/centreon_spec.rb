require 'spec_helper'
require 'puppet/transport/schema/centreon'

RSpec.describe 'the centreon transport' do
  it 'loads' do
    expect(Puppet::ResourceApi::Transport.list['centreon']).not_to be_nil
  end
end
