require 'webmock/rspec'

require_relative './api.rb'


RSpec.describe 'Test Centreon::Client::HostTemplate' do
    
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
        
        it "Test fetch when host template" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"htpl\"}").
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
            
            host_templates = @client.host_template.fetch()
            
            expect(host_templates.length).to eq 1
            expect(host_templates[0]).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :description    => "test app",
                :address        => "127.0.0.1",
                :is_activated   => true
            )
        end

        
        it "Test fetch when no host template" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"htpl\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            host_templates = @client.host_template.fetch()
            
            expect(host_templates.length).to eq 0
        end
        
        it "Test fetch when no lazzy" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"htpl\"}").
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
            with(body: '{"action":"gettemplate","object":"htpl","values":"test"}').
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
            with(body: '{"action":"gethostgroup","object":"htpl","values":"test"}').
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
            with(body: '{"action":"showinstance","object":"htpl","values":"test"}').
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
            with(body: '{"action":"getmacro","object":"htpl","values":"test"}').
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
            with(body: '{"action":"getparam","object":"htpl","values":"test;comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "comment": "foo"
                        }
                    ]
                }
            ')
            
            host_templates = @client.host_template.fetch(name = nil, lazzy = false)
            
            expect(host_templates.length).to eq 1
            expect(host_templates[0]).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :description    => "test app",
                :address        => "127.0.0.1",
                :is_activated   => true,
                :poller         => "poller1",
            )
            
            expect(host_templates[0].templates().length).to eq 1
            expect(host_templates[0].templates()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HT_TEST"
            )
            
            expect(host_templates[0].groups().length).to eq 1
            expect(host_templates[0].groups()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HG_TEST"
            )
            
            expect(host_templates[0].macros().length).to eq 1
            expect(host_templates[0].macros()[0]).to have_attributes(
                :name           => "warning",
                :value          => "10",
                :is_password    => false,
                :description    => "Threshold warning"
            )
        end
        
        
        
        it "Test get when host template found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"htpl\",\"values\":\"test\"}").
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
            with(body: '{"action":"gettemplate","object":"htpl","values":"test"}').
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
            with(body: '{"action":"gethostgroup","object":"htpl","values":"test"}').
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
            with(body: '{"action":"showinstance","object":"htpl","values":"test"}').
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
            with(body: '{"action":"getmacro","object":"htpl","values":"test"}').
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
            with(body: '{"action":"getparam","object":"htpl","values":"test;comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "comment": "foo"
                        }
                    ]
                }
            ')
            
            host_template = @client.host_template.get("test", false)
            
            expect(host_template).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :description    => "test app",
                :address        => "127.0.0.1",
                :is_activated   => true,
                :poller         => "poller1",
            )
            
            expect(host_template.templates().length).to eq 1
            expect(host_template.templates()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HT_TEST"
            )
            
            expect(host_template.groups().length).to eq 1
            expect(host_template.groups()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HG_TEST"
            )
            
            expect(host_template.macros().length).to eq 1
            expect(host_template.macros()[0]).to have_attributes(
                :name           => "warning",
                :value          => "10",
                :is_password    => false,
                :description    => "Threshold warning"
            )
        end
        
        it "Test get when host template not found" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"htpl\",\"values\":\"test\"}").
            to_return(status: 200, body:'
                {
                    "result": [
                    ]
                }
            ')
            
            host_template = @client.host_template.get("test")
            
            expect(host_template).to eq nil
    
        end
        
        
        it "Test load when host template found" do
            
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"gettemplate","object":"htpl","values":"test"}').
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
            with(body: '{"action":"gethostgroup","object":"htpl","values":"test"}').
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
            with(body: '{"action":"showinstance","object":"htpl","values":"test"}').
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
            with(body: '{"action":"getmacro","object":"htpl","values":"test"}').
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
            with(body: '{"action":"getparam","object":"htpl","values":"test;comment"}').
            to_return(status: 200, body:'
                {
                    "result": [
                        {
                            "comment": "foo"
                        }
                    ]
                }
            ')
            host_template = Centreon::HostTemplate.new()
            host_template.set_id(82)
            host_template.set_name("test")
            host_template.set_address("127.0.0.1")
            
            @client.host_template.load(host_template)
            
            expect(host_template).to have_attributes(
                :id             => 82, 
                :name           => "test",
                :address        => "127.0.0.1",
                :poller         => "poller1",
            )
            
            expect(host_template.templates().length).to eq 1
            expect(host_template.templates()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HT_TEST"
            )
            
            expect(host_template.groups().length).to eq 1
            expect(host_template.groups()[0]).to have_attributes(
                :id             => 1, 
                :name           => "HG_TEST"
            )
            
            expect(host_template.macros().length).to eq 1
            expect(host_template.macros()[0]).to have_attributes(
                :name           => "warning",
                :value          => "10",
                :is_password    => false,
                :description    => "Threshold warning"
            )
        end
        
        it "Test add host template" do
            
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"add","object":"htpl","values":"test;my description;127.0.0.1;HT1|HT2;poller1;HG1|HG2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"htpl","values":"test;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;foo;0;"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"applytpl","object":"htpl","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: "{\"action\":\"show\",\"object\":\"htpl\",\"values\":\"test\"}").
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
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            host_template.set_description("my description")
            host_template.set_comment("foo")
            host_template.set_address("127.0.0.1")
            host_template.set_poller("poller1")
            hg1 = Centreon::HostGroup.new()
            hg1.set_name("HG1")
            host_template.add_group(hg1)
            hg2 = Centreon::HostGroup.new()
            hg2.set_name("HG2")
            host_template.add_group(hg2)
            ht1 = Centreon::HostTemplate.new()
            ht1.set_name("HT1")
            host_template.add_template(ht1)
            ht2 = Centreon::HostTemplate.new()
            ht2.set_name("HT2")
            host_template.add_template(ht2)
            macro1 = Centreon::Macro.new()
            macro1.set_name("macro1")
            macro1.set_value("foo")
            host_template.add_macro(macro1)
            host_template.set_is_activated(true)
            
            @client.host_template.add(host_template)
            expect(host_template.id()).to eq 82
        end
        
        it "Test update host template" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"htpl","values":"test;alias;my description"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setparam","object":"htpl","values":"test;comment;foo"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"disable","object":"htpl","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setinstance","object":"htpl","values":"test;poller1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;value;0;"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"settemplate","object":"htpl","values":"test;HT1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"sethostgroup","object":"htpl","values":"test;HG1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"applytpl","object":"htpl","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"getmacro","object":"htpl","values":"test"}').
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
            with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;foo;0;"}').
            to_return(status: 200, body:'
                {
                }
            ')
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"delmacro","object":"htpl","values":"test;old"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            host_template.set_poller("poller1")
            host_template.set_description("my description")
            host_template.set_comment("foo")
            host_group = Centreon::HostGroup.new()
            host_group.set_name("HG1")
            host_template.add_group(host_group)
            ht = Centreon::HostTemplate.new()
            ht.set_name("HT1")
            host_template.add_template(ht)
            macro1 = Centreon::Macro.new()
            macro1.set_name("macro1")
            macro1.set_value("foo")
            host_template.add_macro(macro1)
            
            @client.host_template.update(host_template)
            
        end
        
        it "Test delete host template" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"del","object":"htpl","values":"test"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            @client.host_template.delete("test")
        end
        
        it "Test add_templates" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"addtemplate","object":"htpl","values":"test;HT1|HT2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            host_template1 = Centreon::HostTemplate.new()
            host_template1.set_name("HT1")
            host_template.add_template(host_template1)
            host_template2 = Centreon::HostTemplate.new()
            host_template2.set_name("HT2")
            host_template.add_template(host_template2)
            
            @client.host_template.add_templates(host_template)
        end
        
        it "Test delete_templates" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"deltemplate","object":"htpl","values":"test;HT1|HT2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            host_template1 = Centreon::HostTemplate.new()
            host_template1.set_name("HT1")
            host_template.add_template(host_template1)
            host_template2 = Centreon::HostTemplate.new()
            host_template2.set_name("HT2")
            host_template.add_template(host_template2)
            
            @client.host_template.delete_templates(host_template)
        end
        
        it "Test add_groups" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"addhostgroup","object":"htpl","values":"test;HG1|HG2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            host_group1 = Centreon::HostGroup.new()
            host_group1.set_name("HG1")
            host_template.add_group(host_group1)
            host_group2 = Centreon::HostGroup.new()
            host_group2.set_name("HG2")
            host_template.add_group(host_group2)
            
            @client.host_template.add_groups(host_template)
        end
        
        it "Test delete_groups" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"delhostgroup","object":"htpl","values":"test;HG1|HG2"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            host_group1 = Centreon::HostGroup.new()
            host_group1.set_name("HG1")
            host_template.add_group(host_group1)
            host_group2 = Centreon::HostGroup.new()
            host_group2.set_name("HG2")
            host_template.add_group(host_group2)
            
            @client.host_template.delete_groups(host_template)
        end
        
        it "Test add_macros" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"setmacro","object":"htpl","values":"test;MACRO1;value;0;my macro"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            macro = Centreon::Macro.new()
            macro.set_name("MACRO1")
            macro.set_value("value")
            macro.set_description("my macro")
            macro.set_is_password(false)
            host_template.add_macro(macro)
            
            @client.host_template.add_macros(host_template)
        end
        
        it "Test delete_macros" do
            stub_request(:post, "localhost/centreon/api/index.php?action=action&object=centreon_clapi").
            with(body: '{"action":"delmacro","object":"htpl","values":"test;MACRO1"}').
            to_return(status: 200, body:'
                {
                }
            ')
            
            host_template = Centreon::HostTemplate.new()
            host_template.set_name("test")
            macro = Centreon::Macro.new()
            macro.set_name("MACRO1")
            macro.set_value("value")
            macro.set_description("my macro")
            macro.set_is_password(false)
            host_template.add_macro(macro)
            
            @client.host_template.delete_macros(host_template)
        end

    end
end