require_relative './helper.rb'
require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::HostGroup' do
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
      expect(client.host_group).not_to eq nil
    end

    it 'Test fetch when host groups' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"hg"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "HG1",
                      "alias": "test HG"
                  }
              ]
          }
      ')

      host_groups = client.host_group.fetch

      expect(host_groups.length).to eq 1
      expect(host_groups[0]).to have_attributes(
        id: 82,
        name: 'HG1',
        description: 'test HG',
      )
    end

    it 'Test fetch when no host group' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"hg"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      host_groups = client.host_group.fetch

      expect(host_groups.length).to eq 0
    end

    it 'Test fetch when specific host_group' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"hg","values":"HG1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "HG1",
                      "alias": "test HG"
                  }
              ]
          }
      ')

      host_groups = client.host_group.fetch('HG1')

      expect(host_groups.length).to eq 1
      expect(host_groups[0]).to have_attributes(
        id: 82,
        name: 'HG1',
        description: 'test HG',
      )
    end

    it 'Test delete' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"hg","values":"HG1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.host_group.delete('HG1')
    end

    it 'Test create' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"hg","values":"HG1;test HG"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;comment;my comment"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;notes;my note"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;notes_url;my note url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;action_url;my action url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;icon_image;my icon image"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_group = Centreon::HostGroup.new
      host_group.name = 'HG1'
      host_group.description = 'test HG'
      host_group.activated = true
      host_group.comment = 'my comment'
      host_group.note = 'my note'
      host_group.note_url = 'my note url'
      host_group.action_url = 'my action url'
      host_group.icon_image = 'my icon image'

      client.host_group.add(host_group)
    end

    it 'Test update' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;alias;test HG"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;comment;my comment"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;notes;my note"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;notes_url;my note url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;action_url;my action url"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"hg","values":"HG1;icon_image;my icon image"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      host_group = Centreon::HostGroup.new
      host_group.name = 'HG1'
      host_group.description = 'test HG'
      host_group.activated = true
      host_group.comment = 'my comment'
      host_group.note = 'my note'
      host_group.note_url = 'my note url'
      host_group.action_url = 'my action url'
      host_group.icon_image = 'my icon image'
      client.host_group.update(host_group)
    end
  end
end
