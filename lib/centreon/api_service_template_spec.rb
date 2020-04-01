require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::ServiceTemplate' do
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
      expect(client.service_template).not_to eq nil
    end

    it 'Test fetch when service template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"stpl"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2"
                  }
              ]
          }
      ')

      service_templates = client.service_template.fetch

      expect(service_templates.length).to eq 1
      expect(service_templates[0]).to have_attributes(
        id: 2,
        name: 'service1',
        command: 'ls',
        command_args: ['h', 'l'],
        normal_check_interval: 5,
        retry_check_interval: 1,
        max_check_attempts: 3,
        active_check_enabled: 'default',
        passive_check_enabled: 'default',
      )
    end

    it 'Test fetch when no service template' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"stpl"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      service_templates = client.service_template.fetch

      expect(service_templates.length).to eq 0
    end

    it 'Test fetch when no lazzy' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"stpl"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"stpl","values":"service1;alias|template|notes_url|action_url|comment"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "alias": "my template",
                      "template": "template1",
                      "notes_url": "http://localhost",
                      "action_url": "http://127.0.0.1",
                      "comment": "this is a test"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"stpl","values":"service1"}')
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

      service_templates = client.service_template.fetch(nil, false)

      expect(service_templates.length).to eq 1
      expect(service_templates[0]).to have_attributes(
        id: 2,
        name: 'service1',
        command: 'ls',
        command_args: ['h', 'l'],
        normal_check_interval: 5,
        retry_check_interval: 1,
        max_check_attempts: 3,
        active_check_enabled: 'default',
        passive_check_enabled: 'default',
        # Bug centreon
        #:template               => "template1",
        #:note_url               => "http://localhost",
        #:action_url             => "http://127.0.0.1",
        #:comment                => "this is a test"
      )

      expect(service_templates[0].macros.length).to eq 1
      expect(service_templates[0].macros[0].name).to eq 'macro1'
      expect(service_templates[0].macros[0].value).to eq 'foo'
      expect(service_templates[0].macros[0].password).to eq false
      expect(service_templates[0].macros[0].description).to eq 'my macro 1'
      expect(service_templates[0].macros[0].source).to eq 'direct'
    end

    it 'Test get when service template found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"stpl","values":"service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"stpl","values":"service1;alias|template|notes_url|action_url|comment"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "alias": "my template",
                      "template": "template1",
                      "notes_url": "http://localhost",
                      "action_url": "http://127.0.0.1",
                      "comment": "this is a test"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"stpl","values":"service1"}')
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

      service_template = client.service_template.get('service1', false)

      expect(service_template).not_to eq nil
      expect(service_template).to have_attributes(
        id: 2,
        name: 'service1',
        command: 'ls',
        command_args: ['h', 'l'],
        normal_check_interval: 5,
        retry_check_interval: 1,
        max_check_attempts: 3,
        active_check_enabled: 'default',
        passive_check_enabled: 'default',
        # Bug centreon
        #:template               => "template1",
        #:note_url               => "http://localhost",
        #:action_url             => "http://127.0.0.1",
        #:comment                => "this is a test"
      )

      expect(service_template.macros.length).to eq 1
      expect(service_template.macros[0].name).to eq 'macro1'
      expect(service_template.macros[0].value).to eq 'foo'
      expect(service_template.macros[0].password).to eq false
      expect(service_template.macros[0].description).to eq 'my macro 1'
      expect(service_template.macros[0].source).to eq 'direct'
    end

    it 'Test get when service not found' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"stpl","values":"service1"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      service = client.service_template.get('service1')

      expect(service).to eq nil
    end

    it 'Test load' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"stpl","values":"service1;alias|template|notes_url|action_url|comment"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "alias": "my template",
                      "template": "template1",
                      "notes_url": "http://localhost",
                      "action_url": "http://127.0.0.1",
                      "comment": "this is a test"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"stpl","values":"service1"}')
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

      service_template = Centreon::ServiceTemplate.new
      service_template.name = 'service1'
      client.service_template.load(service_template)

      expect(service_template).not_to eq nil
      expect(service_template).to have_attributes(
        name: 'service1',
        # Bug centreon
        #:template               => "template1",
        #:note_url               => "http://localhost",
        #:action_url             => "http://127.0.0.1",
        #:comment                => "this is a test"
      )

      expect(service_template.macros.length).to eq 1
      expect(service_template.macros[0].name).to eq 'macro1'
      expect(service_template.macros[0].value).to eq 'foo'
      expect(service_template.macros[0].password).to eq false
      expect(service_template.macros[0].description).to eq 'my macro 1'
      expect(service_template.macros[0].source).to eq 'direct'
    end

    it 'Test add' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"stpl","values":"service1;my template;template1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;check_command;ls"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;check_command_arguments;!l!h"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;normal_check_interval;5"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;active_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;passive_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;notes_url;http://localhost"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;action_url;http://127.0.0.1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"stpl","values":"service1;MACRO1;foo;0;my macro"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      service_template = Centreon::ServiceTemplate.new
      service_template.name = 'service1'
      service_template.description = 'my template'
      service_template.command = 'ls'
      service_template.add_command_arg('l')
      service_template.add_command_arg('h')
      service_template.activated = true
      service_template.template = 'template1'
      service_template.normal_check_interval = 5
      service_template.retry_check_interval = 1
      service_template.max_check_attempts = 3
      service_template.active_check_enabled = 'default'
      service_template.passive_check_enabled = 'default'
      service_template.note_url = 'http://localhost'
      service_template.action_url = 'http://127.0.0.1'
      service_template.comment = 'foo'

      macro = Centreon::Macro.new
      macro.name = 'macro1'
      macro.value = 'foo'
      macro.password = false
      macro.description = 'my macro'
      service_template.add_macro(macro)

      client.service_template.add(service_template)
    end

    it 'Test delete' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"stpl","values":"service1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.service_template.delete('service1')
    end

    it 'Test update' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"stpl"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "2",
                      "description": "service1",
                      "check command": "ls",
                      "check command arg": "!h!l",
                      "normal check interval": "5",
                      "retry check interval": "1",
                      "max check attempts": "3",
                      "active checks enabled": "2",
                      "passive checks enabled": "2"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"stpl","values":"service1;my template;template1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;alias;my template"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;check_command;ls"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;check_command_arguments;!l!h"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;max_check_attempts;3"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;normal_check_interval;5"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;retry_check_interval;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;active_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;passive_checks_enabled;2"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;notes_url;http://localhost"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;action_url;http://127.0.0.1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;comment;foo"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"stpl","values":"service1;template;template1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setmacro","object":"stpl","values":"service1;MACRO1;foo;0;my macro"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getmacro","object":"stpl","values":"service1"}')
        .to_return(status: 200, body: '
          {
              "result": [

              ]
          }
      ')

      service_template = Centreon::ServiceTemplate.new
      service_template.name = 'service1'
      service_template.description = 'my template'
      service_template.command = 'ls'
      service_template.add_command_arg('l')
      service_template.add_command_arg('h')
      service_template.activated = true
      service_template.template = 'template1'
      service_template.normal_check_interval = 5
      service_template.retry_check_interval = 1
      service_template.max_check_attempts = 3
      service_template.active_check_enabled = 'default'
      service_template.passive_check_enabled = 'default'
      service_template.note_url = 'http://localhost'
      service_template.action_url = 'http://127.0.0.1'
      service_template.comment = 'foo'

      macro = Centreon::Macro.new
      macro.name = 'macro1'
      macro.value = 'foo'
      macro.password = false
      macro.description = 'my macro'
      service_template.add_macro(macro)

      client.service_template.update(service_template)
    end
  end
end
