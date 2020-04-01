require_relative './host_group.rb'

RSpec.describe 'Test Centreon::host_group' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      host_group = ::Centreon::HostGroup.new
      expect(host_group.id).to eq nil
      expect(host_group.name).to eq nil
      expect(host_group.description).to eq nil
      expect(host_group.comment).to eq nil
      expect(host_group.note).to eq nil
      expect(host_group.note_url).to eq nil
      expect(host_group.action_url).to eq nil
      expect(host_group.icon_image).to eq nil
      expect(host_group.activated).to eq false
    end

    it 'test set/get id' do
      host_group = ::Centreon::HostGroup.new
      host_group.id = 123_456
      expect(host_group.id).to eq 123_456
    end

    it 'test set/get name' do
      host_group = ::Centreon::HostGroup.new
      host_group.name = 'test'
      expect(host_group.name).to eq 'test'
    end

    it 'test set/get description' do
      host_group = ::Centreon::HostGroup.new
      host_group.description = 'test'
      expect(host_group.description).to eq 'test'

      host_group.description = ''
      expect(host_group.description).to eq ''
    end

    it 'test set/get comment' do
      host_group = ::Centreon::HostGroup.new
      host_group.comment = 'test'
      expect(host_group.comment).to eq 'test'

      host_group.comment = ''
      expect(host_group.comment).to eq ''
    end

    it 'test set/get note' do
      host_group = ::Centreon::HostGroup.new
      host_group.note = 'test'
      expect(host_group.note).to eq 'test'

      host_group.note = ''
      expect(host_group.note).to eq ''
    end

    it 'test set/get note url' do
      host_group = ::Centreon::HostGroup.new
      host_group.note_url = 'test'
      expect(host_group.note_url).to eq 'test'

      host_group.note_url = ''
      expect(host_group.note_url).to eq ''
    end

    it 'test set/get action url' do
      host_group = ::Centreon::HostGroup.new
      host_group.action_url = 'test'
      expect(host_group.action_url).to eq 'test'

      host_group.action_url = ''
      expect(host_group.action_url).to eq ''
    end

    it 'test set/get icon image' do
      host_group = ::Centreon::HostGroup.new
      host_group.icon_image = 'test'
      expect(host_group.icon_image).to eq 'test'

      host_group.icon_image = ''
      expect(host_group.icon_image).to eq ''
    end

    it 'test set/get activated' do
      host_group = ::Centreon::HostGroup.new
      host_group.activated = true
      expect(host_group.activated).to eq true

      host_group.activated = false
      expect(host_group.activated).to eq false
    end

    it 'test valid' do
      host_group = ::Centreon::HostGroup.new
      expect(host_group.valid).to eq false

      host_group.name = 'test'
      expect(host_group.valid).to eq true
    end
  end
end
