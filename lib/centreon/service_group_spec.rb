require_relative './service_group.rb'
require_relative './service.rb'
require_relative './host.rb'

RSpec.describe 'Test Centreon::ServiceGroup' do
    context "Test all getter / setter" do
        it "Test constructor" do
           serviceGroup = ::Centreon::ServiceGroup.new()
           expect(serviceGroup.id()).to eq nil
           expect(serviceGroup.name()).to eq nil
           expect(serviceGroup.description()).to eq nil
           expect(serviceGroup.services()).to eq []
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
        
        it "test set/get description" do
            serviceGroup = ::Centreon::ServiceGroup.new()
            serviceGroup.set_description("test")
            expect(serviceGroup.description()).to eq "test"
            
            serviceGroup.set_description("")
            expect(serviceGroup.description()).to eq ""
        end
        
        it "test is_valid" do
            serviceGroup = ::Centreon::ServiceGroup.new()
            expect(serviceGroup.is_valid()).to eq false
            
            serviceGroup.set_name("test")
            expect(serviceGroup.is_valid()).to eq true
        end
        
        it "test add/get services" do
            service_group = ::Centreon::ServiceGroup.new()
            service = ::Centreon::Service.new()
            host = ::Centreon::Host.new()
            host.set_name("test")
            service.set_name("test")
            service.set_host(host)
            service_group.add_service(service)
            expect(service_group.services()).to eq [service]
        end
        
    end
end