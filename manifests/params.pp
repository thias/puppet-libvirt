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
    }
    'Debian': {
      $libvirt_package = 'libvirt-bin'
      $libvirt_service = 'libvirt-bin'
      $virtinst_package = 'virtinst'
    }
    default: {
      $libvirt_package = 'libvirt'
      $libvirt_service = 'libvirtd'
      $virtinst_package = 'python-virtinst'
    }
  }

}

