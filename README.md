# Centreon-Puppet

## Setup

```bash
yum install gcc-c++
/opt/puppetlabs/puppet/bin/gem install rest-client
```

This provided need [Centreon pull request](https://github.com/centreon/centreon/pull/8571)

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

### Centreon host in host group

`centreon_host_in_host_group` permit to attach on the flow groups to host. It usefull to add group to host on application profile.

> Don't use `groups` parameter on host definition when you use `centreon_host_in_host_group`.
> To remove groups, you need to put `ensure` as `absent`.

The following example will add some groups on host.

```puppet
centreon_host_in_host_group{'test_app_groups':
    ensure  => 'present',
    host    => 'test',
    groups  => ['HG_TEST', 'HG_TEST2'],
}
```

The resource `centreon_host_in_host_group` have the following parameters:
  - **title**: The unique arbitrary name. It not used by provider.
  - **ensure**: present or absent
  - **host**: The host to attach groups
  - **groups**: The list of groups to attach.


### Centreon host in host template

`centreon_host_in_host_template` permit to attach on the flow templates to host. It usefull to add template to host on application profile.

> Don't use `templates` parameter on host definition when you use `centreon_host_in_host_template`.
> To remove templates, you need to put `ensure` as `absent`.

The following example will add some templates on host.

```puppet
centreon_host_in_host_template{'test_app_templates':
    ensure  => 'present',
    host    => 'test',
    groups  => ['HT_TEST', 'HT_TEST2'],
}
```

The resource `centreon_host_in_host_template` have the following parameters:
  - **title**: The unique arbitrary name. It not used by provider.
  - **ensure**: present or absent
  - **host**: The host to attach templates
  - **templates**: The list of templates to attach.


### Centreon host with macro

`centreon_host_with_macro` permit to attach on the flow macros to host. It usefull to add macros to host on application profile.

> Don't use `macros` parameter on host definition when you use `centreon_host_with_macros`.
> To remove macros, you need to put `ensure` as `absent`.

The following example will add some templates on host.

```puppet
centreon_host_with_macro{'test_app_templates':
    ensure  => 'present',
    host    => 'test',
    macros  => [
        {
            name  => 'MACRO1',
            value => 'foo',
        },
        {
            name  => 'MACRO2',
            value => 'bar',
        }
    ],
}
```

The resource `centreon_host_in_host_template` have the following parameters:
  - **title**: The unique arbitrary name. It not used by provider.
  - **ensure**: present or absent
  - **host**: The host to attach templates
  - **macros**: The list of macros to attach.

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
  - **description**: The name used when generate service
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


### Centreon service

The following example will configure service on Centreon.

```puppet
centreon_service_template{'test|ping':
    ensure   => 'present',
    template => 'ST1',
}
```

The resource `centreon_service` have the following parameters:
  - **title**: The unique service name. It composed by `HOST_NAME|SERVICE_NAME`
  - **ensure**: present or absent
  - **template**: The linked service template
  - **comment** (optional): The comment
  - **enable** (optional): Enable or disable. Default to `true`
  
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
  - **groups** (optional): The list of service group. Default to `[]`
  

  The `macro` hash have the following parameters:
    - **name**: The macro name
    - **value**: The macro value
    - **description** (optional): The macro description
    - **is_password** (optional): Set to true if macro contain password


## Contribute

Pull request are always welcome ;)

Please follow this instruction:
  - Clone the repository and create feature / fix branch from master branch
  - Add feature / fix, what you want
  - Add rspec unit test if you modify Centreon librairy. Run `rspec rspec lib/centreon/*_spec.rb`
  - Add puppet acceptance test to validate provider change. Run `rspec spec/acceptance/*_spec.rb`
  - Fix documentation if needed
  - Make a pull request and look CircleCI status


> To run test, you can use `docker-compose run --rm puppet bash` and wait some time that centreon finish setup. 
> run `gem install webmock rest-client`.
> Then run rspec command on it.