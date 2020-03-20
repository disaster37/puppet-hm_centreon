centreon_host{ "test-seb3":
    ensure      => present,
    enable      => true,
    description => "test3",
    address     => "localhost",
    poller      => "poller1",
    macros      => [
        {
            name => "macro2",
            value => "value1",
            is_password => false,
            description => "test macro 1",
        }
    ]
}


centreon_host_in_host_template{"Set host templates":
    host => "test-seb3",
    templates => ["TH_OS-SYS-AIX"]
}

centreon_host_in_host_group{"Set host groups":
    host => "test-seb3",
    groups => ["HG_CENTRAL"]
}