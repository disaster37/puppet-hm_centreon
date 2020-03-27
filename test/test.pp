centreon{'testing':
    url      => 'https://sup37etu11.hm.dm.ad/centreon/api/index.php',
    username => 'langoureaux-s',
    password => 'Msblaster.71',
    debug    => true,
}

centreon_host{ "test-seb3":
    ensure      => 'present',
    enable      => true,
    description => "test3",
    address     => "localhost",
    poller      => "poller1",
}

centreon_host_template{'HT_TEST_SEB':
    ensure      => 'present',
}

centreon_service{'SR072605CTI3700.hm.dm.ad|App-TEST-API-MAQ-URL-Health-11001':
    enable   => true,
    template => 'TS_App-Protocol-HTTP-MultiCheck-Health'
}