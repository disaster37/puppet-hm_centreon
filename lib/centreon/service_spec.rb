require_relative './service.rb'

RSpec.describe 'Test Centreon::Service' do
    context "Test all getter / setter" do
        it "Test constructor" do
           service = ::Centreon::Service.new()
           expect(service.name()).to eq nil
           expect(service.is_activated()).to eq false
           expect(service.template()).to eq nil
           expect(service.macros()).to eq []
        end
        
        it "test set/get name" do
            service = ::Centreon::Service.new()
            service.set_name("test")
            expect(service.name()).to eq "test"
        end
        
        it "test set/get template" do
            service = ::Centreon::Service.new()
            service.set_template("test")
            expect(service.template()).to eq "test"
        end
        
        it "test set/get is_activated" do
            service = ::Centreon::Service.new()
            service.set_is_activated(true)
            expect(service.is_activated()).to eq true
        end
        
        it "test add/get macro" do
            service = ::Centreon::Service.new()
            macro = ::Centreon::Macro.new()
            macro.set_name("test")
            macro.set_value("test")
            service.add_macro(macro)
            expect(service.macros()).to eq [macro]
        end
        
    end
end