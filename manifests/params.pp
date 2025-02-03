# Class: libvirt::params
#
# Hold values for parameters and variables for each supported platform.
#
class libvirt::params {

  case $facts['os']['family'] {
    'RedHat': {
      $libvirt_package = "libvirt.${facts['os']['architecture']}"
      if versioncmp($facts['os']['release']['major'], '9') >= 0 {
        $libvirt_service = 'virtqemud'
      } else {
        $libvirt_service = 'libvirtd'
      }
      if versioncmp($facts['os']['release']['major'], '7') >= 0 {
        $virtinst_package = 'virt-install'
      } else {
        $virtinst_package = 'python-virtinst'
      }
      $radvd_package = 'radvd'
      $sysconfig = {}
      $deb_default = false
      $auth_unix_ro = false
      $unix_sock_rw_perms = false
      $auth_unix_rw = false
      $unix_sock_group = false
    }
    'Debian': {
      $libvirt_package = 'libvirt-bin'
      $virtinst_package = 'virtinst'
      $radvd_package = 'radvd'
      $sysconfig = false
      $deb_default = {}
      # UNIX socket
      $auth_unix_ro = 'none'
      $unix_sock_rw_perms = '0770'
      $auth_unix_rw = 'none'
      case $facts['os']['name'] {
        'Ubuntu', 'LinuxMint': {
          $libvirt_service = 'libvirt-bin'
          $unix_sock_group = 'libvirtd'
        }
        default: {
          $libvirt_service = 'libvirtd'
          $unix_sock_group = 'libvirt'
        }
      }
    }
    default: {
      $libvirt_package = 'libvirt'
      $libvirt_service = 'libvirtd'
      $virtinst_package = 'python-virtinst'
      $radvd_package = 'radvd'
      $sysconfig = false
      $deb_default = false
      $auth_unix_ro = false
      $unix_sock_rw_perms = false
      $auth_unix_rw = false
      $unix_sock_group = false
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

