require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::HostTemplate' do
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
      expect(client.host).not_to eq nil
    end

    it 'Test fetch when host template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"htpl"}')
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

      host_templates = client.host_template.fetch

      expect(host_templates.length).to eq 1
      expect(host_templates[0]).to have_attributes(
        id: 82,
        name: 'test',
        description: 'test app',
        address: '127.0.0.1',
        activated: true,
      )
    end

    it 'Test fetch when no host template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"htpl"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      host_templates = client.host_template.fetch

      expect(host_templates.length).to eq 0
    end

    it 'Test fetch when no lazzy' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"htpl"}')
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
        .with(body: '{"action":"gettemplate","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"getmacro","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"getparam","object":"htpl","values":"test;action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "comment": "comment",
                      "snmp_community": "snmp_community",
                      "snmp_version": "3",
                      "timezone": "timezone",
                      "check_command": "check_command",
                      "check_command_args": "!arg1!arg2",
                      "check_interval": "10",
                      "retry_check_interval": "1",
                      "max_check_attempts": "3",
                      "check_period": "check_period",
                      "active_check": "2",
                      "passive_check": "2",
                      "notes_url": "notes_url",
                      "action_url": "action_url",
                      "notes": "notes",
                      "icon_image": "icon_image"

                  }
              ]
          }
      ')

      host_templates = client.host_template.fetch(nil, false)

      expect(host_templates.length).to eq 1
      expect(host_templates[0]).to have_attributes(
        id: 82,
        name: 'test',
        description: 'test app',
        address: '127.0.0.1',
        activated: true,
        comment: 'comment',
        snmp_community: 'snmp_community',
        snmp_version: '3',
        timezone: 'timezone',
        check_command: 'check_command',
        check_command_args: ['arg1', 'arg2'],
        check_interval: 10,
        retry_check_interval: 1,
        max_check_attempts: 3,
        check_period: 'check_period',
        active_check: 'default',
        passive_check: 'default',
        note_url: 'notes_url',
        action_url: 'action_url',
        note: 'notes',
        icon_image: 'icon_image'
      )

      expect(host_templates[0].templates.length).to eq 1
      expect(host_templates[0].templates[0]).to have_attributes(
        id: 1,
        name: 'HT_TEST',
      )

      expect(host_templates[0].macros.length).to eq 1
      expect(host_templates[0].macros[0]).to have_attributes(
        name: 'warning',
        value: '10',
        password: false,
        description: 'Threshold warning',
      )
    end

    it 'Test get when host template found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"gettemplate","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"getmacro","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"getparam","object":"htpl","values":"test;action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "comment": "comment",
                      "snmp_community": "snmp_community",
                      "snmp_version": "3",
                      "timezone": "timezone",
                      "check_command": "check_command",
                      "check_command_args": "!arg1!arg2",
                      "check_interval": "10",
                      "retry_check_interval": "1",
                      "max_check_attempts": "3",
                      "check_period": "check_period",
                      "active_check": "2",
                      "passive_check": "2",
                      "notes_url": "notes_url",
                      "action_url": "action_url",
                      "notes": "notes",
                      "icon_image": "icon_image"

                  }
              ]
          }
      ')

      host_template = client.host_template.get('test', false)

      expect(host_template).to have_attributes(
        id: 82,
        name: 'test',
        description: 'test app',
        address: '127.0.0.1',
        activated: true,
        comment: 'comment',
        snmp_community: 'snmp_community',
        snmp_version: '3',
        timezone: 'timezone',
        check_command: 'check_command',
        check_command_args: ['arg1', 'arg2'],
        check_interval: 10,
        retry_check_interval: 1,
        max_check_attempts: 3,
        check_period: 'check_period',
        active_check: 'default',
        passive_check: 'default',
        note_url: 'notes_url',
        action_url: 'action_url',
        note: 'notes',
        icon_image: 'icon_image'
      )

      expect(host_template.templates.length).to eq 1
      expect(host_template.templates[0]).to have_attributes(
        id: 1,
        name: 'HT_TEST',
      )

      expect(host_template.macros.length).to eq 1
      expect(host_template.macros[0]).to have_attributes(
        name: 'warning',
        value: '10',
        password: false,
        description: 'Threshold warning',
      )
    end

    it 'Test get when host template not found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"htpl","values":"test"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      host_template = client.host_template.get('test')

      expect(host_template).to eq nil
    end

    it 'Test load when host template found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettemplate","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"getmacro","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"getparam","object":"htpl","values":"test;action_url|active_checks_enabled|check_command|check_command_arguments|check_interval|check_period|icon_image|max_check_attempts|notes|notes_url|passive_checks_enabled|retry_check_interval|snmp_community|snmp_version|timezone"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "comment": "comment",
                      "snmp_community": "snmp_community",
                      "snmp_version": "3",
                      "timezone": "timezone",
                      "check_command": "check_command",
                      "check_command_args": "!arg1!arg2",
                      "check_interval": "10",
                      "retry_check_interval": "1",
                      "max_check_attempts": "3",
                      "check_period": "check_period",
                      "active_check": "2",
                      "passive_check": "2",
                      "notes_url": "notes_url",
                      "action_url": "action_url",
                      "notes": "notes",
                      "icon_image": "icon_image"

                  }
              ]
          }
      ')
      host_template = Centreon::HostTemplate.new
      host_template.id = 82
      host_template.name = 'test'
      host_template.address = '127.0.0.1'

      client.host_template.load(host_template)

      expect(host_template).to have_attributes(
        id: 82,
        name: 'test',
        address: '127.0.0.1',
        comment: 'comment',
        snmp_community: 'snmp_community',
        snmp_version: '3',
        timezone: 'timezone',
        check_command: 'check_command',
        check_command_args: ['arg1', 'arg2'],
        check_interval: 10,
        retry_check_interval: 1,
        max_check_attempts: 3,
        check_period: 'check_period',
        active_check: 'default',
        passive_check: 'default',
        note_url: 'notes_url',
        action_url: 'action_url',
        note: 'notes',
        icon_image: 'icon_image'
      )

      expect(host_template.templates.length).to eq 1
      expect(host_template.templates[0]).to have_attributes(
        id: 1,
        name: 'HT_TEST',
      )

      expect(host_template.macros.length).to eq 1
      expect(host_template.macros[0]).to have_attributes(
        name: 'warning',
        value: '10',
        password: false,
        description: 'Threshold warning',
      )
    end

    it 'Test add host template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"htpl","values":"test;my description;127.0.0.1;HT1|HT2;;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;snmp_community;snmp_community"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;snmp_version;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;timezone;timezone"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_command;check_command"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_command_args;!arg1!arg2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_interval;10"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_period;check_period"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;active_check;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;passive_check;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;notes_url;notes_url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;action_url;action_url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;notes;notes"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;icon_image;icon_image"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;foo;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_template = Centreon::HostTemplate.new
      host_template.name = 'test'
      host_template.description = 'my description'
      host_template.comment = 'foo'
      host_template.address = '127.0.0.1'
      ht1 = Centreon::HostTemplate.new
      ht1.name = 'HT1'
      host_template.add_template(ht1)
      ht2 = Centreon::HostTemplate.new
      ht2.name = 'HT2'
      host_template.add_template(ht2)
      macro1 = Centreon::Macro.new
      macro1.name = 'macro1'
      macro1.value = 'foo'
      host_template.add_macro(macro1)
      host_template.activated = true
      host_template.snmp_community = 'snmp_community'
      host_template.snmp_version = '3'
      host_template.timezone = 'timezone'
      host_template.check_command = 'check_command'
      host_template.add_check_command_arg('arg1')
      host_template.add_check_command_arg('arg2')
      host_template.check_interval = 10
      host_template.retry_check_interval = 1
      host_template.max_check_attempts = 3
      host_template.check_period = 'check_period'
      host_template.active_check = 'default'
      host_template.passive_check = 'default'
      host_template.note_url = 'notes_url'
      host_template.action_url = 'action_url'
      host_template.note = 'notes'
      host_template.icon_image = 'icon_image'

      client.host_template.add(host_template)
    end

    it 'Test update host template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;alias;my description"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;snmp_community;snmp_community"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;snmp_version;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;timezone;timezone"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_command;check_command"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_command_args;!arg1!arg2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_interval;10"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;check_period;check_period"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;active_check;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;passive_check;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;notes_url;notes_url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;action_url;action_url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;notes;notes"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"htpl","values":"test;icon_image;icon_image"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"disable","object":"htpl","values":"test"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;value;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"settemplate","object":"htpl","values":"test;HT1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"htpl","values":"test"}')
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
        .with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;foo;0;"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"delmacro","object":"htpl","values":"test;old"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_template = Centreon::HostTemplate.new
      host_template.name = 'test'
      host_template.description = 'my description'
      host_template.comment = 'foo'
      ht = Centreon::HostTemplate.new
      ht.name = 'HT1'
      host_template.add_template(ht)
      macro1 = Centreon::Macro.new
      macro1.name = 'macro1'
      macro1.value = 'foo'
      host_template.add_macro(macro1)
      host_template.snmp_community = 'snmp_community'
      host_template.snmp_version = '3'
      host_template.timezone = 'timezone'
      host_template.check_command = 'check_command'
      host_template.add_check_command_arg('arg1')
      host_template.add_check_command_arg('arg2')
      host_template.check_interval = 10
      host_template.retry_check_interval = 1
      host_template.max_check_attempts = 3
      host_template.check_period = 'check_period'
      host_template.active_check = 'default'
      host_template.passive_check = 'default'
      host_template.note_url = 'notes_url'
      host_template.action_url = 'action_url'
      host_template.note = 'notes'
      host_template.icon_image = 'icon_image'

      client.host_template.update(host_template)
    end

    it 'Test delete host template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"htpl","values":"test"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.host_template.delete('test')
    end

    it 'Test add_templates' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"addtemplate","object":"htpl","values":"test;HT1|HT2"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_template = Centreon::HostTemplate.new
      host_template.name = 'test'
      host_template1 = Centreon::HostTemplate.new
      host_template1.name = 'HT1'
      host_template.add_template(host_template1)
      host_template2 = Centreon::HostTemplate.new
      host_template2.name = 'HT2'
      host_template.add_template(host_template2)

      client.host_template.add_templates(host_template)
    end

    it 'Test delete_templates' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"deltemplate","object":"htpl","values":"test;HT1|HT2"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_template = Centreon::HostTemplate.new
      host_template.name = 'test'
      host_template1 = Centreon::HostTemplate.new
      host_template1.name = 'HT1'
      host_template.add_template(host_template1)
      host_template2 = Centreon::HostTemplate.new
      host_template2.name = 'HT2'
      host_template.add_template(host_template2)

      client.host_template.delete_templates(host_template)
    end

    it 'Test add_macros' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;value;0;my macro"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_template = Centreon::HostTemplate.new
      host_template.name = 'test'
      macro = Centreon::Macro.new
      macro.name = 'MACRO1'
      macro.value = 'value'
      macro.description = 'my macro'
      macro.password = false
      host_template.add_macro(macro)

      client.host_template.add_macros(host_template)
    end

    it 'Test delete_macros' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"delmacro","object":"htpl","values":"test;MACRO1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_template = Centreon::HostTemplate.new
      host_template.name = 'test'
      macro = Centreon::Macro.new
      macro.name = 'MACRO1'
      macro.value = 'value'
      macro.description = 'my macro'
      macro.password = false
      host_template.add_macro(macro)

      client.host_template.delete_macros(host_template)
    end
  end
end
