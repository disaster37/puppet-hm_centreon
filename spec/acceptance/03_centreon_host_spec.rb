require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'Centreon host resource:' do
  describe 'Manage With minimal parameter' do
    it 'create successfully' do
      pp = <<-EOS
        centreon_host{'test_rspec':
          ensure  => 'present',
          address => '127.0.0.1',
          poller  => 'Central'
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2

      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 0
    end
  end

  describe 'Manage With all parameter' do
    it 'create successfully' do
      pp = <<-EOS
        centreon_host_template{'HT_TEST':
          ensure => 'present'
        }
        centreon_host_group{'HG_TEST':
          ensure => 'present'
        }
        centreon_host{'test_rspec2':
          ensure               => 'present',
          enable               => true,
          address              => '127.0.0.1',
          poller               => 'Central',
          description          => 'my host',
          comment              => 'Managed by puppet',
          templates            => ['HT_TEST'],
          groups               => ['HG_TEST'],
          macros               => [
              {
                  name  => 'MACRO1',
                  value => 'foo',
              }
          ],
          snmp_community       => 'public',
          snmp_version         => '2c',
          timezone             => 'Europe/Paris',
          check_command        => 'ping',
          check_command_args   => ['arg1'],
          check_interval       => 10,
          retry_check_interval => 1,
          max_check_attempts   => 3,
          check_period         => 'none',
          active_check         => 'true',
          passive_check        => 'true',
          note                 => 'this is my note',
          note_url             => 'http://localhost/note',
          action_url           => 'http://localhost/action',
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2

      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 0
    end
  end

  describe 'Update' do
    it 'update successfully' do
      pp = <<-EOS
        centreon_host_template{'HT_TEST':
          ensure => 'present'
        }
        centreon_host_group{'HG_TEST':
          ensure => 'present'
        }
        centreon_host{'test_rspec':
          ensure               => 'present',
          enable               => true,
          address              => '127.0.0.1',
          poller               => 'Central',
          description          => 'my host',
          comment              => 'Managed by puppet',
          templates            => ['HT_TEST'],
          groups               => ['HG_TEST'],
          macros               => [
              {
                  name  => 'MACRO1',
                  value => 'foo',
              }
          ],
          snmp_community       => 'public',
          snmp_version         => '2c',
          timezone             => 'Europe/Paris',
          check_command        => 'ping',
          check_command_args   => ['arg1'],
          check_interval       => 10,
          retry_check_interval => 1,
          max_check_attempts   => 3,
          check_period         => 'none',
          active_check         => 'true',
          passive_check        => 'true',
          note                 => 'this is my note',
          note_url             => 'http://localhost/note',
          action_url           => 'http://localhost/action',
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2

      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 0
    end
  end

  describe 'Destroy' do
    it 'destroy successfully' do
      pp = <<-EOS
        centreon_host{'test_rspec':
          ensure      => 'absent',
        }
        centreon_host{'test_rspec2':
          ensure      => 'absent',
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end
  end
end
