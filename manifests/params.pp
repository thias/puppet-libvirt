# Class: libvirt::params
#
# Hold values for parameters and variables for each supported platform.
#
class libvirt::params {

  case $::osfamily {
    'RedHat': {
      $libvirt_package = "libvirt.${::architecture}"
      $libvirt_service = 'libvirtd'
      $virtinst_package = 'python-virtinst'
      $sysconfig = {}
    }
    'Debian': {
      $libvirt_package = 'libvirt-bin'
      $libvirt_service = 'libvirt-bin'
      $virtinst_package = 'virtinst'
      $sysconfig = false
      # UNIX socket
      $unix_sock_group = 'libvirtd'
      $auth_unix_ro = 'none'
      $unix_sock_rw_perms = '0770'
      $auth_unix_rw = 'none'
    }
    default: {
      $libvirt_package = 'libvirt'
      $libvirt_service = 'libvirtd'
      $virtinst_package = 'python-virtinst'
      $sysconfig = false
    }
  }

  $default_dhcp = {
    'start' => '192.168.122.2',
    'end'   => '192.168.122.254',
  }
  $default_ip = {
    'address' => '192.168.122.1',
    'netmask' => '255.255.255.0',
    'dhcp'    => $default_dhcp,
  }
}

