# hm_centreon class permit to install require for centreon provider
class hm_centreon(
  Stdlib::Absolutepath $puppet_path,
) {

  @package {'gcc-c++':
    ensure => 'present',
  }

  realize(Package['gcc-c++'])

  # Only work on Puppet 6
  #package { 'rest-client':
  #  ensure   => 'present',
  #  name     => 'rest-client',
  #  provider => 'gem',
  #  command  => "${puppet_path}/bin/gem",
  #  require  => Package['gcc-c++'],
  #}
}