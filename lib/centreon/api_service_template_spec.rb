require 'webmock/rspec'

require_relative './api.rb'


RSpec.describe 'Test Centreon::Client::ServiceTemplate' do
    
    before do
        stub_request(:post, "localhost/centreon/api/index.php?action=authenticate").
        with(body: {
            username: "user",
            password: "pass"
        }).
        to_return(status: 200, body:'
            {
                "authToken": "my_token"
            }
        ')
        
        @client = Centreon::Client.new("localhost/centreon/api/index.php", "user", "pass")
    end
    
    context "Test all" do
        it "Test constructor" do
            expect(@client).to_not eq nil
            expect(@client.service_template).to_not eq nil
        end
        
        it "Test fetch when service template" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "host id": "1",
                            "host name": "test",
                            "id": "2",
                            "description": "service1",
                            "check command": "ls",
                            "check command arg": "!h!l",
                            "normal check interval": "5",
                            "retry check interval": "1",
                            "max check attempts": "3",
                            "active checks enabled": "2",
                            "passive checks enabled": "2",
                            "activate": "1"
                        }
                    ]
                }
            ')
            
            service_templates = @client.service_template.fetch()
            
            expect(service_templates.length).to eq 1
            expect(service_templates[0]).to have_attributes(
                :id                     => 2, 
                :name                   => "service1",
                :command                => "ls",
                :command_args           => ["h", "l"],
                :normal_check_interval  => 5,
                :retry_check_interval   => 1,
                :max_check_attempts     => 3,
                :active_check_enabled   => "default",
                :passive_check_enabled  => "default",
                :is_activated           => true,
            )
            expect(service_templates[0].host()).to_not eq nil
            expect(service_templates[0].host().id()).to eq 1
            expect(service_templates[0].host().name()).to eq "test"
        end
        
        it "Test fetch when no service template" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            service_templates = @client.service_template.fetch()
            
            expect(service_templates.length).to eq 0
        end
        
        
        it "Test fetch when no lazzy" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "host id": "1",
                            "host name": "test",
                            "id": "2",
                            "description": "service1",
                            "check command": "ls",
                            "check command arg": "!h!l",
                            "normal check interval": "5",
                            "retry check interval": "1",
                            "max check attempts": "3",
                            "active checks enabled": "2",
                            "passive checks enabled": "2",
                            "activate": "1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"stpl","values":"test;service1;template|notes_url|action_url|comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "template": "template1",
                            "notes_url": "http://localhost",
                            "action_url": "http://127.0.0.1",
                            "comment": "this is a test"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"stpl","values":"test;service1"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "macro1",
                            "macro value": "foo",
                            "is_password": "0",
                            "description": "my macro 1",
                            "source": "direct"
                        }
                    ]
                }
            ')
            
            
            service_templates = @client.service_template.fetch(nil, false)
            
            expect(service_templates.length).to eq 1
            expect(service_templates[0]).to have_attributes(
                :id                     => 2, 
                :name                   => "service1",
                :command                => "ls",
                :command_args           => ["h", "l"],
                :normal_check_interval  => 5,
                :retry_check_interval   => 1,
                :max_check_attempts     => 3,
                :active_check_enabled   => "default",
                :passive_check_enabled  => "default",
                :is_activated           => true,
                # Bug centreon
                #:template               => "template1",
                #:note_url               => "http://localhost",
                #:action_url             => "http://127.0.0.1",
                #:comment                => "this is a test"
            )
            expect(service_templates[0].host()).to_not eq nil
            expect(service_templates[0].host().id()).to eq 1
            expect(service_templates[0].host().name()).to eq "test"
            
            expect(service_templates[0].macros().length).to eq 1
            expect(service_templates[0].macros()[0].name()).to eq "macro1"
            expect(service_templates[0].macros()[0].value()).to eq "foo"
            expect(service_templates[0].macros()[0].is_password()).to eq false
            expect(service_templates[0].macros()[0].description()).to eq "my macro 1"
            expect(service_templates[0].macros()[0].source()).to eq "direct"
            
        end
        
        it "Test get when service template found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\",\"values\":\"service1\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "host id": "1",
                            "host name": "test",
                            "id": "2",
                            "description": "service1",
                            "check command": "ls",
                            "check command arg": "!h!l",
                            "normal check interval": "5",
                            "retry check interval": "1",
                            "max check attempts": "3",
                            "active checks enabled": "2",
                            "passive checks enabled": "2",
                            "activate": "1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"stpl","values":"test;service1;template|notes_url|action_url|comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "template": "template1",
                            "notes_url": "http://localhost",
                            "action_url": "http://127.0.0.1",
                            "comment": "this is a test"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"stpl","values":"test;service1"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "macro1",
                            "macro value": "foo",
                            "is_password": "0",
                            "description": "my macro 1",
                            "source": "direct"
                        }
                    ]
                }
            ')
            
            service_template = @client.service_template.get("test", "service1", false)
            
            expect(service_template).to_not eq nil
            expect(service_template).to have_attributes(
                :id                     => 2, 
                :name                   => "service1",
                :command                => "ls",
                :command_args           => ["h", "l"],
                :normal_check_interval  => 5,
                :retry_check_interval   => 1,
                :max_check_attempts     => 3,
                :active_check_enabled   => "default",
                :passive_check_enabled  => "default",
                :is_activated           => true,
                # Bug centreon
                #:template               => "template1",
                #:note_url               => "http://localhost",
                #:action_url             => "http://127.0.0.1",
                #:comment                => "this is a test"
            )
            expect(service_template.host()).to_not eq nil
            expect(service_template.host().id()).to eq 1
            expect(service_template.host().name()).to eq "test"
            
            expect(service_template.macros().length).to eq 1
            expect(service_template.macros()[0].name()).to eq "macro1"
            expect(service_template.macros()[0].value()).to eq "foo"
            expect(service_template.macros()[0].is_password()).to eq false
            expect(service_template.macros()[0].description()).to eq "my macro 1"
            expect(service_template.macros()[0].source()).to eq "direct"
        end
        
        it "Test get when service not found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\",\"values\":\"service1\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            service = @client.service_template.get("test", "service1")
            
            expect(service).to eq nil
        end
        
        it "Test load" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"stpl","values":"test;service1;template|notes_url|action_url|comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "template": "template1",
                            "notes_url": "http://localhost",
                            "action_url": "http://127.0.0.1",
                            "comment": "this is a test"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"stpl","values":"test;service1"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "macro1",
                            "macro value": "foo",
                            "is_password": "0",
                            "description": "my macro 1",
                            "source": "direct"
                        }
                    ]
                }
            ')
            
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            service_template = Centreon::ServiceTemplate.new()
            service_template.set_name("service1")
            service_template.set_host(host_template)
            @client.service_template.load(service_template)
            
            
            expect(service_template).to_not eq nil
            expect(service_template).to have_attributes(
                :name                   => "service1",
                # Bug centreon
                #:template               => "template1",
                #:note_url               => "http://localhost",
                #:action_url             => "http://127.0.0.1",
                #:comment                => "this is a test"
            )
            expect(service_template.host()).to_not eq nil
            expect(service_template.host().name()).to eq "test"
            
            expect(service_template.macros().length).to eq 1
            expect(service_template.macros()[0].name()).to eq "macro1"
            expect(service_template.macros()[0].value()).to eq "foo"
            expect(service_template.macros()[0].is_password()).to eq false
            expect(service_template.macros()[0].description()).to eq "my macro 1"
            expect(service_template.macros()[0].source()).to eq "direct"

        end
        
        it "Test add" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\",\"values\":\"service1\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "host id": "1",
                            "host name": "test",
                            "id": "2",
                            "description": "service1",
                            "check command": "ls",
                            "check command arg": "!h!l",
                            "normal check interval": "5",
                            "retry check interval": "1",
                            "max check attempts": "3",
                            "active checks enabled": "2",
                            "passive checks enabled": "2",
                            "activate": "1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"add","object":"stpl","values":"test;service1;template1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;activate;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;check_command;ls"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;check_command_arguments;!l!h"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;max_check_attempts;3"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;normal_check_interval;5"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;retry_check_interval;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;active_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;passive_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;notes_url;http://localhost"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;action_url;http://127.0.0.1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"stpl","values":"test;service1;MACRO1;foo;0;my macro"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"addservice","object":"sg","values":"SG1;test,service1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            
            host = Centreon::HostTemplate.new()
            host.set_name("test")
            service_template = Centreon::ServiceTemplate.new()
            service_template.set_host(host)
            service_template.set_name("service1")
            service_template.set_command("ls")
            service_template.add_command_arg("l")
            service_template.add_command_arg("h")
            service_template.set_is_activated(true)
            service_template.set_template("template1")
            service_template.set_normal_check_interval(5)
            service_template.set_retry_check_interval(1)
            service_template.set_max_check_attempts(3)
            service_template.set_active_check_enabled("default")
            service_template.set_passive_check_enabled("default")
            service_template.set_note_url("http://localhost")
            service_template.set_action_url("http://127.0.0.1")
            service_template.set_comment("foo")
            
            
            macro = Centreon::Macro.new()
            macro.set_name("macro1")
            macro.set_value("foo")
            macro.set_is_password(false)
            macro.set_description("my macro")
            service_template.add_macro(macro)
            
            @client.service_template.add(service_template)
            expect(service_template.id()).to eq 2
        end
        
        it "Test delete" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"del","object":"stpl","values":"test;service1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            
            @client.service_template.delete("test", "service1")
        end
        
        
        it "Test update" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"stpl\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "host id": "1",
                            "host name": "test",
                            "id": "2",
                            "description": "service1",
                            "check command": "ls",
                            "check command arg": "!h!l",
                            "normal check interval": "5",
                            "retry check interval": "1",
                            "max check attempts": "3",
                            "active checks enabled": "2",
                            "passive checks enabled": "2",
                            "activate": "1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"add","object":"stpl","values":"test;service1;template1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;activate;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;check_command;ls"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;check_command_arguments;!l!h"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;max_check_attempts;3"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;normal_check_interval;5"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;retry_check_interval;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;active_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;passive_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;notes_url;http://localhost"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;action_url;http://127.0.0.1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"stpl","values":"test;service1;template;template1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"stpl","values":"test;service1;MACRO1;foo;0;my macro"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"addservice","object":"sg","values":"SG1;test,service1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"stpl","values":"test;service1"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"show","object":"sg"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "SG1",
                            "alias": "my sg 1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getservice","object":"sg","values":"SG1"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "host id": "1",
                            "host name": "test",
                            "service id": "3",
                            "service description": "service3"
                        }
                    ]
                }
            ')
            
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            service_template = Centreon::ServiceTemplate.new()
            service_template.set_host(host_template)
            service_template.set_name("service1")
            service_template.set_command("ls")
            service_template.add_command_arg("l")
            service_template.add_command_arg("h")
            service_template.set_is_activated(true)
            service_template.set_template("template1")
            service_template.set_normal_check_interval(5)
            service_template.set_retry_check_interval(1)
            service_template.set_max_check_attempts(3)
            service_template.set_active_check_enabled("default")
            service_template.set_passive_check_enabled("default")
            service_template.set_note_url("http://localhost")
            service_template.set_action_url("http://127.0.0.1")
            service_template.set_comment("foo")
            
            macro = Centreon::Macro.new()
            macro.set_name("macro1")
            macro.set_value("foo")
            macro.set_is_password(false)
            macro.set_description("my macro")
            service_template.add_macro(macro)
            
            @client.service_template.update(service_template)
        end

    end
end