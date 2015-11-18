network { 'direct-net':
  autostart          => true,
  forward_mode       => 'bridge',
  forward_dev        => 'eth0',
  forward_interfaces => [ 'eth0']
}

network { 'bridge':
  bridge       => 'vmbr0',
  forward_mode => 'bridge'
}

$dhcp1 = {
  'start' => '192.168.122.2',
  'end'   => '192.168.122.254',
  'bootp_file' => 'pxelinux.0',
}
$ip1 = {
  'address' => '192.168.122.1',
  'netmask' => '255.255.255.0',
  'dhcp'    => $dhcp1,
}
network { 'pxe':
  autostart    => true,
  forward_mode => 'nat',
  forward_dev  => 'virbr0',
  ip           => [ $ip1]
}


$dhcp2 = {
  'start' => '192.168.222.2',
  'end'   => '192.168.222.254',
}
$ip2 = {
  'address' => '192.168.222.1',
  'netmask' => '255.255.255.0',
}
$ipv6 = {
  address => '2001:db8:ca2:2::1',
  prefix  => '64',
}
network { 'dual-stack':
  autostart    => true,
  forward_mode => 'nat',
  forward_dev  => 'virbr2',
  bridge       => 'virbr2',
  ip           => [ $ip2],
  ipv6         => [ $ipv6 ],
}

network { 'bridge_mode':
  bridge => 'vmbr4',
  forward_mode => 'bridge'
}

