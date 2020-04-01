require 'webmock/rspec'

require_relative './api.rb'

RSpec.describe 'Test Centreon::Client::ServiceGroup' do
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
      expect(client.service_group).not_to eq nil
    end

    it 'Test fetch when service groups' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"sg"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "SG1",
                      "alias": "test SG"
                  }
              ]
          }
      ')

      service_groups = client.service_group.fetch

      expect(service_groups.length).to eq 1
      expect(service_groups[0]).to have_attributes(
        id: 82,
        name: 'SG1',
        description: 'test SG',
      )
    end

    it 'Test fetch when no service group' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"sg"}')
        .to_return(status: 200, body: '
          {
              "result": [
              ]
          }
      ')

      service_groups = client.service_group.fetch

      expect(service_groups.length).to eq 0
    end

    it 'Test fetch when specific service_group' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"show","object":"sg","values":"SG1"}')
        .to_return(status: 200, body: '
          {
              "result": [
                  {
                      "id": "82",
                      "name": "SG1",
                      "alias": "test SG"
                  }
              ]
          }
      ')

      service_groups = client.service_group.fetch('SG1')

      expect(service_groups.length).to eq 1
      expect(service_groups[0]).to have_attributes(
        id: 82,
        name: 'SG1',
        description: 'test SG',
      )
    end

    it 'Test delete' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"del","object":"sg","values":"SG1"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      client.service_group.delete('SG1')
    end

    it 'Test create' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"add","object":"sg","values":"SG1;test SG"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"sg","values":"SG1;comment;my comment"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      service_group = Centreon::ServiceGroup.new
      service_group.name = 'SG1'
      service_group.description = 'test SG'
      service_group.activated = true
      service_group.comment = 'my comment'

      client.service_group.add(service_group)
    end

    it 'Test update' do
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"sg","values":"SG1;alias;test SG"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"sg","values":"SG1;activate;1"}')
        .to_return(status: 200, body: '
          {
          }
      ')
      stub_request(:post, 'localhost/centreon/api/index.php?action=action&object=centreon_clapi')
        .with(body: '{"action":"setparam","object":"sg","values":"SG1;comment;my comment"}')
        .to_return(status: 200, body: '
          {
          }
      ')

      service_group = Centreon::ServiceGroup.new
      service_group.name = 'SG1'
      service_group.description = 'test SG'
      service_group.activated = true
      service_group.comment = 'my comment'
      client.service_group.update(service_group)
    end
  end
end
