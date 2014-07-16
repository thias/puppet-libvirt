# puppet-libvirt

## Overview

Libvirt module. Useful on minimal Red Hat Enterprise Linux and Debian/Ubuntu
installations which need to be configured as KVM virtualization hosts.

* `libvirt` : Main class to install, enable and configure libvirt.
* `libvirt::network` : Definition to manage libvirt networks.

## Examples

Use all of the module's defaults :

```puppet
include '::libvirt'
```

Typical KVM/qemu host for virtualization :

```puppet
class { '::libvirt':
  mdns_adv => false
}
```

Change even more defaults :

```puppet
class { '::libvirt':
  defaultnetwork     => true,
  virtinst           => false,
  unix_sock_group    => 'wheel',
  unix_sock_rw_perms => '0770',
}
```

The module also allows the user to customize qemu parameters :

```puppet
class { '::libvirt':
  qemu_vnc_listen => "0.0.0.0",
  qemu_vnc_sasl   => true,
  qemu_vnc_tls    => false,
}
```

Configure Kerberos authentication:

```puppet
class { '::libvirt':
  listen_tls                => false,
  listen_tcp                => true,
  auth_tcp                  => 'sasl',
  sysconfig                 => {
    'LIBVIRTD_ARGS' => '--listen',
  },
  sasl2_libvirt_mech_list   => 'gssapi',
  sasl2_libvirt_keytab      => '/etc/libvirt/krb5.tab',
  qemu_vnc_listen           => "0.0.0.0",
  qemu_vnc_sasl             => true,
  qemu_vnc_tls              => false,
  sasl2_qemu_mech_list      => 'gssapi',
  sasl2_qemu_keytab         => '/etc/qemu/krb5.tab',
  sasl2_qemu_auxprop_plugin => 'sasldb',
}
```

Replace the default network with a PXE boot one :

```puppet
class { '::libvirt':
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

We also support IPv6: It has the same sematics as ip:

```puppet
# $ip = same as above

$ipv6 = {
  address => '2001:db8:ca2:2::1',
  prefix  => '64',
}

libvirt::network { 'dual-stack':
  forward_mode => 'nat',
  forward_dev  => 'virbr0',
  ip           => [ $ip ],
  ipv6         => [ $ipv6 ],
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
class { '::libvirt':
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

* Create a new directory pool  :

```puppet
libvirt_pool { 'mypool' :
  ensure   => present,
  type     => 'dir',
  active   => false,
  target   => '/tmp/pool-dir',
}
```
The above will *define*, *build* but not *activate* the pool.

By default a pool is *activated* ( same as `active => true`).

By default a pool is *not autostarted* (same as `autostart => false`).



* Create a `logical` pool (`lvm`) and set the autostart flag :

```puppet
libvirt_pool { 'lvm-pool' :
  ensure     => present,
  type       => 'logical',
  autostart  => true,
  sourcedev  => [ '/dev/sdb1', '/dev/sdc1' ],
  sourcename => 'vg',
  target     => '/dev/vg'
}
```

* Remove the default pool :

```puppet
libvirt_pool { 'default' :
  ensure => absent,
}
```
