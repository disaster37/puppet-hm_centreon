
centreon_host{ "test-seb3":
    ensure      => present,
    enable      => true,
    description => "test3",
    address     => "localhost",
    poller      => "poller1",
    templates   => ["TH_OS-SYS-AIX", "TH_HW-Server-IBM-Bladecenter-SNMP"],
    groups      => ["HG_TECH_SERVER", "HG_TECH_GLOBAL"],
    macros      => [
        {
            name => "macro2",
            value => "value1",
            is_password => false,
            description => "test macro 1",
        }
    ]
}


centreon_service{"test-seb3 | test":
    ensure                  => present,
    enable                  => false,
    template                => "Base-Ping-LAN",
    command                 => "App-DB-MSSQL",
    command_args            => ["arg1", "arg2", "arg3"],
    normal_check_interval   => 5,
    retry_check_interval    => 1,
    max_check_attempts      => 3,
    active_check            => "default",
    passive_check           => "default",
    note_url                => "http://localhost",
    action_url              => "http://127.0.0.1",
    comment                 => "Handle by Puppet",
    groups                  => ["SG_DOWN_CENTREON"],
    macros                  => [
        {
            name => "macro2",
            value => "value6",
            is_password => false,
            description => "test macro 1",
        }
    ]
}

centreon_host_group{'HG_TEST_SEB':
    description => "My HG test2"
}

#centreon_service{'sr062161cti3700.hm.dm.ad | OS-Linux-Disk-/var': 
#    ensure => present,
#    enable => true,
#    template => 'TS_OS-Linux-Disk-Generic-Name-SNMP',
#    macros => [{
#        name => 'DISKNAME',
#        value => '/var',
#    }],
#    comment  => "Handle by Puppet",
#}