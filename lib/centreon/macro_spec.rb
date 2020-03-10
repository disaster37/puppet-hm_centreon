require_relative './macro.rb'

RSpec.describe 'Test Centreon::Macro' do
    context "Test all getter / setter" do
        it "Test constructor" do
           macro = ::Centreon::Macro.new()
           expect(macro.name()).to eq nil
           expect(macro.value()).to eq nil
           expect(macro.description()).to eq nil
           expect(macro.is_password()).to eq false
        end
        
        it "test set/get name" do
            macro = ::Centreon::Macro.new()
            macro.set_name("test")
            expect(macro.name()).to eq "test"
        end
        
        it "test set/get value" do
            macro = ::Centreon::Macro.new()
            macro.set_value("test")
            expect(macro.value()).to eq "test"
        end
        
        it "test set/get description" do
            macro = ::Centreon::Macro.new()
            macro.set_description("test")
            expect(macro.description()).to eq "test"
            
            macro.set_description("")
            expect(macro.description()).to eq ""
        end
        
        it "test set/get source" do
            macro = ::Centreon::Macro.new()
            macro.set_source("test")
            expect(macro.source()).to eq "test"
            
            macro.set_source("")
            expect(macro.source()).to eq ""
        end
        
        it "test set/get is_password" do
            macro = ::Centreon::Macro.new()
            macro.set_is_password(true)
            expect(macro.is_password()).to eq true
        end
        
        it "test is_valid" do
            macro = ::Centreon::Macro.new()
            expect(macro.is_valid()).to eq false
            
            macro.set_name("test")
            expect(macro.is_valid()).to eq false
            
            macro.set_value("test")
            expect(macro.is_valid()).to eq true
            
            macro.set_value("")
            expect(macro.is_valid()).to eq true
        end
        
        it "test compare" do
           macro1 = ::Centreon::Macro.new()
           macro1.set_name("test")
           macro1.set_value("value")
           macro1.set_is_password(true)
           macro1.set_description("description")
           
           macro2 = ::Centreon::Macro.new()
           
           expect(macro1.compare(macro2)).to eq false
        end
        
    end
end