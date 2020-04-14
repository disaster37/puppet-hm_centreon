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
  - **comment** (optional): The comment for host group. We can't update the field because of `getparam` is not implemented.
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

### Centreon command

The following example will configure command on Centreon.

```puppet
centreon_command{'ping':
    ensure      => 'present',
    type        => 'check',
    line        => 'ping $HOSTADDRESS$'
}
```

The resource `centreon_command` have the following parameters:
  - **title**: The command name
  - **ensure**: present or absent
  - **type**: the command type
  - **line**: The command line to execute
  - **enable** (optional): Enable or disable service group. Default to `true`
  - **graph** (optional): The type of graph
  - **example** (optional): The command example
  - **enable_shell** (optional): To enable shell. Default to `false`
  - **comment** (optional): The comment for service group

### Centreon host template

The following example will configure host template on Centreon.

```puppet
centreon_host_template{'HT_TEST':
    ensure      => 'present',
    description => 'my host template'
}
```

The resource `centreon_host_template` have the following parameters:
  - **title**: The host template name
  - **ensure**: present or absent
  - **description** (optional): The description
  - **comment** (optional): The comment
  - **address** (optional): The IP or hostname
  - **enable** (optional): Enable or disable host group. Default to `true`
  - **templates** (optional): List of host templates
  - **macros** (optional): List of macros
  - **snmp_community** (optional): The SNMP community
  - **snmp_version** (optional): The SNMP version
  - **timezone** (optional): The timezone
  - **check_command** (optional): The check command
  - **check_command_args** (optional): The list of command arguments
  - **check_interval** (optional): The normal check check_interval
  - **retry_check_interval** (optional): The retry check interval
  - **max_check_attempts** (optional): The maximum check attempts to be hard state
  - **check_period** (optional): The check check period
  - **active_check** (optional): To enable active check. Default to `default`
  - **passive_check** (optional): To enable passive check. Default to `default`
  - **note** (optional): The note
  - **note_url** (optional): The note url
  - **action_url** (optional): The action
  - **icon_image** (optional): The icon image
  

  The `macro` hash have the following parameters:
    - **name**: The macro name
    - **value**: The macro value
    - **description** (optional): The macro description
    - **is_password** (optional): Set to true if macro contain password


### Centreon host

The following example will configure host on Centreon.

```puppet
centreon_host{'TEST':
    ensure      => 'present',
    description => 'my host',
    address     => '127.0.0.1',
    poller      => 'Central'
}
```

The resource `centreon_host` have the following parameters:
  - **title**: The host name
  - **ensure**: present or absent
  - **address**: The IP or hostname
  - **poller**: The poller witch monitor the host
  - **description** (optional): The description for host
  - **comment** (optional): The comment for host group
  - **enable** (optional): Enable or disable host group. Default to `true`
  - **templates** (optional): List of host templates
  - **groups** (optional): List of host groups
  - **macros** (optional): List of macros
  - **snmp_community** (optional): The SNMP community
  - **snmp_version** (optional): The SNMP version
  - **timezone** (optional): The timezone
  - **check_command** (optional): The check command
  - **check_command_args** (optional): The list of command arguments
  - **check_interval** (optional): The normal check check_interval
  - **retry_check_interval** (optional): The retry check interval
  - **max_check_attempts** (optional): The maximum check attempts to be hard state
  - **check_period** (optional): The check check period
  - **active_check** (optional): To enable active check. Default to `default`
  - **passive_check** (optional): To enable passive check. Default to `default`
  - **note** (optional): The note
  - **note_url** (optional): The note url
  - **action_url** (optional): The action
  - **icon_image** (optional): The icon image
  

  The `macro` hash have the following parameters:
    - **name**: The macro name
    - **value**: The macro value
    - **description** (optional): The macro description
    - **is_password** (optional): Set to true if macro contain password


### Centreon service template

The following example will configure service template on Centreon.

```puppet
centreon_service_template{'ST_TEST':
    ensure      => 'present',
    description => 'ST1'
}
```

The resource `centreon_service_template` have the following parameters:
  - **title**: The service template name
  - **ensure**: present or absent
  - **description** (optional): The name used when generate service
  - **comment** (optional): The comment
  - **enable** (optional): Enable or disable. Default to `true`
  - **template** (optional): The linked service template
  - **macros** (optional): List of macros
  - **command** (optional): The check command
  - **command_args** (optional): The list of command arguments
  - **normal_check_interval** (optional): The normal check check_interval
  - **retry_check_interval** (optional): The retry check interval
  - **max_check_attempts** (optional): The maximum check attempts to be hard state
  - **check_period** (optional): The check check period
  - **active_check** (optional): To enable active check. Default to `default`
  - **passive_check** (optional): To enable passive check. Default to `default`
  - **note** (optional): The note
  - **note_url** (optional): The note url
  - **action_url** (optional): The action
  - **icon_image** (optional): The icon image
  - **is_volatile** (optional): To set service as volatile. Default to `default`
  - **categories** (optional): The list of categories. Default to `[]`
  - **services_traps** (optional): The list of service traps. Default to `[]`
  - **host_templates** (optional): The list of host templates. Default to `[]`
  

  The `macro` hash have the following parameters:
    - **name**: The macro name
    - **value**: The macro value
    - **description** (optional): The macro description
    - **is_password** (optional): Set to true if macro contain password