require_relative './service_group.rb'

RSpec.describe 'Test Centreon::ServiceGroup' do
    context "Test all getter / setter" do
        it "Test constructor" do
           serviceGroup = ::Centreon::ServiceGroup.new()
           expect(serviceGroup.id()).to eq nil
           expect(serviceGroup.name()).to eq nil
        end
        
        it "test set/get id" do
            serviceGroup = ::Centreon::ServiceGroup.new()
            serviceGroup.set_id(123456)
            expect(serviceGroup.id()).to eq 123456
        end
        
        
        it "test set/get name" do
            serviceGroup = ::Centreon::ServiceGroup.new()
            serviceGroup.set_name("test")
            expect(serviceGroup.name()).to eq "test"
        end
        
        it "test is_valid" do
            serviceGroup = ::Centreon::ServiceGroup.new()
            expect(serviceGroup.is_valid()).to eq false
            
            serviceGroup.set_name("test")
            expect(serviceGroup.is_valid()).to eq true
        end
        
    end
end