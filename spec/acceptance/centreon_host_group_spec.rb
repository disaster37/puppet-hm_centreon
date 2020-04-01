require 'spec_helper_acceptance'
require 'webmock/rspec'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'Centreon host group resource:' do
  before(:each) do
  end

  describe 'Manage With minimal parameter' do
    it 'create successfully' do
      pp = <<-EOS
        centreon_host_group{'test_rspec':
          ensure => 'present'
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
        centreon_host_group{'test_rspec2':
          ensure      => 'present',
          description => 'my HG',
          comment     => 'Managed by puppet',
          note        => 'this is my note',
          note_url    => 'http://localhost/note',
          action_url  => 'http://localhost/action',
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
        centreon_host_group{'test_rspec':
          ensure      => 'absent',
        }
        centreon_host_group{'test_rspec2':
          ensure      => 'absent',
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
    end
  end
end
