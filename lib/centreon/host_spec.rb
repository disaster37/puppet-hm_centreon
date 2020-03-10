require_relative './host.rb'

RSpec.describe 'Test Centreon::Host' do
    context "Test all getter / setter" do
        it "Test constructor" do
           host = ::Centreon::Host.new()
           expect(host.is_activated()).to eq false
           expect(host.id()).to eq nil
           expect(host.description()).to eq nil
           expect(host.name()).to eq nil
           expect(host.address()).to eq nil
           expect(host.poller()).to eq nil
           expect(host.groups()).to eq []
           expect(host.templates()).to eq []
           expect(host.macros()).to eq []
        end
        
        it "test set/get id" do
            host = ::Centreon::Host.new()
            host.set_id(123456)
            expect(host.id()).to eq 123456
        end
        
        it "test set/get is_activated" do
            host = ::Centreon::Host.new()
            host.set_is_activated(true)
            expect(host.is_activated()).to eq true
        end
        
        it "test set/get description" do
            host = ::Centreon::Host.new()
            host.set_description("test")
            expect(host.description()).to eq "test"
            
            host.set_description("")
            expect(host.description()).to eq ""
        end
        
        it "test set/get name" do
            host = ::Centreon::Host.new()
            host.set_name("test")
            expect(host.name()).to eq "test"
        end
        
        it "test set/get address" do
            host = ::Centreon::Host.new()
            host.set_address("test")
            expect(host.address()).to eq "test"
        end
        
        it "test set/get poller" do
            host = ::Centreon::Host.new()
            host.set_poller("test")
            expect(host.poller()).to eq "test"
        end
        
        it "test set/get comment" do
            host = ::Centreon::Host.new()
            host.set_comment("test")
            expect(host.comment()).to eq "test"
        end
        
        it "test add/get group" do
            host = ::Centreon::Host.new()
            expect(host.groups_to_s()).to eq ""
            
            hostGroup = ::Centreon::HostGroup.new()
            hostGroup.set_name("test")
            host.add_group(hostGroup)
            expect(host.groups()).to eq [hostGroup]
            
            hostGroup2 = ::Centreon::HostGroup.new()
            hostGroup2.set_name("test2")
            host.add_group(hostGroup2)
            expect(host.groups_to_s()).to eq "test|test2"
            
        end
        
        it "test add/get template" do
            host = ::Centreon::Host.new()
            expect(host.templates_to_s()).to eq ""
            
            hostTemplate = ::Centreon::HostTemplate.new()
            hostTemplate.set_name("test")
            host.add_template(hostTemplate)
            expect(host.templates()).to eq [hostTemplate]
            
            hostTemplate2 = ::Centreon::HostTemplate.new()
            hostTemplate2.set_name("test2")
            host.add_template(hostTemplate2)
            expect(host.templates_to_s()).to eq "test|test2"
        end
        
        it "test add/get macro" do
            host = ::Centreon::Host.new()
            macro = ::Centreon::Macro.new()
            macro.set_name("test")
            macro.set_value("test")
            host.add_macro(macro)
            expect(host.macros()).to eq [macro]
        end
        
        it "test add/get service" do
            host = ::Centreon::Host.new()
            service = ::Centreon::Service.new()
            service.set_name("test")
            host.add_service(service)
            expect(host.services()).to eq [service]
        end
        
        it "test is_valid" do
            host = ::Centreon::Host.new()
            expect(host.is_valid()).to eq false
            
            host.set_name("test")
            expect(host.is_valid()).to eq false
            
            host.set_address("127.0.0.1")
            expect(host.is_valid()).to eq false
            
            host.set_poller("poller1")
            expect(host.is_valid()).to eq true
        end
        
        it "test is_valid_name" do
            host = ::Centreon::Host.new()
            expect(host.is_valid_name()).to eq false
            
            host.set_name("test")
            expect(host.is_valid_name()).to eq true
        end
        
    end
end