require_relative './helper.rb'
require_relative './host_template.rb'
require_relative './service_template.rb'

RSpec.describe 'Test Centreon::HostTemplate' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      host_template = ::Centreon::HostTemplate.new
      expect(host_template.id).to eq nil
      expect(host_template.name).to eq nil
    end

    it 'test set/get id' do
      host_template = ::Centreon::HostTemplate.new
      host_template.id = 123_456
      expect(host_template.id).to eq 123_456
    end

    it 'test set/get name' do
      host_template = ::Centreon::HostTemplate.new
      host_template.name = 'test'
      expect(host_template.name).to eq 'test'
    end

    it 'test is_valid' do
      host_template = ::Centreon::HostTemplate.new
      expect(host_template.valid).to eq false

      host_template.name = 'test'
      expect(host_template.valid).to eq true
    end

    it 'test add/get service' do
      host = ::Centreon::HostTemplate.new
      service = ::Centreon::ServiceTemplate.new
      service.name = 'test'
      host.add_service(service)
      expect(host.services).to eq [service]
    end
  end
end
