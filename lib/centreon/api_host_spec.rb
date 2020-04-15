require_relative './helper.rb'
require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::Host' do
  let(:client) do
    stub_request(:post, 'localhost/centreon/api/index.php?action=authenticate')
      .with(body: {
              username: 'user',
              password: 'pass',
            })
      .to_return(status: 200, body: '
        {
            "authToken": "my_token"
        }
    ')

    Centreon::Client.new('localhost/centreon/api/index.php', 'user', 'pass')
  end

  context 'Test all' do
    it 'Test constructor' do
      expect(client).not_to eq nil
      expect(client.host_template).not_to eq nil
    end

    it 'Test fetch when host' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"host"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "test",
                      "alias": "test app",
                      "address": "127.0.0.1",
                      "activate": "1"
                  }
              ]
          }
      ')

      hosts = client.host.fetch

      expect(hosts.length).to eq 1
      expect(hosts[0]).to have_attributes(
        id: 82,
        name: 'test',
        description: 'test app',
        address: '127.0.0.1',
        activated: true,
      )
    end

    it 'Test fetch when no host' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"host"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      hosts = client.host.fetch

      expect(hosts.length).to eq 0
    end

    it 'Test fetch when no lazzy' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"host"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "test",
                      "alias": "test app",
                      "address": "127.0.0.1",
                      "activate": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettemplate","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "HT_TEST"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gethostgroup","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "HG_TEST"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"showinstance","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "poller1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "warning",
                      "macro value": "10",
                      "is_password": "0",
                      "description": "Threshold warning",
                      "source": "direct"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"host","values":"test;comment|action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone"}') # rubocop:disable LineLength
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "comment": "foo",
                      "snmp_community": "snmp_community",
                      "snmp_version": "3",
                      "timezone": "timezone",
                      "check_command": "check_command",
                      "check_command_arguments": "!arg1!arg2",
                      "check_interval": "10",
                      "retry_check_interval": "1",
                      "max_check_attempts": "3",
                      "check_period": "check_period",
                      "active_checks_enabled": "2",
                      "passive_checks_enabled": "2",
                      "notes_url": "notes_url",
                      "action_url": "action_url",
                      "notes": "notes",
                      "icon_image": "icon_image"
                  }
              ]
          }
      ')

      hosts = client.host.fetch(nil, false)

      expect(hosts.length).to eq 1
      expect(hosts[0]).to have_attributes(
        id: 82,
        name: 'test',
        description: 'test app',
        address: '127.0.0.1',
        activated: true,
        poller: 'poller1',
        comment: 'foo',
        snmp_community: 'snmp_community',
        snmp_version: '3',
        timezone: 'timezone',
        check_command: 'check_command',
        check_command_args: ['arg1', 'arg2'],
        check_interval: 10,
        retry_check_interval: 1,
        max_check_attempts: 3,
        check_period: 'check_period',
        active_checks_enabled: 'default',
        passive_checks_enabled: 'default',
        note_url: 'notes_url',
        action_url: 'action_url',
        note: 'notes',
        icon_image: 'icon_image',
      )

      expect(hosts[0].templates.length).to eq 1
      expect(hosts[0].templates[0]).to have_attributes(
        id: 1,
        name: 'HT_TEST',
      )

      expect(hosts[0].groups.length).to eq 1
      expect(hosts[0].groups[0]).to have_attributes(
        id: 1,
        name: 'HG_TEST',
      )

      expect(hosts[0].macros.length).to eq 1
      expect(hosts[0].macros[0]).to have_attributes(
        name: 'warning',
        value: '10',
        password: false,
        description: 'Threshold warning',
      )
    end

    it 'Test get when host found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "test",
                      "alias": "test app",
                      "address": "127.0.0.1",
                      "activate": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettemplate","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "HT_TEST"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gethostgroup","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "HG_TEST"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"showinstance","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "poller1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "warning",
                      "macro value": "10",
                      "is_password": "0",
                      "description": "Threshold warning",
                      "source": "direct"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"host","values":"test;comment|action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone"}') # rubocop:disable LineLength
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "comment": "foo",
                      "snmp_community": "snmp_community",
                      "snmp_version": "3",
                      "timezone": "timezone",
                      "check_command": "check_command",
                      "check_command_arguments": "!arg1!arg2",
                      "check_interval": "10",
                      "retry_check_interval": "1",
                      "max_check_attempts": "3",
                      "check_period": "check_period",
                      "active_checks_enabled": "2",
                      "passive_checks_enabled": "2",
                      "notes_url": "notes_url",
                      "action_url": "action_url",
                      "notes": "notes",
                      "icon_image": "icon_image"
                  }
              ]
          }
      ')

      host = client.host.get('test', false)

      expect(host).to have_attributes(
        id: 82,
        name: 'test',
        description: 'test app',
        address: '127.0.0.1',
        activated: true,
        poller: 'poller1',
        comment: 'foo',
        snmp_community: 'snmp_community',
        snmp_version: '3',
        timezone: 'timezone',
        check_command: 'check_command',
        check_command_args: ['arg1', 'arg2'],
        check_interval: 10,
        retry_check_interval: 1,
        max_check_attempts: 3,
        check_period: 'check_period',
        active_checks_enabled: 'default',
        passive_checks_enabled: 'default',
        note_url: 'notes_url',
        action_url: 'action_url',
        note: 'notes',
        icon_image: 'icon_image',
      )

      expect(host.templates.length).to eq 1
      expect(host.templates[0]).to have_attributes(
        id: 1,
        name: 'HT_TEST',
      )

      expect(host.groups.length).to eq 1
      expect(host.groups[0]).to have_attributes(
        id: 1,
        name: 'HG_TEST',
      )

      expect(host.macros.length).to eq 1
      expect(host.macros[0]).to have_attributes(
        name: 'warning',
        value: '10',
        password: false,
        description: 'Threshold warning',
      )
    end

    it 'Test get when host not found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      host = client.host.get('test')

      expect(host).to eq nil
    end

    it 'Test load when host found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettemplate","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "HT_TEST"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gethostgroup","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "HG_TEST"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"showinstance","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "1",
                      "name": "poller1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "warning",
                      "macro value": "10",
                      "is_password": "0",
                      "description": "Threshold warning",
                      "source": "direct"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"host","values":"test;comment|action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone"}') # rubocop:disable LineLength
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "comment": "foo",
                      "snmp_community": "snmp_community",
                      "snmp_version": "3",
                      "timezone": "timezone",
                      "check_command": "check_command",
                      "check_command_arguments": "!arg1!arg2",
                      "check_interval": "10",
                      "retry_check_interval": "1",
                      "max_check_attempts": "3",
                      "check_period": "check_period",
                      "active_checks_enabled": "2",
                      "passive_checks_enabled": "2",
                      "notes_url": "notes_url",
                      "action_url": "action_url",
                      "notes": "notes",
                      "icon_image": "icon_image"
                  }
              ]
          }
      ')
      host = Centreon::Host.new
      host.id = 82
      host.name = 'test'
      host.address = '127.0.0.1'

      client.host.load(host)

      expect(host).to have_attributes(
        id: 82,
        name: 'test',
        address: '127.0.0.1',
        poller: 'poller1',
        comment: 'foo',
        snmp_community: 'snmp_community',
        snmp_version: '3',
        timezone: 'timezone',
        check_command: 'check_command',
        check_command_args: ['arg1', 'arg2'],
        check_interval: 10,
        retry_check_interval: 1,
        max_check_attempts: 3,
        check_period: 'check_period',
        active_checks_enabled: 'default',
        passive_checks_enabled: 'default',
        note_url: 'notes_url',
        action_url: 'action_url',
        note: 'notes',
        icon_image: 'icon_image',
      )

      expect(host.templates.length).to eq 1
      expect(host.templates[0]).to have_attributes(
        id: 1,
        name: 'HT_TEST',
      )

      expect(host.groups.length).to eq 1
      expect(host.groups[0]).to have_attributes(
        id: 1,
        name: 'HG_TEST',
      )

      expect(host.macros.length).to eq 1
      expect(host.macros[0]).to have_attributes(
        name: 'warning',
        value: '10',
        password: false,
        description: 'Threshold warning',
      )
    end

    it 'Test add host' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"host","values":"test;my description;127.0.0.1;HT1|HT2;poller1;HG1|HG2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_command;ping"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_command_arguments;!arg1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;action_url;http://127.0.0.1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;active_checks_enabled;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_interval;10"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_period;none"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;icon_image;image"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;notes;note"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;notes_url;http://localhost"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;passive_checks_enabled;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;snmp_community;public"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;snmp_version;2c"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;timezone;Europe/Paris"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;foo;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"applytpl","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      host.description = 'my description'
      host.comment = 'foo'
      host.address = '127.0.0.1'
      host.poller = 'poller1'
      hg1 = Centreon::HostGroup.new
      hg1.name = 'HG1'
      host.add_group(hg1)
      hg2 = Centreon::HostGroup.new
      hg2.name = 'HG2'
      host.add_group(hg2)
      ht1 = Centreon::HostTemplate.new
      ht1.name = 'HT1'
      host.add_template(ht1)
      ht2 = Centreon::HostTemplate.new
      ht2.name = 'HT2'
      host.add_template(ht2)
      macro1 = Centreon::Macro.new
      macro1.name = 'macro1'
      macro1.value = 'foo'
      host.add_macro(macro1)
      host.activated = true
      host.check_command = 'ping'
      host.add_check_command_arg('arg1')
      host.note = 'note'
      host.note_url = 'http://localhost'
      host.action_url = 'http://127.0.0.1'
      host.icon_image = 'image'
      host.snmp_community = 'public'
      host.snmp_version = '2c'
      host.timezone = 'Europe/Paris'
      host.check_interval = 10
      host.retry_check_interval = 1
      host.max_check_attempts = 3
      host.check_period = 'none'
      host.active_checks_enabled = 'true'
      host.passive_checks_enabled = 'true'
      client.host.add(host)
    end

    it 'Test update host' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;alias;my description"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_command;ping"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_command_arguments;!arg1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;action_url;http://127.0.0.1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;active_checks_enabled;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_interval;10"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;check_period;none"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;icon_image;image"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;notes;note"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;notes_url;http://localhost"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;passive_checks_enabled;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;snmp_community;public"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;snmp_version;2c"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"host","values":"test;timezone;Europe/Paris"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;foo;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"disable","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setinstance","object":"host","values":"test;poller1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;value;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"settemplate","object":"host","values":"test;HT1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"sethostgroup","object":"host","values":"test;HG1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"applytpl","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "old",
                      "macro value": "foo",
                      "is_password": "0",
                      "description": ""
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;foo;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"delmacro","object":"host","values":"test;old"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      host.poller = 'poller1'
      host.description = 'my description'
      host.comment = 'foo'
      host_group = Centreon::HostGroup.new
      host_group.name = 'HG1'
      host.add_group(host_group)
      host_template = Centreon::HostTemplate.new
      host_template.name = 'HT1'
      host.add_template(host_template)
      macro1 = Centreon::Macro.new
      macro1.name = 'macro1'
      macro1.value = 'foo'
      host.add_macro(macro1)
      host.check_command = 'ping'
      host.add_check_command_arg('arg1')
      host.note = 'note'
      host.note_url = 'http://localhost'
      host.action_url = 'http://127.0.0.1'
      host.icon_image = 'image'
      host.snmp_community = 'public'
      host.snmp_version = '2c'
      host.timezone = 'Europe/Paris'
      host.check_interval = 10
      host.retry_check_interval = 1
      host.max_check_attempts = 3
      host.check_period = 'none'
      host.active_checks_enabled = 'true'
      host.passive_checks_enabled = 'true'

      client.host.update(host)
    end

    it 'Test delete host' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"host","values":"test"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.host.delete('test')
    end

    it 'Test add_templates' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"addtemplate","object":"host","values":"test;HT1|HT2"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      host_template1 = Centreon::HostTemplate.new
      host_template1.name = 'HT1'
      host.add_template(host_template1)
      host_template2 = Centreon::HostTemplate.new
      host_template2.name = 'HT2'
      host.add_template(host_template2)

      client.host.add_templates(host)
    end

    it 'Test delete_templates' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"deltemplate","object":"host","values":"test;HT1|HT2"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      host_template1 = Centreon::HostTemplate.new
      host_template1.name = 'HT1'
      host.add_template(host_template1)
      host_template2 = Centreon::HostTemplate.new
      host_template2.name = 'HT2'
      host.add_template(host_template2)

      client.host.delete_templates(host)
    end

    it 'Test add_groups' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"addhostgroup","object":"host","values":"test;HG1|HG2"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      host_group1 = Centreon::HostGroup.new
      host_group1.name = 'HG1'
      host.add_group(host_group1)
      host_group2 = Centreon::HostGroup.new
      host_group2.name = 'HG2'
      host.add_group(host_group2)

      client.host.add_groups(host)
    end

    it 'Test delete_groups' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"delhostgroup","object":"host","values":"test;HG1|HG2"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      host_group1 = Centreon::HostGroup.new
      host_group1.name = 'HG1'
      host.add_group(host_group1)
      host_group2 = Centreon::HostGroup.new
      host_group2.name = 'HG2'
      host.add_group(host_group2)

      client.host.delete_groups(host)
    end

    it 'Test add_macros' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;value;0;my macro"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      macro = Centreon::Macro.new
      macro.name = 'MACRO1'
      macro.value = 'value'
      macro.description = 'my macro'
      macro.password = false
      host.add_macro(macro)

      client.host.add_macros(host)
    end

    it 'Test delete_macros' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"delmacro","object":"host","values":"test;MACRO1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      macro = Centreon::Macro.new
      macro.name = 'MACRO1'
      macro.value = 'value'
      macro.description = 'my macro'
      macro.password = false
      host.add_macro(macro)

      client.host.delete_macros(host)
    end
  end
end
