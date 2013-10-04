
# Class: libvirt::params
#
# hold values for parameters and variables for each supported platform
#
class libvirt::params {

  $libvirt_package = $::osfamily? {
    'RedHat' => "libvirt.${::architecture}",
    'Debian' => 'libvirt-bin',
    default  => 'libvirt'
  }

  $virtinst_package = $::osfamily? {
    'RedHat' => 'python-virtinst',
    'debian' => 'virtinst',
    default  => 'python-virtinst'
  }

  $libvirt_service = $::osfamily? {
    'Debian' => 'libvirt-bin',
    default  => 'libvirtd'
  }
}

