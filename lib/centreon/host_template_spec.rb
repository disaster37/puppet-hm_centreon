require_relative './host_template.rb'

RSpec.describe 'Test Centreon::HostTemplate' do
    context "Test all getter / setter" do
        it "Test constructor" do
           hostTemplate = ::Centreon::HostTemplate.new()
           expect(hostTemplate.id()).to eq nil
           expect(hostTemplate.name()).to eq nil
        end
        
        it "test set/get id" do
            hostTemplate = ::Centreon::HostTemplate.new()
            hostTemplate.set_id(123456)
            expect(hostTemplate.id()).to eq 123456
        end
        
        
        it "test set/get name" do
            hostTemplate = ::Centreon::HostTemplate.new()
            hostTemplate.set_name("test")
            expect(hostTemplate.name()).to eq "test"
        end
        
        it "test is_valid" do
            hostTemplate = ::Centreon::HostTemplate.new()
            expect(hostTemplate.is_valid()).to eq false
            
            hostTemplate.set_name("test")
            expect(hostTemplate.is_valid()).to eq true
        end
        
    end
end