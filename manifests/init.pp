# Class: libvirt
#
# Install, enable and configure libvirt.
#
# Parameters:
#  $defaultnetwork:
#    Whether the default network for NAT should be enabled. Default: false
#  $virtinst:
#    Install the python-virtinst package, to get virt-install. Default: true
#  $qemu:
#    Install the qemu-kvm package, required for KVM. Default: true
#  $mdns_adv,
#  $unix_sock_group,
#  $unix_sock_ro_perms,
#  $unix_sock_rw_perms,
#  $unix_sock_dir:
#    Options for libvirtd.conf. Default: unchanged original values
#
# Sample Usage :
#  include libvirt
#
class libvirt (
  $defaultnetwork     = false,
  $virtinst           = true,
  $qemu               = true,
  $libvirt_package    = $::libvirt::params::libvirt_package,
  $libvirt_service    = $::libvirt::params::libvirt_service,
  $virtinst_package   = $::libvirt::params::virtinst_package,
  # libvirtd.conf options
  $mdns_adv           = true,
  $unix_sock_group    = 'root',
  $unix_sock_ro_perms = '0777',
  $auth_unix_ro       = $::libvirt::params::auth_unix_ro,
  $unix_sock_rw_perms = '0700',
  $auth_unix_rw       = $::libvirt::params::auth_unix_rw,
  $unix_sock_dir      = '/var/run/libvirt',
) inherits ::libvirt::params {

  package { 'libvirt':
    ensure => installed,
    name   => $libvirt_package,
  }

  service { 'libvirtd':
    ensure    => running,
    name      => $libvirt_service,
    enable    => true,
    hasstatus => true,
    require   => Package['libvirt'],
  }

  file { '/etc/libvirt/libvirtd.conf':
    content => template('libvirt/libvirtd.conf.erb'),
    notify  => Service['libvirtd'],
    require => Package['libvirt'],
  }

  # Not needed until we support changes to it
  #file { '/etc/libvirt/qemu.conf':
  #  content => template('libvirt/qemu.conf.erb'),
  #  notify  => Service['libvirtd'],
  #  require => Package['libvirt'],
  #}

  # The default network, automatically configured... disable it by default
  $def_net = $defaultnetwork? {
    true    => 'enabled',
    default => 'absent',
  }
  libvirt::network { 'default':
    ensure       => $def_net,
    autostart    => true,
    forward_mode => 'nat',
    bridge       => 'virbr0',
    ip           => [ $::libvirt::params::default_ip ],
  }

  # The most useful libvirt-related packages
  if $virtinst {
    package { $virtinst_package: ensure => installed }
  }
  if $qemu {
    package { 'qemu-kvm': ensure => installed }
  }

}

