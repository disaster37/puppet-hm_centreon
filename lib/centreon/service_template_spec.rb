require_relative './service_model.rb'
require_relative './service_template.rb'


RSpec.describe 'Test Centreon::ServiceTemplate' do
    context "Test all getter / setter" do
        it "Test constructor" do
           serviceTemplate = ::Centreon::ServiceTemplate.new()
           expect(serviceTemplate.id()).to eq nil
           expect(serviceTemplate.name()).to eq nil
        end
        
        it "test set/get id" do
            serviceTemplate = ::Centreon::ServiceTemplate.new()
            serviceTemplate.set_id(123456)
            expect(serviceTemplate.id()).to eq 123456
        end
        
        it "test set/get name" do
            serviceTemplate = ::Centreon::ServiceTemplate.new()
            serviceTemplate.set_name("test")
            expect(serviceTemplate.name()).to eq "test"
        end
        
        it "test is_valid" do
            serviceTemplate = ::Centreon::ServiceTemplate.new()
            expect(serviceTemplate.is_valid()).to eq false
            
            serviceTemplate.set_name("test")
            expect(serviceTemplate.is_valid()).to eq true
        end
        
        it "test set/get description" do
            service = ::Centreon::ServiceTemplate.new()
            service.set_description("my template")
            expect(service.description()).to eq "my template"
            
            service.set_description("")
            expect(service.description()).to eq ""
        end
        
    end
end