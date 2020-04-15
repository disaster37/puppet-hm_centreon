require_relative './helper.rb'
require_relative './command.rb'

RSpec.describe 'Test Centreon::command' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      command = ::Centreon::Command.new
      expect(command.id).to eq nil
      expect(command.name).to eq nil
      expect(command.line).to eq nil
      expect(command.type).to eq nil
      expect(command.graph).to eq nil
      expect(command.example).to eq nil
      expect(command.comment).to eq nil
    end

    it 'test set/get id' do
      command = ::Centreon::Command.new
      command.id = 123_456
      expect(command.id).to eq 123_456
    end

    it 'test set/get name' do
      command = ::Centreon::Command.new
      command.name = 'test'
      expect(command.name).to eq 'test'
    end

    it 'test set/get type' do
      command = ::Centreon::Command.new
      command.type = 'test'
      expect(command.type).to eq 'test'
    end

    it 'test set/get comment' do
      command = ::Centreon::Command.new
      command.comment = 'test'
      expect(command.comment).to eq 'test'

      command.comment = ''
      expect(command.comment).to eq ''
    end

    it 'test set/get line' do
      command = ::Centreon::Command.new
      command.line = 'test'
      expect(command.line).to eq 'test'
    end

    it 'test set/get graph' do
      command = ::Centreon::Command.new
      command.graph = 'test'
      expect(command.graph).to eq 'test'

      command.graph = ''
      expect(command.graph).to eq ''
    end

    it 'test set/get example' do
      command = ::Centreon::Command.new
      command.example = 'test'
      expect(command.example).to eq 'test'

      command.example = ''
      expect(command.example).to eq ''
    end

    it 'test set/get activated' do
      command = ::Centreon::Command.new
      command.activated = true
      expect(command.activated).to eq true

      command.activated = false
      expect(command.activated).to eq false
    end

    it 'test set/get enable_shell' do
      command = ::Centreon::Command.new
      command.enable_shell = true
      expect(command.enable_shell).to eq true

      command.enable_shell = false
      expect(command.enable_shell).to eq false
    end
  end
end
