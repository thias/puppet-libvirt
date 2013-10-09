# puppet-libvirt

## Overview

Libvirt module. Useful on minimal Red Hat Enterprise Linux and Debian/Ubuntu
installations which need to be configured as KVM virtualization hosts.

* `libvirt` : Main class to install, enable and configure libvirt.

## Examples

Use all of the module's defaults :

```puppet
include libvirt
```

Typical KVM/qemu host for virtualization :

```puppet
class { 'libvirt': mdns_adv => '0' }
```

Change even more defaults :

```puppet
class { 'libvirt':
  defaultnetwork     => true,
  virtinst           => false,
  unix_sock_group    => 'wheel',
  unix_sock_rw_perms => '0770',
}
```

Replace the default network with a PXE boot one:

```puppet
class { 'libvirt':
  defaultnetwork => false,
}

$dhcp = {
  'start'      => '192.168.122.2',
  'end'        => '192.168.122.254',
  'bootp_file' => 'pxelinux.0',
}
$ip = {
  'address' => '192.168.122.1',
  'netmask' => '255.255.255.0',
  'dhcp'    => $dhcp,
}

libvirt::network { 'pxe':
  forward_mode => 'nat',
  bridge       => 'virbr0',
  ip           => [ $ip ],
}
```

While this might look a little convoluted in puppet code, this gives you the ability to specify networks in hiera, and then use `create_resources()` to  generate them:

```yaml
---
libvirt_networks:

   pxe:
     autostart:    true
     forward_mode: nat
     bridge:       virbr0
     ip:
       - address: 192.168.122.1
         netmask: 255.255.255.0
         dhcp:
            start: 192.168.122.2
            end:   192.168.122.254
            bootp_file: pxelinux.0
   direct:
     autostart:    true
     forward_mode: bridge
     interfaces:
        - eth0
     bridge:       eth0
```

and then in your manifest:

```puppet
$networks = hiera('libvirt_networks', [])
create_resources($networks, $your_defaults_for_a_network)
```
