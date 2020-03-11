require 'webmock/rspec'

require_relative './api.rb'


RSpec.describe 'Test Centreon::Client' do
    
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
            expect(@client.service).to_not eq nil
        end
        
        it "Test fetch when service" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
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
            
            services = @client.service.fetch()
            
            expect(services.length).to eq 1
            expect(services[0]).to have_attributes(
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
            expect(services[0].host()).to_not eq nil
            expect(services[0].host().id()).to eq 1
            expect(services[0].host().name()).to eq "test"
        end
        
        it "Test fetch when no service" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            services = @client.service.fetch()
            
            expect(services.length).to eq 0
        end
        
        
        it "Test fetch when no lazzy" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
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
            with(body: '{"action":"getparam","object":"service","values":"test;service1;template|notes_url|action_url|comment"}').
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
            with(body: '{"action":"getmacro","object":"service","values":"test;service1"}').
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
                            "service id": "2",
                            "service description": "service1"
                        },
                        {
                            "host id": "1",
                            "host name": "test",
                            "service id": "3",
                            "service description": "service3"
                        }
                    ]
                }
            ')
            
            services = @client.service.fetch(false)
            
            expect(services.length).to eq 1
            expect(services[0]).to have_attributes(
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
                :template               => "template1",
                :note_url               => "http://localhost",
                :action_url             => "http://127.0.0.1",
                :comment                => "this is a test"
            )
            expect(services[0].host()).to_not eq nil
            expect(services[0].host().id()).to eq 1
            expect(services[0].host().name()).to eq "test"
            
            expect(services[0].macros().length).to eq 1
            expect(services[0].macros()[0].name()).to eq "macro1"
            expect(services[0].macros()[0].value()).to eq "foo"
            expect(services[0].macros()[0].is_password()).to eq false
            expect(services[0].macros()[0].description()).to eq "my macro 1"
            expect(services[0].macros()[0].source()).to eq "direct"
            
            expect(services[0].groups().length).to eq 1
            expect(services[0].groups()[0].name()).to eq "SG1"
            expect(services[0].groups()[0].id()).to eq 1
            expect(services[0].groups()[0].description()).to eq "my sg 1"
        end
        
        it "Test get when service found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
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
            with(body: '{"action":"getparam","object":"service","values":"test;service1;template|notes_url|action_url|comment"}').
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
            with(body: '{"action":"getmacro","object":"service","values":"test;service1"}').
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
                            "service id": "2",
                            "service description": "service1"
                        },
                        {
                            "host id": "1",
                            "host name": "test",
                            "service id": "3",
                            "service description": "service3"
                        }
                    ]
                }
            ')
            
            service = @client.service.get("test", "service1", false)
            
            expect(service).to_not eq nil
            expect(service).to have_attributes(
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
                :template               => "template1",
                :note_url               => "http://localhost",
                :action_url             => "http://127.0.0.1",
                :comment                => "this is a test"
            )
            expect(service.host()).to_not eq nil
            expect(service.host().id()).to eq 1
            expect(service.host().name()).to eq "test"
            
            expect(service.macros().length).to eq 1
            expect(service.macros()[0].name()).to eq "macro1"
            expect(service.macros()[0].value()).to eq "foo"
            expect(service.macros()[0].is_password()).to eq false
            expect(service.macros()[0].description()).to eq "my macro 1"
            expect(service.macros()[0].source()).to eq "direct"
            
            expect(service.groups().length).to eq 1
            expect(service.groups()[0].name()).to eq "SG1"
            expect(service.groups()[0].id()).to eq 1
            expect(service.groups()[0].description()).to eq "my sg 1"
        end
        
        it "Test get when service not found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            service = @client.service.get("test", "service1")
            
            expect(service).to eq nil
        end
        
        it "Test load" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"service","values":"test;service1;template|notes_url|action_url|comment"}').
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
            with(body: '{"action":"getmacro","object":"service","values":"test;service1"}').
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
            
            
            host = Centreon::Host.new()
            host.set_name("test")
            service = Centreon::Service.new()
            service.set_name("service1")
            service.set_host(host)
            @client.service.load(service)
            
            
            expect(service).to_not eq nil
            expect(service).to have_attributes(
                :name                   => "service1",
                :template               => "template1",
                :note_url               => "http://localhost",
                :action_url             => "http://127.0.0.1",
                :comment                => "this is a test"
            )
            expect(service.host()).to_not eq nil
            expect(service.host().name()).to eq "test"
            
            expect(service.macros().length).to eq 1
            expect(service.macros()[0].name()).to eq "macro1"
            expect(service.macros()[0].value()).to eq "foo"
            expect(service.macros()[0].is_password()).to eq false
            expect(service.macros()[0].description()).to eq "my macro 1"
            expect(service.macros()[0].source()).to eq "direct"

        end
        
        it "Test add" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
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
            with(body: '{"action":"add","object":"service","values":"test;service1;template1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;activate;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command;ls"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command_arguments;!l!h"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;max_check_attempts;3"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;normal_check_interval;5"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;retry_check_interval;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;active_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;passive_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;notes_url;http://localhost"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;action_url;http://127.0.0.1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"service","values":"test;service1;MACRO1;foo;0;my macro"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"addservice","object":"sg","values":"SG1;test;service1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            
            host = Centreon::Host.new()
            host.set_name("test")
            service = Centreon::Service.new()
            service.set_host(host)
            service.set_name("service1")
            service.set_command("ls")
            service.add_command_arg("l")
            service.add_command_arg("h")
            service.set_is_activated(true)
            service.set_template("template1")
            service.set_normal_check_interval(5)
            service.set_retry_check_interval(1)
            service.set_max_check_attempts(3)
            service.set_active_check_enabled("default")
            service.set_passive_check_enabled("default")
            service.set_note_url("http://localhost")
            service.set_action_url("http://127.0.0.1")
            service.set_comment("foo")
            
            service_group = Centreon::ServiceGroup.new()
            service_group.set_name("SG1")
            service.add_group(service_group)
            
            macro = Centreon::Macro.new()
            macro.set_name("macro1")
            macro.set_value("foo")
            macro.set_is_password(false)
            macro.set_description("my macro")
            service.add_macro(macro)
            
            @client.service.add(service)
            expect(service.id()).to eq 2
        end
        
        it "Test delete" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"del","object":"service","values":"test;service1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            
            @client.service.delete("test", "service1")
        end
        
        it "Test fetch_service_group" do
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
                            "service id": "2",
                            "service description": "service1"
                        },
                        {
                            "host id": "1",
                            "host name": "test",
                            "service id": "3",
                            "service description": "service3"
                        }
                    ]
                }
            ')
            
            service_groups = @client.service.fetch_service_group()
            expect(service_groups.length).to eq 1
            expect(service_groups[0].name()).to eq "SG1"
            expect(service_groups[0].id()).to eq 1
            expect(service_groups[0].description()).to eq "my sg 1"
            expect(service_groups[0].services().length).to eq 2
            expect(service_groups[0].services()[0].host.name()).to eq "test"
            expect(service_groups[0].services()[0].host.id()).to eq 1
            expect(service_groups[0].services()[0].name()).to eq "service1"
            expect(service_groups[0].services()[0].id()).to eq 2
            
            host = Centreon::Host.new()
            host.set_id(1)
            host.set_name("test")
            service = Centreon::Service.new()
            service.set_host(host)
            service.set_id(3)
            service.set_name("service3")
            @client.service.fetch_service_group([service])
            expect(service.groups().length).to eq 1
            expect(service.groups()[0].name()).to eq "SG1"
            expect(service.groups()[0].id()).to eq 1
            expect(service.groups()[0].description()).to eq "my sg 1"
        end
        
        it "Test update" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"service\"}").
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
            with(body: '{"action":"add","object":"service","values":"test;service1;template1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;activate;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command;ls"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;check_command_arguments;!l!h"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;max_check_attempts;3"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;normal_check_interval;5"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;retry_check_interval;1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;active_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;passive_checks_enabled;2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;notes_url;http://localhost"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;action_url;http://127.0.0.1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"service","values":"test;service1;template;template1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"service","values":"test;service1;MACRO1;foo;0;my macro"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"addservice","object":"sg","values":"SG1;test;service1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"service","values":"test;service1"}').
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
            
            
            host = Centreon::Host.new()
            host.set_name("test")
            service = Centreon::Service.new()
            service.set_host(host)
            service.set_name("service1")
            service.set_command("ls")
            service.add_command_arg("l")
            service.add_command_arg("h")
            service.set_is_activated(true)
            service.set_template("template1")
            service.set_normal_check_interval(5)
            service.set_retry_check_interval(1)
            service.set_max_check_attempts(3)
            service.set_active_check_enabled("default")
            service.set_passive_check_enabled("default")
            service.set_note_url("http://localhost")
            service.set_action_url("http://127.0.0.1")
            service.set_comment("foo")
            
            service_group = Centreon::ServiceGroup.new()
            service_group.set_name("SG1")
            service.add_group(service_group)
            
            macro = Centreon::Macro.new()
            macro.set_name("macro1")
            macro.set_value("foo")
            macro.set_is_password(false)
            macro.set_description("my macro")
            service.add_macro(macro)
            
            @client.service.update(service)
        end

    end
end