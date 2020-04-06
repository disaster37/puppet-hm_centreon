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
      expect(host.check_command_args).to eq []
      expect(host.snmp_community).to eq nil
      expect(host.snmp_version).to eq nil
      expect(host.timezone).to eq nil
      expect(host.check_command).to eq nil
      expect(host.check_interval).to eq nil
      expect(host.retry_check_interval).to eq nil
      expect(host.max_check_attempts).to eq nil
      expect(host.check_period).to eq nil
      expect(host.active_check).to eq nil
      expect(host.passive_check).to eq nil
      expect(host.note_url).to eq nil
      expect(host.action_url).to eq nil
      expect(host.note).to eq nil
      expect(host.icon_image).to eq nil

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

      host.comment = ''
      expect(host.comment).to eq ''
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

    it 'test set/get snmp_community' do
      host = ::Centreon::Host.new
      host.snmp_community = 'test'
      expect(host.snmp_community).to eq 'test'

      host.snmp_community = ''
      expect(host.snmp_community).to eq ''
    end

    it 'test set/get snmp_version' do
      host = ::Centreon::Host.new
      host.snmp_version = 'test'
      expect(host.snmp_version).to eq 'test'

      host.snmp_version = ''
      expect(host.snmp_version).to eq ''
    end

    it 'test set/get timezone' do
      host = ::Centreon::Host.new
      host.timezone = 'test'
      expect(host.timezone).to eq 'test'

      host.timezone = ''
      expect(host.timezone).to eq ''
    end

    it 'test set/get check_command' do
      host = ::Centreon::Host.new
      host.check_command = 'test'
      expect(host.check_command).to eq 'test'

      host.check_command = ''
      expect(host.check_command).to eq ''
    end

    it 'test set/get check_command_args' do
      host = ::Centreon::Host.new
      host.add_check_command_arg('test')
      expect(host.check_command_args).to eq ['test']
    end

    it 'test set/get check_interval' do
      host = ::Centreon::Host.new
      host.check_interval = 10
      expect(host.check_interval).to eq 10
    end

    it 'test set/get retry_check_interval' do
      host = ::Centreon::Host.new
      host.retry_check_interval = 10
      expect(host.retry_check_interval).to eq 10
    end

    it 'test set/get max_check_attempts' do
      host = ::Centreon::Host.new
      host.max_check_attempts = 10
      expect(host.max_check_attempts).to eq 10
    end

    it 'test set/get check_period' do
      host = ::Centreon::Host.new
      host.check_period = 'test'
      expect(host.check_period).to eq 'test'

      host.check_period = ''
      expect(host.check_period).to eq ''
    end

    it 'test set/get active_check' do
      host = ::Centreon::Host.new
      host.active_check = 'default'
      expect(host.active_check).to eq 'default'
    end

    it 'test set/get passive_check' do
      host = ::Centreon::Host.new
      host.passive_check = 'default'
      expect(host.passive_check).to eq 'default'
    end

    it 'test set/get note_url' do
      host = ::Centreon::Host.new
      host.note_url = 'test'
      expect(host.note_url).to eq 'test'

      host.note_url = ''
      expect(host.note_url).to eq ''
    end

    it 'test set/get action_url' do
      host = ::Centreon::Host.new
      host.action_url = 'test'
      expect(host.action_url).to eq 'test'

      host.action_url = ''
      expect(host.action_url).to eq ''
    end

    it 'test set/get note' do
      host = ::Centreon::Host.new
      host.note = 'test'
      expect(host.note).to eq 'test'

      host.note = ''
      expect(host.note).to eq ''
    end

    it 'test set/get icon_image' do
      host = ::Centreon::Host.new
      host.icon_image = 'test'
      expect(host.icon_image).to eq 'test'

      host.icon_image = ''
      expect(host.icon_image).to eq ''
    end
  end
end
