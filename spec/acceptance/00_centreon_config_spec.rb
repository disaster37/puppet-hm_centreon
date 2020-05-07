require 'spec_helper_acceptance'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}

describe 'Centreon Config defined type:' do
  before(:each) do
  end

  describe 'Collect all resources' do
    it 'create successfully' do
      pp = <<-EOS
        hm_centreon::centreon_backend{'default':
          url      => 'http://centreon/centreon/api/index.php',
          username => 'admin',
          password => Sensitive('admin')
        }
      EOS

      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 0
    end
  end
end
