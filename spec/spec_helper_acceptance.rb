ENV['DOCKER_BUILDARGS'] = 'http_proxy=' + ENV['http_proxy'] + ' https_proxy=' + ENV['https_proxy']

require 'beaker-rspec'
require 'beaker-hiera'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
begin
  require 'puppet'
rescue TypeError
  puts 'Capture error about hiera'
end

hiera = <<-EOS
version: 5
defaults:
  datadir: /etc/puppetlabs/code/environments/production
  data_hash: yaml_data
hierarchy:
  - name: 'Per Operating System'
    glob: "hieradata/os/%{facts.os.family}/*.yaml"
  - name: 'Per environment'
    glob: "hieradata/environment/%{::environment}/*.yaml"
  - name: 'Module'
    paths:
      - "modules/%{module_name}/hieradata/%{::environment}.yaml"
      - "modules/%{module_name}/hieradata/common.yaml"
  - name: 'Common'
    glob: 'hieradata/*.yaml'
EOS

hosts.each do |host|
  # Proxy
  on host, "echo 'export http_proxy=" + ENV['http_proxy'] + "' >> /root/.bashrc"
  on host, "echo 'export https_proxy=" + ENV['https_proxy'] + "' >> /root/.bashrc"
  on host, "echo 'export no_proxy=\"" + ENV['no_proxy'] + ",#{host.name},10.221.78.61\"' >> /root/.bashrc"

  # Facts for role/profile
  on(host, 'mkdir -p /etc/puppetlabs/facter/facts.d')

  case Puppet.version.to_i
  when 4
    version_to_install = '1.' + Puppet.version.split('.')[1..-1] * '.'
    install_puppet_agent_on(host, version: version_to_install)
  when 5
    install_puppet_agent_on(host, version: Puppet.version, puppet_collection: 'puppet5')
  else
    puts 'unsupported puppet version'
    exit
  end

  install_module_dependencies_on(host)

  # Create hiera configs
  create_remote_file(host, '/etc/puppetlabs/puppet/hiera.yaml', hiera)
  create_remote_file(host, '/etc/puppetlabs/code/environments/production/hiera.yaml', hiera)
  on(host, 'mkdir -p /etc/puppetlabs/code/environments/production/hieradata', acceptable_exit_codes: [0]).stdout
end

RSpec.configure do |c|
  # module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  # hiera_file = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
  # hiera_folder = File.expand_path(File.join(__FILE__, '../fixtures/hieradata'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configuire all nodes in nodeset
  c.before :suite do
    # Install module
    # puppet_module_install(:source => module_root, :module_name => 'hm_profile')

    hosts.each do |host|
      # scp_to(host, hiera_file, '/etc/puppetlabs/puppet/hiera.yaml')
      # scp_to(host, '/tmp/puppet/hieradata', '/etc/puppetlabs/code')
      # scp_to(host, '/tmp/puppet/modules', '/etc/puppetlabs/code')
      on(host, '/opt/puppetlabs/puppet/bin/gem install rest-client webmock')
      scp_to(host, File.expand_path(File.join(__FILE__, '../fixtures/puppetlabs_centreon_configuration.ini')), '/etc/puppetlabs/puppet/puppetlabs_centreon_configuration.ini')
    end
  end
end
