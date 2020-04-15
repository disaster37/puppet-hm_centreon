require_relative './helper.rb'
require_relative './service_model.rb'
require_relative './service_template.rb'

RSpec.describe 'Test Centreon::ServiceTemplate' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      service_template = ::Centreon::ServiceTemplate.new
      expect(service_template.id).to eq nil
      expect(service_template.name).to eq nil
    end

    it 'test set/get id' do
      service_template = ::Centreon::ServiceTemplate.new
      service_template.id = 123_456
      expect(service_template.id).to eq 123_456
    end

    it 'test set/get name' do
      service_template = ::Centreon::ServiceTemplate.new
      service_template.name = 'test'
      expect(service_template.name).to eq 'test'
    end

    it 'test is_valid' do
      service_template = ::Centreon::ServiceTemplate.new
      expect(service_template.valid).to eq false

      service_template.name = 'test'
      expect(service_template.valid).to eq true
    end

    it 'test set/get description' do
      service = ::Centreon::ServiceTemplate.new
      service.description = 'my template'
      expect(service.description).to eq 'my template'

      service.description = ''
      expect(service.description).to eq ''
    end

    it 'test add/get host_template' do
      service = ::Centreon::ServiceTemplate.new
      host_template = ::Centreon::HostTemplate.new
      host_template.name = 'HT1'
      service.add_host_template(host_template)
      expect(service.host_templates).to eq [host_template]
    end
  end
end
