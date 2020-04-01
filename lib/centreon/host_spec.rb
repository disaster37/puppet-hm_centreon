require_relative './host.rb'

RSpec.describe 'Test Centreon::Host' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      host = ::Centreon::Host.new
      expect(host.activated).to eq false
      expect(host.id).to eq nil
      expect(host.description).to eq nil
      expect(host.name).to eq nil
      expect(host.address).to eq nil
      expect(host.poller).to eq nil
      expect(host.comment).to eq nil
      expect(host.groups).to eq []
      expect(host.templates).to eq []
      expect(host.macros).to eq []
    end

    it 'test set/get id' do
      host = ::Centreon::Host.new
      host.id = 123_456
      expect(host.id).to eq 123_456
    end

    it 'test set/get activated' do
      host = ::Centreon::Host.new
      host.activated = true
      expect(host.activated).to eq true
    end

    it 'test set/get description' do
      host = ::Centreon::Host.new
      host.description = 'test'
      expect(host.description).to eq 'test'

      host.description = ''
      expect(host.description).to eq ''
    end

    it 'test set/get name' do
      host = ::Centreon::Host.new
      host.name = 'test'
      expect(host.name).to eq 'test'
    end

    it 'test set/get address' do
      host = ::Centreon::Host.new
      host.address = 'test'
      expect(host.address).to eq 'test'
    end

    it 'test set/get poller' do
      host = ::Centreon::Host.new
      host.poller = 'test'
      expect(host.poller).to eq 'test'
    end

    it 'test set/get comment' do
      host = ::Centreon::Host.new
      host.comment = 'test'
      expect(host.comment).to eq 'test'
    end

    it 'test add/get group' do
      host = ::Centreon::Host.new
      expect(host.groups_to_s).to eq ''

      host_group = ::Centreon::HostGroup.new
      host_group.name = 'test'
      host.add_group(host_group)
      expect(host.groups).to eq [host_group]

      host_group2 = ::Centreon::HostGroup.new
      host_group2.name = 'test2'
      host.add_group(host_group2)
      expect(host.groups_to_s).to eq 'test|test2'
    end

    it 'test add/get template' do
      host = ::Centreon::Host.new
      expect(host.templates_to_s).to eq ''

      host_template = ::Centreon::HostTemplate.new
      host_template.name = 'test'
      host.add_template(host_template)
      expect(host.templates).to eq [host_template]

      host_template2 = ::Centreon::HostTemplate.new
      host_template2.name = 'test2'
      host.add_template(host_template2)
      expect(host.templates_to_s).to eq 'test|test2'
    end

    it 'test add/get macro' do
      host = ::Centreon::Host.new
      macro = ::Centreon::Macro.new
      macro.name = 'test'
      macro.value = 'test'
      host.add_macro(macro)
      expect(host.macros).to eq [macro]
    end

    it 'test add/get service' do
      host = ::Centreon::Host.new
      service = ::Centreon::Service.new
      service.name = 'test'
      host.add_service(service)
      expect(host.services).to eq [service]
    end

    it 'test valid' do
      host = ::Centreon::Host.new
      expect(host.valid).to eq false

      host.name = 'test'
      expect(host.valid).to eq false

      host.address = '127.0.0.1'
      expect(host.valid).to eq false

      host.poller = 'poller1'
      expect(host.valid).to eq true
    end

    it 'test is_valid_name' do
      host = ::Centreon::Host.new
      expect(host.valid_name).to eq false

      host.name = 'test'
      expect(host.valid_name).to eq true
    end
  end
end
