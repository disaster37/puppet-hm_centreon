require_relative './helper.rb'
require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::Service' do
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

  before(:each) do
  end

  context 'Test all' do
    it 'Test constructor' do
      expect(client).not_to eq nil
      expect(client.service).not_to eq nil
    end

    it 'Test fetch when service' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"service"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "host id": "1",
                      "host name": "test",
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2",
                      "activate": "1"
                  }
              ]
          }
      ')

      services = client.service.fetch

      expect(services.length).to eq 1
      expect(services[0]).to have_attributes(
        id: 2,
        name: 'service1',
        check_command: 'ls',
        check_command_args: ['h', 'l'],
        normal_check_interval: 5,
        retry_check_interval: 1,
        max_check_attempts: 3,
        active_checks_enabled: 'default',
        passive_checks_enabled: 'default',
        activated: true,
      )
      expect(services[0].host).not_to eq nil
      expect(services[0].host.id).to eq 1
      expect(services[0].host.name).to eq 'test'
    end

    it 'Test fetch when no service' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"service"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      services = client.service.fetch

      expect(services.length).to eq 0
    end

    it 'Test fetch when no lazzy' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"service"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "host id": "1",
                      "host name": "test",
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2",
                      "activate": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"service","values":"test;service1;template|notes_url|action_url|comment|notes|check_period|is_volatile|icon_image"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "template": "template1",
                      "notes_url": "http://localhost",
                      "action_url": "http://127.0.0.1",
                      "comment": "this is a test",
                      "notes": "my notes",
                      "check_period": "check_period",
                      "is_volatile": "2",
                      "icon_image": "icon_image"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "macro1",
                      "macro value": "foo",
                      "is_password": "0",
                      "description": "my macro 1",
                      "source": "direct"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getcategory","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "CPU",
                      "id": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getservicegroup","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "SG1",
                      "id": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettrap","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "trap",
                      "id": "1"
                  }
              ]
          }
      ')

      services = client.service.fetch(nil, nil, false)

      expect(services.length).to eq 1
      expect(services[0]).to have_attributes(
        id: 2,
        name: 'service1',
        check_command: 'ls',
        check_command_args: ['h', 'l'],
        normal_check_interval: 5,
        retry_check_interval: 1,
        max_check_attempts: 3,
        active_checks_enabled: 'default',
        passive_checks_enabled: 'default',
        activated: true,
        template: 'template1',
        note_url: 'http://localhost',
        action_url: 'http://127.0.0.1',
        comment: 'this is a test',
        note: 'my notes',
        check_period: 'check_period',
        volatile_enabled: 'default',
        icon_image: 'icon_image',

      )
      expect(services[0].host).not_to eq nil
      expect(services[0].host.id).to eq 1
      expect(services[0].host.name).to eq 'test'

      expect(services[0].macros.length).to eq 1
      expect(services[0].macros[0].name).to eq 'macro1'
      expect(services[0].macros[0].value).to eq 'foo'
      expect(services[0].macros[0].password).to eq false
      expect(services[0].macros[0].description).to eq 'my macro 1'
      expect(services[0].macros[0].source).to eq 'direct'

      expect(services[0].groups.length).to eq 1
      expect(services[0].groups[0].name).to eq 'SG1'
      expect(services[0].groups[0].id).to eq 1

      expect(services[0].service_traps.length).to eq 1
      expect(services[0].service_traps[0]).to eq 'trap'

      expect(services[0].categories.length).to eq 1
      expect(services[0].categories[0]).to eq 'CPU'
    end

    it 'Test get when service found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "host id": "1",
                      "host name": "test",
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2",
                      "activate": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"service","values":"test;service1;template|notes_url|action_url|comment|notes|check_period|is_volatile|icon_image"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "template": "template1",
                      "notes_url": "http://localhost",
                      "action_url": "http://127.0.0.1",
                      "comment": "this is a test",
                      "notes": "my notes",
                      "check_period": "check_period",
                      "is_volatile": "2",
                      "icon_image": "icon_image"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "macro1",
                      "macro value": "foo",
                      "is_password": "0",
                      "description": "my macro 1",
                      "source": "direct"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getcategory","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "CPU",
                      "id": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getservicegroup","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "SG1",
                      "id": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettrap","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "trap",
                      "id": "1"
                  }
              ]
          }
      ')

      service = client.service.get('test', 'service1', false)

      expect(service).not_to eq nil
      expect(service).to have_attributes(
        id: 2,
        name: 'service1',
        check_command: 'ls',
        check_command_args: ['h', 'l'],
        normal_check_interval: 5,
        retry_check_interval: 1,
        max_check_attempts: 3,
        active_checks_enabled: 'default',
        passive_checks_enabled: 'default',
        activated: true,
        template: 'template1',
        note_url: 'http://localhost',
        action_url: 'http://127.0.0.1',
        comment: 'this is a test',
        note: 'my notes',
        check_period: 'check_period',
        volatile_enabled: 'default',
        icon_image: 'icon_image',
      )
      expect(service.host).not_to eq nil
      expect(service.host.id).to eq 1
      expect(service.host.name).to eq 'test'

      expect(service.macros.length).to eq 1
      expect(service.macros[0].name).to eq 'macro1'
      expect(service.macros[0].value).to eq 'foo'
      expect(service.macros[0].password).to eq false
      expect(service.macros[0].description).to eq 'my macro 1'
      expect(service.macros[0].source).to eq 'direct'

      expect(service.groups.length).to eq 1
      expect(service.groups[0].name).to eq 'SG1'
      expect(service.groups[0].id).to eq 1

      expect(service.service_traps.length).to eq 1
      expect(service.service_traps[0]).to eq 'trap'

      expect(service.categories.length).to eq 1
      expect(service.categories[0]).to eq 'CPU'
    end

    it 'Test get when service not found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      service = client.service.get('test', 'service1')

      expect(service).to eq nil
    end

    it 'Test load' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"service","values":"test;service1;template|notes_url|action_url|comment|notes|check_period|is_volatile|icon_image"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "template": "template1",
                      "notes_url": "http://localhost",
                      "action_url": "http://127.0.0.1",
                      "comment": "this is a test",
                      "notes": "my notes",
                      "check_period": "check_period",
                      "is_volatile": "2",
                      "icon_image": "icon_image"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "macro name": "macro1",
                      "macro value": "foo",
                      "is_password": "0",
                      "description": "my macro 1",
                      "source": "direct"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getcategory","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "CPU",
                      "id": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getservicegroup","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "SG1",
                      "id": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"gettrap","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "name": "trap",
                      "id": "1"
                  }
              ]
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      service = Centreon::Service.new
      service.name = 'service1'
      service.host = host
      client.service.load(service)

      expect(service).not_to eq nil
      expect(service).to have_attributes(
        name: 'service1',
        template: 'template1',
        note_url: 'http://localhost',
        action_url: 'http://127.0.0.1',
        comment: 'this is a test',
        note: 'my notes',
        check_period: 'check_period',
        volatile_enabled: 'default',
        icon_image: 'icon_image',
      )
      expect(service.host).not_to eq nil
      expect(service.host.name).to eq 'test'

      expect(service.macros.length).to eq 1
      expect(service.macros[0].name).to eq 'macro1'
      expect(service.macros[0].value).to eq 'foo'
      expect(service.macros[0].password).to eq false
      expect(service.macros[0].description).to eq 'my macro 1'
      expect(service.macros[0].source).to eq 'direct'

      expect(service.groups.length).to eq 1
      expect(service.groups[0].name).to eq 'SG1'
      expect(service.groups[0].id).to eq 1

      expect(service.service_traps.length).to eq 1
      expect(service.service_traps[0]).to eq 'trap'

      expect(service.categories.length).to eq 1
      expect(service.categories[0]).to eq 'CPU'
    end

    it 'Test add' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"service","values":"test;service1;template1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command;ls"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command_arguments;!l!h"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;normal_check_interval;5"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;active_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;passive_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;notes_url;http://localhost"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;action_url;http://127.0.0.1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;check_period;check_period"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;is_volatile;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;notes;note"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;icon_image;icon_image"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"service","values":"test;service1;MACRO1;foo;0;my macro"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setservicegroup","object":"service","values":"test;service1;SG1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setcategory","object":"service","values":"test;service1;CPU"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"settrap","object":"service","values":"test;service1;trap"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      service = Centreon::Service.new
      service.host = host
      service.name = 'service1'
      service.check_command = 'ls'
      service.add_check_command_arg('l')
      service.add_check_command_arg('h')
      service.activated = true
      service.template = 'template1'
      service.normal_check_interval = 5
      service.retry_check_interval = 1
      service.max_check_attempts = 3
      service.active_checks_enabled = 'default'
      service.passive_checks_enabled = 'default'
      service.note_url = 'http://localhost'
      service.action_url = 'http://127.0.0.1'
      service.comment = 'foo'
      service.check_period = 'check_period'
      service.volatile_enabled = 'default'
      service.note = 'note'
      service.icon_image = 'icon_image'
      service.add_category('CPU')
      service.add_service_trap('trap')

      service_group = Centreon::ServiceGroup.new
      service_group.name = 'SG1'
      service.add_group(service_group)

      macro = Centreon::Macro.new
      macro.name = 'macro1'
      macro.value = 'foo'
      macro.password = false
      macro.description = 'my macro'
      service.add_macro(macro)

      client.service.add(service)
    end

    it 'Test delete' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.service.delete('test', 'service1')
    end

    it 'Test update' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"service"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "host id": "1",
                      "host name": "test",
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2",
                      "activate": "1"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"service","values":"test;service1;template1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command;ls"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command_arguments;!l!h"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;normal_check_interval;5"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;active_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;passive_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;notes_url;http://localhost"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;action_url;http://127.0.0.1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"service","values":"test;service1;template;template1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"service","values":"test;service1;MACRO1;foo;0;my macro"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"service","values":"test;service1"}')
        .to_return(status: 200, body: '
          {
              "result": [

              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setcategory","object":"service","values":"test;service1;CPU"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"settrap","object":"service","values":"test;service1;trap"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setservicegroup","object":"service","values":"test;service1;SG1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host = Centreon::Host.new
      host.name = 'test'
      service = Centreon::Service.new
      service.host = host
      service.name = 'service1'
      service.check_command = 'ls'
      service.add_check_command_arg('l')
      service.add_check_command_arg('h')
      service.activated = true
      service.template = 'template1'
      service.normal_check_interval = 5
      service.retry_check_interval = 1
      service.max_check_attempts = 3
      service.active_checks_enabled = 'default'
      service.passive_checks_enabled = 'default'
      service.note_url = 'http://localhost'
      service.action_url = 'http://127.0.0.1'
      service.comment = 'foo'
      service.add_category('CPU')
      service.add_service_trap('trap')

      service_group = Centreon::ServiceGroup.new
      service_group.name = 'SG1'
      service.add_group(service_group)

      macro = Centreon::Macro.new
      macro.name = 'macro1'
      macro.value = 'foo'
      macro.password = false
      macro.description = 'my macro'
      service.add_macro(macro)

      client.service.update(service)
    end
  end
end
