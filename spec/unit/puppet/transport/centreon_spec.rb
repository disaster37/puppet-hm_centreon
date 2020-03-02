require 'spec_helper'

require 'puppet/transport/centreon'

RSpec.describe Puppet::Transport::Centreon do
  subject(:transport) { described_class.new(context, connection_info) }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:connection_info) do
    {
      host: 'api.example.com',
      user: 'admin',
      password: 'aih6cu6ohvohpahN',
    }
  end

  before(:each) do
    allow(context).to receive(:debug)
  end

  describe 'initialize(context, connection_info)' do
    it { expect { transport }.not_to raise_error }
  end

  describe 'verify(context)' do
    context 'with valid credentials' do
      it 'returns' do
        expect { transport.verify(context) }.not_to raise_error
      end
    end

    context 'with invalid credentials' do
      let(:connection_info) { super().merge(password: 'invalid') }

      it 'raises an error' do
        expect { transport.verify(context) }.to raise_error RuntimeError, %r{authentication error}
      end
    end
  end

  describe 'facts(context)' do
    let(:facts) { transport.facts(context) }

    it 'returns basic facts' do
      expect(facts).to include(:operatingsystem, :operatingsystemrelease)
    end
  end

  describe 'close(context)' do
    it 'releases resources' do
      transport.close(context)

      expect(transport.instance_variable_get(:@connection_info)).to be_nil
    end
  end
end
