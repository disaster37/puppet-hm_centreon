require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'Centreon service resource:' do
  describe 'Manage With minimal parameter' do
    it 'create successfully' do
      pp = <<-EOS
        centreon_host{'test':
          ensure  => 'present',
          address => '127.0.0.1',
          poller  => 'Central'
        }
        centreon_service{'test|test_rspec':
          ensure  => 'present',
          template => 'ST1',
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
        centreon_host{'test':
          ensure  => 'present',
          address => '127.0.0.1',
          poller  => 'Central'
        }
        centreon_command{'ping':
            ensure => 'present',
            type   => 'check',
            line   => 'ping'
        }
        centreon_service_group{'SG1':
          ensure => 'present'
        }
        centreon_service_template{'ST1':
          ensure      => 'present',
          description => 'ST1'
        }
        centreon_service{'test|test_rspec2':
          ensure                => 'present',
          enable                => true,
          command               => 'ping',
          command_args          => ['arg1'],
          template              => 'ST1',
          normal_check_interval => 10,
          retry_check_interval  => 1,
          max_check_attempts    => 3,
          active_check          => 'true',
          passive_check         => 'true',
          note                  => 'this is my note',
          note_url              => 'http://localhost/note',
          action_url            => 'http://localhost/action',
          comment               => 'Managed by puppet',
          check_period          => 'none',
          is_volatile           => 'false',
          groups                => ['SG1'],
          macros                => [
              {
                  name  => 'MACRO1',
                  value => 'foo',
              }
          ],
          categories            => ['Ping'],
          service_traps         => ['brDatabaseFull']
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
        centreon_host{'test':
          ensure  => 'present',
          address => '127.0.0.1',
          poller  => 'Central'
        }
        centreon_command{'ping':
            ensure => 'present',
            type   => 'check',
            line   => 'ping'
        }
        centreon_service_group{'SG1':
          ensure => 'present'
        }
        centreon_service_template{'ST1':
          ensure      => 'present',
          description => 'ST1'
        }
        centreon_service{'test|test_rspec':
          ensure                => 'present',
          enable                => true,
          command               => 'ping',
          command_args          => ['arg1'],
          template              => 'ST1',
          normal_check_interval => 10,
          retry_check_interval  => 1,
          max_check_attempts    => 3,
          active_check          => 'true',
          passive_check         => 'true',
          note                  => 'this is my note',
          note_url              => 'http://localhost/note',
          action_url            => 'http://localhost/action',
          comment               => 'Managed by puppet',
          check_period          => 'none',
          is_volatile           => 'false',
          groups                => ['SG1'],
          macros                => [
              {
                  name  => 'MACRO1',
                  value => 'foo',
              }
          ],
          categories            => ['Ping'],
          service_traps         => ['brDatabaseFull']
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
        centreon_service{'test|test_rspec':
          ensure      => 'absent',
        }
        centreon_service{'test|test_rspec2':
          ensure      => 'absent',
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end
  end
end
