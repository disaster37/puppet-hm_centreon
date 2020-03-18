require 'spec_helper_acceptance'
require 'webmock/rspec'

apply_manifest_opts = {
  catch_failures: true,
  debug: true,
  trace: true,
}



describe 'Centreon host group resource:' do
  before do
    
  end
  
  describe 'With minimal parameter' do
    it 'deploys successfully' do
      
      pp = <<-EOS
        centreon_host_group{'test':
        }
      EOS
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 2
      
      result = apply_manifest(pp, apply_manifest_opts)
      expect(result.exit_code).to eq 0
    end
  end
end