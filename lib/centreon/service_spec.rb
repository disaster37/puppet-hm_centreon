require_relative './service.rb'

RSpec.describe 'Test Centreon::Service' do
    context "Test all getter / setter" do
        it "Test constructor" do
           service = ::Centreon::Service.new()
           expect(service.host()).to eq nil
           expect(service.id()).to eq nil
           expect(service.name()).to eq nil
           expect(service.command()).to eq nil
           expect(service.is_activated()).to eq false
           expect(service.template()).to eq nil
           expect(service.normal_check_interval()).to eq nil
           expect(service.retry_check_interval()).to eq nil
           expect(service.max_check_attempts()).to eq nil
           expect(service.active_check_enabled()).to eq nil
           expect(service.passive_check_enabled()).to eq nil
           expect(service.note_url()).to eq nil
           expect(service.action_url()).to eq nil
           expect(service.comment()).to eq nil
           expect(service.command_args()).to eq []
           expect(service.macros()).to eq []
           expect(service.groups()).to eq []
        end
        
        it "test set/get host" do
            host = ::Centreon::Host.new()
            host.set_name("test")
            service = ::Centreon::Service.new()
            service.set_host(host)
            expect(service.host()).to eq host
        end
        
        it "test set/get id" do
            service = ::Centreon::Service.new()
            service.set_id(1)
            expect(service.id()).to eq 1
        end
        
        it "test set/get name" do
            service = ::Centreon::Service.new()
            service.set_name("test")
            expect(service.name()).to eq "test"
        end
        
        it "test set/get command" do
            service = ::Centreon::Service.new()
            service.set_command("test")
            expect(service.command()).to eq "test"
            
            service.set_command("")
            expect(service.command()).to eq ""
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
        
        it "test set/get normal_check_interval" do
            service = ::Centreon::Service.new()
            service.set_normal_check_interval(1)
            expect(service.normal_check_interval()).to eq 1
        end
        
        it "test set/get retry_check_interval" do
            service = ::Centreon::Service.new()
            service.set_retry_check_interval(1)
            expect(service.retry_check_interval()).to eq 1
        end
        
        it "test set/get max_check_attempts" do
            service = ::Centreon::Service.new()
            service.set_max_check_attempts(1)
            expect(service.max_check_attempts()).to eq 1
        end
        
        it "test set/get active_check_enabled" do
            service = ::Centreon::Service.new()
            service.set_active_check_enabled("true")
            expect(service.active_check_enabled()).to eq "true"
            
            service.set_active_check_enabled("false")
            expect(service.active_check_enabled()).to eq "false"
            
            service.set_active_check_enabled("default")
            expect(service.active_check_enabled()).to eq "default"
        end
        
        it "test set/get passive_check_enabled" do
            service = ::Centreon::Service.new()
            service.set_passive_check_enabled("true")
            expect(service.passive_check_enabled()).to eq "true"
            
            service.set_passive_check_enabled("false")
            expect(service.passive_check_enabled()).to eq "false"
            
            service.set_passive_check_enabled("default")
            expect(service.passive_check_enabled()).to eq "default"
        end
        
        it "test set/get note_url" do
            service = ::Centreon::Service.new()
            service.set_note_url("http://test")
            expect(service.note_url()).to eq "http://test"
            
            service.set_note_url("")
            expect(service.note_url()).to eq ""
        end
        
        it "test set/get action_url" do
            service = ::Centreon::Service.new()
            service.set_action_url("http://test")
            expect(service.action_url()).to eq "http://test"
            
            service.set_action_url("")
            expect(service.action_url()).to eq ""
        end
        
        it "test set/get comment" do
            service = ::Centreon::Service.new()
            service.set_comment("test")
            expect(service.comment()).to eq "test"
            
            service.set_comment("")
            expect(service.comment()).to eq ""
        end
        
        it "test add/get macro" do
            service = ::Centreon::Service.new()
            macro = ::Centreon::Macro.new()
            macro.set_name("test")
            macro.set_value("test")
            service.add_macro(macro)
            expect(service.macros()).to eq [macro]
        end
        
        it "test add/get command_args" do
            service = ::Centreon::Service.new()
            service.add_command_arg("test")
            expect(service.command_args()).to eq ["test"]
        end
        
        it "test add/get group" do
            service = ::Centreon::Service.new()
            service_group = ::Centreon::ServiceGroup.new()
            service_group.set_name("test")
            service.add_group(service_group)
            expect(service.groups()).to eq [service_group]
        end
        
    end
end