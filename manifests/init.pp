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
  $defaultnetwork            = false,
  $networks                  = {},
  $networks_defaults         = {},
  $virtinst                  = true,
  $qemu                      = true,
  $radvd                     = false,
  $libvirt_package           = $::libvirt::params::libvirt_package,
  $libvirt_service           = $::libvirt::params::libvirt_service,
  $virtinst_package          = $::libvirt::params::virtinst_package,
  $radvd_package             = $::libvirt::params::radvd_package,
  $sysconfig                 = $::libvirt::params::sysconfig,
  $deb_default               = $::libvirt::params::deb_default,
  # libvirtd.conf options
  $listen_tls                = undef,
  $listen_tcp                = undef,
  $tls_port                  = undef,
  $tcp_port                  = undef,
  $listen_addr               = undef,
  $mdns_adv                  = undef,
  $auth_tcp                  = undef,
  $auth_tls                  = undef,
  $unix_sock_group           = $::libvirt::params::unix_sock_group,
  $unix_sock_ro_perms        = undef,
  $auth_unix_ro              = $::libvirt::params::auth_unix_ro,
  $unix_sock_rw_perms        = $::libvirt::params::unix_sock_rw_perms,
  $auth_unix_rw              = $::libvirt::params::auth_unix_rw,
  $unix_sock_dir             = undef,
  # qemu.conf options
  $qemu_vnc_listen           = undef,
  $qemu_vnc_sasl             = undef,
  $qemu_vnc_tls              = undef,
  $qemu_set_process_name     = undef,
  $qemu_user                 = undef,
  $qemu_group                = undef,
  # sasl2 options
  $sasl2_libvirt_mech_list   = undef,
  $sasl2_libvirt_keytab      = undef,
  $sasl2_qemu_mech_list      = undef,
  $sasl2_qemu_keytab         = undef,
  $sasl2_qemu_auxprop_plugin = undef,
  # libvirt hooks
  $daemon_hook_content       = undef,
  $daemon_hook_source        = undef,
  $qemu_hook_content         = undef,
  $qemu_hook_source          = undef,
  $network_hook_content      = undef,
  $network_hook_source       = undef,
) inherits ::libvirt::params {

  # Keep multiple templates, as close to the original as possible
  if $::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '8') >= 0 {
    $filesuffix = '-el8'
  } else {
    $filesuffix = ''
  }

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
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("libvirt/libvirtd.conf${filesuffix}.erb"),
    notify  => Service['libvirtd'],
    require => Package['libvirt'],
  }

  file { '/etc/libvirt/qemu.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("libvirt/qemu.conf${filesuffix}.erb"),
    notify  => Service['libvirtd'],
    require => Package['libvirt'],
  }

  file { '/etc/sasl2/libvirt.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("libvirt/sasl2/libvirt.conf${filesuffix}.erb"),
    notify  => Service['libvirtd'],
    require => Package['libvirt'],
  }

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
    file { '/etc/sasl2/qemu-kvm.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("libvirt/sasl2/qemu-kvm.conf${filesuffix}.erb"),
      notify  => Service['libvirtd'],
      require => [Package['libvirt'], Package['qemu-kvm']]
    }
  }
  if $radvd {
    package { $radvd_package: ensure => installed }
  }

  # Optional changes to the sysconfig file (on RedHat)
  if $sysconfig != false {
    file { '/etc/sysconfig/libvirtd':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/sysconfig/libvirtd.erb"),
      notify  => Service['libvirtd'],
    }
  }

  # Optional changes to the /etc/default file (on Debian)
  if $deb_default != false {
    file { '/etc/default/libvirt-bin':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/default/libvirt-bin.erb"),
      notify  => Service['libvirtd'],
    }
  }

  if $daemon_hook_content and $daemon_hook_source {
    fail('daemon_hook_content and daemon_hook_source cannot be used together')
  } elsif $daemon_hook_content or $daemon_hook_source {
    file { '/etc/libvirt/hooks/daemon':
      ensure  => present,
      source  => $daemon_hook_source,
      content => $daemon_hook_content,
      mode    => '0755'
    }
  }
  if $qemu_hook_content and $qemu_hook_source {
    fail('qemu_hook_content and qemu_hook_source cannot be used together')
  } elsif $daemon_hook_content or $daemon_hook_source {
    file { '/etc/libvirt/hooks/qemu':
      ensure  => present,
      source  => $qemu_hook_source,
      content => $qemu_hook_content,
      mode    => '0755'
    }
  }
  if $network_hook_content and $network_hook_source {
    fail('network_hook_content and network_hook_source cannot be used together')
  } elsif $network_hook_content or $network_hook_source {
    file { '/etc/libvirt/hooks/network':
      ensure  => present,
      source  => $network_hook_source,
      content => $network_hook_content,
      mode    => '0755'
    }
  }

  # Create Optional networks
  create_resources(libvirt::network, $networks, $networks_defaults)

}

