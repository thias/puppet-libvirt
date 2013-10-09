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
      $auth_unix_ro = undef
      $auth_unix_rw = undef
    }
    'Debian': {
      $libvirt_package = 'libvirt-bin'
      $libvirt_service = 'libvirt-bin'
      $virtinst_package = 'virtinst'
      $auth_unix_ro = 'none'
      $auth_unix_rw = 'none'
    }
    default: {
      $libvirt_package = 'libvirt'
      $libvirt_service = 'libvirtd'
      $virtinst_package = 'python-virtinst'
      $auth_unix_ro = undef
    }
  }

}

