# puppet-libvirt

## Overview

Libvirt module. Useful on minimal Red Hat Enterprise Linux installations which
need to be configured as KVM virtualization hosts.

* `libvirt` : Main class to install, enable and configure libvirt.

## EXamples

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

