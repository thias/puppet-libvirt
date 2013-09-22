
# Class: libvirt::params
#
# hold values for parameters and variables for each supported platform
#
class libvirt::params {

  $libvirt_package = $::osfamily? {
    'RedHat' => "libvirt.${::architecture}",
    'Debian' => 'libvirt-bin',
  }

  $virtinst_package = $::osfamily? {
    'RedHat' => 'python-virtinst',
    'debian' => 'virtinst',
  }

  $libvirt_service = $::osfamily? {
    'RedHat' => 'libvirtd',
    'Debian' => 'libvirt-bin',
  }
}

