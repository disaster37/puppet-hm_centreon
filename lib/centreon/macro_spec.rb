require_relative './helper.rb'
require_relative './macro.rb'

RSpec.describe 'Test Centreon::Macro' do
  context 'Test all getter / setter' do
    it 'Test constructor' do
      macro = ::Centreon::Macro.new
      expect(macro.name).to eq nil
      expect(macro.value).to eq nil
      expect(macro.description).to eq nil
      expect(macro.password).to eq false
    end

    it 'test set/get name' do
      macro = ::Centreon::Macro.new
      macro.name = 'test'
      expect(macro.name).to eq 'test'
    end

    it 'test set/get value' do
      macro = ::Centreon::Macro.new
      macro.value = 'test'
      expect(macro.value).to eq 'test'
    end

    it 'test set/get description' do
      macro = ::Centreon::Macro.new
      macro.description = 'test'
      expect(macro.description).to eq 'test'

      macro.description = ''
      expect(macro.description).to eq ''
    end

    it 'test set/get source' do
      macro = ::Centreon::Macro.new
      macro.source = 'test'
      expect(macro.source).to eq 'test'

      macro.source = ''
      expect(macro.source).to eq ''
    end

    it 'test set/get password' do
      macro = ::Centreon::Macro.new
      macro.password = true
      expect(macro.password).to eq true
    end

    it 'test is_valid' do
      macro = ::Centreon::Macro.new
      expect(macro.valid).to eq false

      macro.name = 'test'
      expect(macro.valid).to eq false

      macro.value = 'test'
      expect(macro.valid).to eq true

      macro.value = ''
      expect(macro.valid).to eq true
    end

    it 'test compare' do
      macro1 = ::Centreon::Macro.new
      macro1.name = 'test'
      macro1.value = 'value'
      macro1.password = true
      macro1.description = 'description'

      macro2 = ::Centreon::Macro.new

      expect(macro1.compare(macro2)).to eq false
    end
  end
end
