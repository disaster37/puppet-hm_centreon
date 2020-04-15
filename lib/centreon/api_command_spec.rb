require_relative './helper.rb'
require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::Command' do
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
      expect(client.command).not_to eq nil
    end

    it 'Test fetch when command' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"cmd"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "command1",
                      "type": "check",
                      "line": "ls"
                  }
              ]
          }
      ')

      commands = client.command.fetch

      expect(commands.length).to eq 1
      expect(commands[0]).to have_attributes(
        id: 82,
        name: 'command1',
        type: 'check',
        line: 'ls'
      )
    end

    it 'Test fetch when no command' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"cmd"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      commands = client.command.fetch

      expect(commands.length).to eq 0
    end

    it 'Test fetch when specific command and no lazzy' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"cmd","values":"command1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "command1",
                      "type": "check",
                      "line": "ls"
                  }
              ]
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"getparam","object":"cmd","values":"command1;graph|example|comment|activate|enable_shell"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "graph": "CPU",
                      "example": "example",
                      "comment": "comment",
                      "activate": "1",
                      "enable_shell": 1
                  }
              ]
          }
      ')

      commands = client.command.fetch('command1', false)

      expect(commands.length).to eq 1
      expect(commands[0]).to have_attributes(
        id: 82,
        name: 'command1',
        type: 'check',
        line: 'ls',
        graph: 'CPU',
        example: 'example',
        comment: 'comment',
        activated: true,
        enable_shell: true,
      )
    end

    it 'Test delete' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"cmd","values":"command1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.command.delete('command1')
    end

    it 'Test create' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"cmd","values":"command1;check;ls"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;graph;CPU"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;example;sample"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;comment;comment"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;enable_shell;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      command = Centreon::Command.new
      command.name = 'command1'
      command.type = 'check'
      command.line = 'ls'
      command.graph = 'CPU'
      command.example = 'sample'
      command.comment = 'comment'
      command.activated = true
      command.enable_shell = true

      client.command.add(command)
    end

    it 'Test update' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;type;check"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;line;ls"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;graph;CPU"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;example;sample"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;comment;comment"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"cmd","values":"command1;enable_shell;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      command = Centreon::Command.new
      command.name = 'command1'
      command.type = 'check'
      command.line = 'ls'
      command.graph = 'CPU'
      command.example = 'sample'
      command.comment = 'comment'
      command.activated = true
      command.enable_shell = true

      client.command.update(command)
    end
  end
end
