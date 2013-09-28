
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

  $default_dhcp = {
    'start'      => '192.168.122.2',
    'end'        => '192.168.122.254',
  }
  $default_ip = {
    'address' => '192.168.122.1',
    'netmask' => '255.255.255.0',
    'dhcp'    => $default_dhcp,
  }
}

