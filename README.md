# Centreon-Puppet

## Setup

```bash
yum install gcc-c++
/opt/puppetlabs/puppet/bin/gem install rest-client
```

## Usages

### Basic Centreon backend

The following example will configure the centreon backend. Per default, all resource will try to use `default` backend.
You can choose to use another backend on each resource with the parameter `config`.

```puppet
centreon{'default':
    url      => 'https://centreon.domain.com/centreon/api/index.php',
    username => 'admin',
    password => 'P@ssw0rd!',
}
```

The resource `centreon` have the following parameters:
  - **title**: The configuration name. You need to use the same in each resource.
  - **url**: The url to access on centreon API.
  - **username**: The username to access on API.
  - **password**: The password to acces on API.
  - **use_proxy** (optional): Use system proxy or not. Default to `false`.
  - **debug** (optional): Put provider on debug log verbosity. Default to `false`.

### Centreon host group

The following example will configure host group on Centreon.

```puppet
centreon_host_group{'HG_TEST':
    ensure      => 'present',
    description => 'My host group for test purpose'
}
```

The resource `centreon_host_group` have the following parameters:
  - **title**: The host group name
  - **ensure**: present or absent
  - **description** (optional): The description for host group
  - **comment** (optional): The comment for host group
  - **note** (optional): The note for host group
  - **note_url** (optional): The note url for host group
  - **action_url** (optional): The action url for host group
  - **icon_image** (optional): The icon image for host group
  - **enable** (optional): Enable or disable host group. Default to `true`

### Centreon service group

The following example will configure service group on Centreon.

```puppet
centreon_service_group{'SG_TEST':
    ensure      => 'present',
    description => 'My service group for test purpose'
}
```

The resource `centreon_service_group` have the following parameters:
  - **title**: The service group name
  - **ensure**: present or absent
  - **description** (optional): The description for service group
  - **comment** (optional): The comment for service group
  - **enable** (optional): Enable or disable service group. Default to `true`

### Centreon host template

The following example will configure host template on Centreon.

```puppet
centreon_host_template{'HT_TEST':
    ensure      => 'present',
    description => ''
}
```

The resource `centreon_host_template` have the following parameters:
  - **title**: The host template name
  - **ensure**: present or absent
  - **description** (optional): The description for host group
  - **comment** (optional): The comment for host group
  - **note** (optional): The note for host group
  - **note_url** (optional): The note url for host group
  - **action_url** (optional): The action url for host group
  - **icon_image** (optional): The icon image for host group
  - **enable** (optional): Enable or disable host group. Default to `true`