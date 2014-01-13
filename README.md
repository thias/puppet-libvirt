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
class { 'libvirt':
  mdns_adv => false
}
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

The module also allows the user to customize qemu parameters :

```puppet
class { 'libvirt':
  qemu_vnc_listen => "0.0.0.0",
  qemu_vnc_sasl   => true,
  qemu_vnc_tls    => false,
}
```

Replace the default network with a PXE boot one :

```puppet
class { 'libvirt':
  defaultnetwork => false, # This is the default
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
  forward_dev  => 'virbr0',
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
    forward_dev:  virbr0
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
    forward_dev: br0
    forward_interfaces:
      - eth0
```

and then in your manifest:

```puppet
$networks = hiera('libvirt_networks', [])
create_resources($networks, $your_defaults_for_a_network)
```

On Red Hat Enterprise Linux, you might want to also manage changes to the
`/etc/sysconfig/libvirtd` file. In this case, you pass the key/value pairs
of the variables to set inside the `sysconfig` hash :

```puppet
class { 'libvirt':
  listen_tls => false,
  listen_tcp => true,
  sysconfig  => {
    'LIBVIRTD_ARGS'          => '--listen',
    'LIBVIRTD_NOFILES_LIMIT' => '4096',
  },
}
```

## Native Types

### Libvirt Storage Pools

#### Puppet Resource 

Query all current pools: `$ puppet resource libvirt_pool`

#### Examples

Define a new directory pool (calls `virsh pool-define-as`) :

```puppet
libvirt_pool { 'mypool' :
  ensure  => present,
  type    => 'dir',
  target  => '/tmp/pool-dir',
}
```

Build a new directory pool (calls `virsh pool-define-as` and
`virsh pool-build`) :
```puppet
libvirt_pool { 'mypool' :
  ensure  => build,
  type    => 'dir',
  target  => '/tmp/pool-dir',
}
```

Start a new directory pool (calls `virsh pool-define-as` and `virsh pool-build`
and `virsh pool-start`) :
```puppet
libvirt_pool { 'mypool' :
  ensure  => active,
  type    => 'dir',
  target  => '/tmp/pool-dir',
}
```

Start a new directory pool and set the autostart flag (calls
`virsh pool-define-as` and `virsh pool-build` and `virsh pool-start` and
`virsh pool-autostart`) :
```puppet
libvirt_pool { 'mypool' :
  ensure    => active,
  autostart => true,
  type      => 'dir',
  target    => '/tmp/pool-dir',
}
```

Create a `netfs` pool (default format to `nfs`) :

```puppet
libvirt_pool { 'gl-built' :
  ensure       => present,
  type         => 'netfs',
  sourceformat => 'glusterfs',
  sourcehost   => 'mafalda',
  sourcepath   => '/tmp/gluster-shared',
  target       => '/tmp/gluster-present',
}
```

Create a `logical` pool (`lvm`) :

```puppet
libvirt_pool { 'lvm-active' :
  ensure     => active,
  type       => 'logical',
  sourcedev  => [ '/dev/sdb1', '/dev/sdc1']
  sourcename => 'vg',
  target     => '/dev/vg'
}
```

