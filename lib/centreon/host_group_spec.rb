require_relative './host_group.rb'

RSpec.describe 'Test Centreon::HostGroup' do
    context "Test all getter / setter" do
        it "Test constructor" do
           hostGroup = ::Centreon::HostGroup.new()
           expect(hostGroup.id()).to eq nil
           expect(hostGroup.name()).to eq nil
        end
        
        it "test set/get id" do
            hostGroup = ::Centreon::HostGroup.new()
            hostGroup.set_id(123456)
            expect(hostGroup.id()).to eq 123456
        end
        
        
        it "test set/get name" do
            hostGroup = ::Centreon::HostGroup.new()
            hostGroup.set_name("test")
            expect(hostGroup.name()).to eq "test"
        end
        
        it "test is_valid" do
            hostGroup = ::Centreon::HostGroup.new()
            expect(hostGroup.is_valid()).to eq false
            
            hostGroup.set_name("test")
            expect(hostGroup.is_valid()).to eq true
        end
        
    end
end