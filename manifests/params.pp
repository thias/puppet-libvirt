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

      $unix_sock_dir = '/var/run/libvirt'
      $unix_sock_group = 'root'
      $unix_sock_ro_perms = '0777'
      $auth_unix_ro = undef
      $unix_sock_rw_perms = '0700'
      $auth_unix_rw = undef
    }
    'Debian': {
      $libvirt_package = 'libvirt-bin'
      $libvirt_service = 'libvirt-bin'
      $virtinst_package = 'virtinst'

      $unix_sock_dir = '/var/run/libvirt'
      $unix_sock_group = 'libvirtd'
      $auth_unix_ro = 'none'
      $unix_sock_rw_perms = '0770'
      $auth_unix_rw = 'none'
    }
    default: {
      $libvirt_package = 'libvirt'
      $libvirt_service = 'libvirtd'
      $virtinst_package = 'python-virtinst'

      $unix_sock_dir = '/var/run/libvirt'
      $unix_sock_group = 'root'
      $unix_sock_ro_perms = '0777'
      $auth_unix_ro = undef
      $unix_sock_rw_perms = '0700'
      $auth_unix_rw = undef
    }
  }

}

