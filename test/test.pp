

centreon_service{'sr062161cti3700.hm.dm.ad|OS-Linux-Disk-/var/lib/docker': 
    ensure => present,
    enable => true,
    template => 'TS_OS-Linux-Disk-Generic-Name-SNMP',
    macros => [{
        name => 'DISKNAME',
        value => '/var',
    }],
    comment  => "Handle by Puppet",
}

centreon_service{'sr062161cti3700.hm.dm.ad|OS-Linux-Disk-/': 
    ensure => present,
    enable => true,
    template => 'TS_OS-Linux-Disk-Generic-Name-SNMP',
    macros => [{
        name => 'DISKNAME',
        value => '/var',
    }],
    comment  => "Handle by Puppet",
}