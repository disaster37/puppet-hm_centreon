centreon_host{ "test-seb3":
    ensure => present,
    description => "test2",
    address => "localhost",
    poller => "poller1",
    templates => ["TH_OS-SYS-AIX", "TH_HW-Server-IBM-Bladecenter-SNMP"],
    groups => ["HG_TECH_SERVER", "HG_TECH_GLOBAL"],
    macros => [
        {
            name => "macro2",
            value => "value1",
            is_password => false,
            description => "test macro 1",
        }
    ]
}