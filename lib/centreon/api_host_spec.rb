require 'webmock/rspec'

require_relative './api.rb'


RSpec.describe 'Test Centreon::Client::Host' do
    
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
            expect(@client.host).to_not eq nil
        end
        
        it "Test fetch when host" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"host\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "82",
                            "name": "test",
                            "alias": "test app",
                            "address": "127.0.0.1",
                            "activate": "1"
                        }
                    ]
                }
            ')
            
            hosts = @client.host.fetch()
            
            expect(hosts.length).to eq 1
            expect(hosts[0]).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :description    => "test app",
                :address        => "127.0.0.1",
                :is_activated   => true
            )
        end

        
        it "Test fetch when no host" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"host\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            hosts = @client.host.fetch()
            
            expect(hosts.length).to eq 0
        end
        
        it "Test fetch when no lazzy" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"host\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "82",
                            "name": "test",
                            "alias": "test app",
                            "address": "127.0.0.1",
                            "activate": "1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gettemplate","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "HT_TEST"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gethostgroup","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "HG_TEST"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"showinstance","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "poller1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "warning",
                            "macro value": "10",
                            "is_password": "0",
                            "description": "Threshold warning",
                            "source": "direct"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"host","values":"test;comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "comment": "foo"
                        }
                    ]
                }
            ')
            
            hosts = @client.host.fetch(name = nil, lazzy = false)
            
            expect(hosts.length).to eq 1
            expect(hosts[0]).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :description    => "test app",
                :address        => "127.0.0.1",
                :is_activated   => true,
                :poller         => "poller1",
            )
            
            expect(hosts[0].templates().length).to eq 1
            expect(hosts[0].templates()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HT_TEST"
            )
            
            expect(hosts[0].groups().length).to eq 1
            expect(hosts[0].groups()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HG_TEST"
            )
            
            expect(hosts[0].macros().length).to eq 1
            expect(hosts[0].macros()[0]).to have_attributes(
                :name           => "warning",
                :value          => "10",
                :is_password    => false,
                :description    => "Threshold warning"
            )
        end
        
        
        
        it "Test get when host found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"host\",\"values\":\"test\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "82",
                            "name": "test",
                            "alias": "test app",
                            "address": "127.0.0.1",
                            "activate": "1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gettemplate","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "HT_TEST"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gethostgroup","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "HG_TEST"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"showinstance","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "poller1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "warning",
                            "macro value": "10",
                            "is_password": "0",
                            "description": "Threshold warning",
                            "source": "direct"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"host","values":"test;comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "comment": "foo"
                        }
                    ]
                }
            ')
            
            host = @client.host.get("test", false)
            
            expect(host).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :description    => "test app",
                :address        => "127.0.0.1",
                :is_activated   => true,
                :poller         => "poller1",
            )
            
            expect(host.templates().length).to eq 1
            expect(host.templates()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HT_TEST"
            )
            
            expect(host.groups().length).to eq 1
            expect(host.groups()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HG_TEST"
            )
            
            expect(host.macros().length).to eq 1
            expect(host.macros()[0]).to have_attributes(
                :name           => "warning",
                :value          => "10",
                :is_password    => false,
                :description    => "Threshold warning"
            )
        end
        
        it "Test get when host not found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"host\",\"values\":\"test\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            host = @client.host.get("test")
            
            expect(host).to eq nil
    
        end
        
        
        it "Test load when host found" do
            
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gettemplate","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "HT_TEST"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gethostgroup","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "HG_TEST"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"showinstance","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "1",
                            "name": "poller1"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "warning",
                            "macro value": "10",
                            "is_password": "0",
                            "description": "Threshold warning",
                            "source": "direct"
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getparam","object":"host","values":"test;comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "comment": "foo"
                        }
                    ]
                }
            ')
            host = Centreon::Host.new()
            host.set_id(82)
            host.set_name("test")
            host.set_address("127.0.0.1")
            
            @client.host.load(host)
            
            expect(host).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :address        => "127.0.0.1",
                :poller         => "poller1",
            )
            
            expect(host.templates().length).to eq 1
            expect(host.templates()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HT_TEST"
            )
            
            expect(host.groups().length).to eq 1
            expect(host.groups()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HG_TEST"
            )
            
            expect(host.macros().length).to eq 1
            expect(host.macros()[0]).to have_attributes(
                :name           => "warning",
                :value          => "10",
                :is_password    => false,
                :description    => "Threshold warning"
            )
        end
        
        it "Test add host" do
            
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"add","object":"host","values":"test;my description;127.0.0.1;HT1|HT2;poller1;HG1|HG2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"host","values":"test;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;foo;0;"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"applytpl","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"host\",\"values\":\"test\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "id": "82",
                            "name": "test",
                            "alias": "my description",
                            "address": "127.0.0.1",
                            "activate": "1"
                        }
                    ]
                }
            ')
            
            host = Centreon::Host.new()
            host.set_name("test")
            host.set_description("my description")
            host.set_comment("foo")
            host.set_address("127.0.0.1")
            host.set_poller("poller1")
            hg1 = Centreon::HostGroup.new()
            hg1.set_name("HG1")
            host.add_group(hg1)
            hg2 = Centreon::HostGroup.new()
            hg2.set_name("HG2")
            host.add_group(hg2)
            ht1 = Centreon::HostTemplate.new()
            ht1.set_name("HT1")
            host.add_template(ht1)
            ht2 = Centreon::HostTemplate.new()
            ht2.set_name("HT2")
            host.add_template(ht2)
            macro1 = Centreon::Macro.new()
            macro1.set_name("macro1")
            macro1.set_value("foo")
            host.add_macro(macro1)
            host.set_is_activated(true)
            
            @client.host.add(host)
            expect(host.id()).to eq 82
        end
        
        it "Test update host" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"host","values":"test;alias;my description"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"host","values":"test;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"disable","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setinstance","object":"host","values":"test;poller1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;value;0;"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"settemplate","object":"host","values":"test;HT1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"sethostgroup","object":"host","values":"test;HG1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"applytpl","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "macro name": "old",
                            "macro value": "foo",
                            "is_password": "0",
                            "description": ""
                        }
                    ]
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"host","values":"test;MACRO1;foo;0;"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"delmacro","object":"host","values":"test;old"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host = Centreon::Host.new()
            host.set_name("test")
            host.set_poller("poller1")
            host.set_description("my description")
            host.set_comment("foo")
            host_group = Centreon::HostGroup.new()
            host_group.set_name("HG1")
            host.add_group(host_group)
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("HT1")
            host.add_template(host_template)
            macro1 = Centreon::Macro.new()
            macro1.set_name("macro1")
            macro1.set_value("foo")
            host.add_macro(macro1)
            
            @client.host.update(host)
            
        end
        
        it "Test delete host" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"del","object":"host","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            @client.host.delete("test")
        end

    end
end