# Define: libvirt::network
#
# define, configure, enable and autostart a network for libvirt guests
#
# Parameters:
#  $ensure
#    Ensure this network is defined (present), or enabled (running), or undefined (absent)
#  $autostart
#    Whether to start this network at boot time
#  $bridge
#    Name of the bridge this network will be attached to
#  $forward_mode
#    One of nat, route, bridge, vepa, passthrough, private, hostdev
#  $forward_dev
#    The interface to forward, useful in bridge and route mode
#  $forward_interfaces
#    An array of interfaces to forwad
#  $ip and/or $ipv6 array hashes with
#    address
#    netmask (or alterntively prefix)
#    dhcp This is another hash that consists of
#      start - start of the range
#      end - end of the range
#      host - an array of hosts
#  Note: The following options are not supported on IPv6 networks
#    bootp_file - A file to serve for servers booting from PXE
#    bootp_server - Which server that file is served from
#  $mac - A MAC for this network, if none is defined, libvirt will chose one for you
#
# Sample Usage :
#
# $dhcp = {
#   start      => '192.168.122.2',
#   end        => '192.168.122.254',
#   bootp_file => 'pxelinux.0',
# }
# $pxe_ip = {
#   'address' => '192.168.122.2'
#   'prefix'  => '24'
#   'dhcp'    => $dhcp,
# }
# libvirt::network { 'pxe':
#   ensure       => 'enabled',
#   autostart    => true,
#   forward_mode => 'nat',
#   ip           => [ $pxe_ip ],
# }
#
# libvirt::network { 'direct-net'
#   ensure             => 'enabled',
#   autostart          => true,
#   forward_mode       => 'bridge',
#   forward_dev        => 'br0',
#   forward_interfaces => [ 'eth0', ],
# }
#
# $ipv6 = {
#   address => '2001:db8:ca2:2::1',
#   prefix  => '64',
# }
#
# libvirt::network { 'dual-stack'
#   ensure       => 'enabled',
#   autostart    => true,
#   forward_mode => 'nat',
#   ip           => [ $pxe_ip ],
#   ipv6         => [ $ipv6 ],
# }
#
define libvirt::network (
  $ensure             = 'present',
  $autostart          = false,
  $bridge             = undef,
  $forward_mode       = undef,
  $forward_dev        = undef,
  $forward_interfaces = [],
  $ip                 = undef,
  $ipv6               = undef,
  $mac                = undef,
) {
  validate_bool ($autostart)
  validate_re ($ensure, '^(present|defined|enabled|running|undefined|absent)$',
    'Ensure must be one of defined (present), enabled (running), or undefined (absent).')

  include ::libvirt::params

  Exec {
    cwd         => '/',
    path        => '/bin:/usr/bin',
    user        => 'root',
    provider    => 'posix',
    require     => Service[$::libvirt::params::libvirt_service],
    environment => ['LC_ALL=en_US.utf8', ],
  }

  $ensure_file = $ensure? {
    /(present|defined|enabled|running)/ => 'present',
    /(undefined|absent)/                => 'absent',
  }

  $network_file   = "/etc/libvirt/qemu/networks/${title}.xml"
  $autostart_file = "/etc/libvirt/qemu/networks/autostart/${title}.xml"

  case $ensure_file {
    'present': {
      $content = template('libvirt/network.xml.erb')
      exec { "create-${network_file}":
        command => "cat > ${network_file} <<EOF\n${content}\nEOF",
        creates => $network_file,
        unless  => "test -f ${network_file}",
      }
      exec { "virsh-net-define-${title}":
        command => "virsh net-define ${network_file}",
        unless  => "virsh -q net-list --all | grep -Eq '^\s*${title}'",
        require => Exec["create-${network_file}"],
      }
      if $autostart {
        exec { "virsh-net-autostart-${title}":
          command => "virsh net-autostart ${title}",
          require => Exec["virsh-net-define-${title}"],
          creates => $autostart_file,
        }
      }
      if $ensure in [ 'enabled', 'running' ] {
        exec { "virsh-net-start-${title}":
          command => "virsh net-start ${title}",
          require => Exec["virsh-net-define-${title}"],
          unless  => "virsh -q net-list --all | grep -Eq '^\s*${title}\\s+active'",
        }
      }
    }
    'absent': {
      exec { "virsh-net-destroy-${title}":
        command => "virsh net-destroy ${title}",
        onlyif  => "virsh -q net-list --all | grep -Eq '^\s*${title}\\s+active'",
      }
      exec { "virsh-net-undefine-${title}":
        command => "virsh net-undefine ${title}",
        onlyif  => "virsh -q net-list --all | grep -Eq '^\s*${title}\\s+inactive'",
        require => Exec["virsh-net-destroy-${title}"],
      }
      file { [ $network_file, $autostart_file ]:
        ensure  => absent,
        require => Exec["virsh-net-undefine-${title}"],
      }
    }
    default : {
      fail ("${module_name} This default case should never be reached in Libvirt::Network{'${title}':} on node ${::fqdn}.")
    }
  }
}
