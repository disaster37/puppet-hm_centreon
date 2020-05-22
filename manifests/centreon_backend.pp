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
  Boolean           $collect_all_config = false,
) {

  include hm_centreon

  centreon{$name:
    url      => $url,
    username => $username,
    password => $password
  }

  if $collect_host {
    if $collect_all_config {
      if $poller == undef {
        Centreon_host <<| |>>
      } else {
        Centreon_host <<| |>> {
          poller => $poller
        }
      }
      Centreon_host_in_host_template <<| |>>
      Centreon_host_in_host_group <<| |>>
      Centreon_host_with_macro <<| |>>
    } else {
        if $poller == undef {
          Centreon_host <<| config == $name |>>
        } else {
          Centreon_host <<| config == $name |>> {
            poller => $poller
          }
        }
      Centreon_host_in_host_template <<| config == $name |>>
      Centreon_host_in_host_group <<| config == $name |>>
      Centreon_host_with_macro <<| config == $name |>>
    }
  }

  if $collect_host_group {
    if $collect_all_config {
      Centreon_host_group <<| |>>
    } else {
      Centreon_host_group <<| config == $name |>>
    }
  }

  if $collect_host_template {
    if $collect_all_config {
      Centreon_host_template <<| |>>
    } else {
      Centreon_host_template <<| config == $name |>>
    }
  }

  if $collect_service {
    if $collect_all_config {
      Centreon_service <<| |>>
    } else {
      Centreon_service <<| config == $name |>>
    }
  }

  if $collect_service_group {
    if $collect_all_config {
      Centreon_service_group <<| |>>
    } else {
      Centreon_service_group <<| config == $name |>>
    }
  }

  if $collect_service_template {
    if $collect_all_config {
      Centreon_service_template <<| |>>
    } else {
      Centreon_service_template <<| config == $name |>>
    }
  }

  if $collect_command {
    if $collect_all_config {
      Centreon_command <<| |>>
    } else {
      Centreon_command <<| config == $name |>>
    }
  }
}
