require 'spec_helper'
require 'puppet/type/host'

RSpec.describe 'the host type' do
  it 'loads' do
    expect(Puppet::Type.type(:host)).not_to be_nil
  end
end
