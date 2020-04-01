require_relative './service_group.rb'
require_relative './service.rb'
require_relative './host.rb'

RSpec.describe 'Test Centreon::ServiceGroup' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      service_group = ::Centreon::ServiceGroup.new
      expect(service_group.id).to eq nil
      expect(service_group.name).to eq nil
      expect(service_group.description).to eq nil
      expect(service_group.comment).to eq nil
      expect(service_group.activated).to eq false
      expect(service_group.services).to eq []
    end

    it 'test set/get id' do
      service_group = ::Centreon::ServiceGroup.new
      service_group.id = 123_456
      expect(service_group.id).to eq 123_456
    end

    it 'test set/get name' do
      service_group = ::Centreon::ServiceGroup.new
      service_group.name = 'test'
      expect(service_group.name).to eq 'test'
    end

    it 'test set/get description' do
      service_group = ::Centreon::ServiceGroup.new
      service_group.description = 'test'
      expect(service_group.description).to eq 'test'

      service_group.description = ''
      expect(service_group.description).to eq ''
    end
    
    it 'test set/get comment' do
      service_group = ::Centreon::ServiceGroup.new
      service_group.comment = 'test'
      expect(service_group.comment).to eq 'test'

      service_group.comment = ''
      expect(service_group.comment).to eq ''
    end
    
    it 'test set/get activated' do
      service_group = ::Centreon::ServiceGroup.new
      service_group.activated = true
      expect(service_group.activated).to eq true

      service_group.activated = false
      expect(service_group.activated).to eq false
    end

    it 'test valid' do
      service_group = ::Centreon::ServiceGroup.new
      expect(service_group.valid).to eq false

      service_group.name = 'test'
      expect(service_group.valid).to eq true
    end

    it 'test add/get services' do
      service_group = ::Centreon::ServiceGroup.new
      service = ::Centreon::Service.new
      host = ::Centreon::Host.new
      host.name = 'test'
      service.name = 'test'
      service.host = host
      service_group.add_service(service)
      expect(service_group.services).to eq [service]
    end
  end
end
