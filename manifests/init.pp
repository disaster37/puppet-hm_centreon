# hm_centreon class permit to install require for centreon provider
class hm_centreon(
  Stdlib::Absolutepath $puppet_path,
) {

  @package {'gcc-c++':
    ensure => 'present',
  }

  realize(Package['gcc-c++'])

  package { 'rest-client':
    ensure   => 'present',
    provider => 'gem',
    command  => "${puppet_path}/bin/gem",
    require  => Package['gcc-c++'],
  }
}