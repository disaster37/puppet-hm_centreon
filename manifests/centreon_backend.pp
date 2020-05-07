# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   hm_centreon::centreon_backend { 'namevar': }
define hm_centreon::centreon_backend (
  Stdlib::HTTPUrl   $url,
  String            $username,
  Sensitive[String] $password,
  Optional[String]  $poller = undef,
  Boolean           $collect_host       = true,
  Boolean           $collect_host_group = true,
  Boolean           $collect_host_template = true,
  Boolean           $collect_service = true,
  Boolean           $collect_service_template = true,
  Boolean           $collect_service_group = true,
  Boolean           $collect_command = true,
) {

  include hm_centreon

  centreon{$name:
    url      => $url,
    username => $username,
    password => $password
  }

  if $collect_host {
    if $poller == undef {
      Centreon_host <<| config == $name |>> {}
    } else {
      Centreon_host <<| config == $name |>> {
        poller => $poller
      }
    }

    Centreon_host_in_host_template <<| config == $name |>>
    Centreon_host_in_host_group <<| config == $name |>>
    Centreon_host_with_macro <<| config == $name |>>
  }

  if $collect_host_group {
    Centreon_host_group <<| config == $name |>>
  }

  if $collect_host_template {
    Centreon_host_template <<| config == $name |>>
  }

  if $collect_service {
    Centreon_service <<| config == $name |>>
  }

  if $collect_service_group {
    Centreon_service_group <<| config == $name |>>
  }

  if $collect_service_template {
    Centreon_service_template <<| config == $name |>>
  }

  if $collect_command {
    Centreon_command <<| config == $name |>>
  }
}
