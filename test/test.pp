centreon{'testing':
    url      => 'https://sup37etu11.hm.dm.ad/centreon/api/index.php',
    username => 'langoureaux-s',
    password => 'Msblaster.71',
    debug    => false,
}

centreon_host{ "test-seb3":
    ensure      => 'present',
    enable      => true,
    description => "test3",
    address     => "localhost",
    poller      => "poller1",
}