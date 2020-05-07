require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'Centreon host in host template resource:' do
  describe 'Manage With all parameter' do
    it 'create successfully' do
      pp = <<-EOS
        centreon_host{'test':
          ensure  => 'present',
          address => '127.0.0.1',
          poller  => 'Central'
        }
        centreon_host_template{'HT_TEST':
          ensure => 'present'
        }
        centreon_host_in_host_template{'test_rspec':
          ensure     => 'present',
          host       => 'test',
          templates  => ['HT_TEST'],
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
        centreon_host_template{'HT_TEST':
          ensure => 'present'
        }
        centreon_host_template{'HT_TEST2':
          ensure => 'present'
        }
        centreon_host_in_host_template{'test_rspec':
          ensure     => 'present',
          host       => 'test',
          templates  => ['HT_TEST', 'HT_TEST2'],
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
        centreon_host{'test':
          ensure  => 'present',
          address => '127.0.0.1',
          poller  => 'Central'
        }
        centreon_host_template{'HT_TEST':
          ensure => 'present'
        }
        centreon_host_template{'HT_TEST2':
          ensure => 'present'
        }
        centreon_host_in_host_template{'test_rspec':
          ensure     => 'absent',
          host       => 'test',
          templates  => ['HT_TEST', 'HT_TEST2'],
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end
  end
end
