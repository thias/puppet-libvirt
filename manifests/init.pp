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
  # libvirtd.conf options
  $mdns_adv           = true,
  $unix_sock_group    = 'root',
  $unix_sock_ro_perms = '0777',
  $unix_sock_rw_perms = '0700',
  $unix_sock_dir      = '/var/run/libvirt'
) {

  include libvirt::params

  package { $libvirt::params::libvirt_package:
    ensure => installed,
    alias  => 'libvirt',
  }

  service { 'libvirtd':
    ensure    => running,
    name      => $libvirt::params::libvirt_service,
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
  #    content => template('libvirt/qemu.conf.erb'),
  #    notify  => Service['libvirtd'],
  #    require => Package['libvirt'],
  #}

  # The default network, automatically configured... disable it by default
  if $defaultnetwork {
    file { '/etc/libvirt/qemu/networks/autostart/default.xml':
      ensure  => link,
      target  => '../default.xml',
      require => Package['libvirt'],
    }
  } else {
    file { '/etc/libvirt/qemu/networks/autostart/default.xml':
      ensure  => absent,
      require => Package['libvirt'],
    }
  }

  # The most useful libvirt-related packages
  if $virtinst {
    package { $libvirt::params::virtinst_package: ensure => installed }
  }
  if $qemu {
    package { 'qemu-kvm': ensure => installed }
  }

}

