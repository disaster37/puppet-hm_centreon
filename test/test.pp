centreon_host{ "test-seb3":
    ensure      => 'present',
    enable      => true,
    description => "test3",
    address     => "localhost",
    poller      => "poller1",
}