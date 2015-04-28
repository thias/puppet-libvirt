#### 2015-04-28 - 1.0.0
* Strip whitespace to fix pool detection (#30, @CyBeRoni).
* Convert spec system to beaker tests (#33, @igalic).
* Fix activate vs. active in the README (#35, @unicorn-ljw).
* Pool simplify (#39, @igalic).
* Fix version comparison for puppet future parser (#40, @edestecd).
* Force LC_ALL=en_US.utf8 for all execs (#41, @kakwa).
* Replace Modulefile with metadata.json.

#### 2014-05-05 - 0.3.2
* Bugfix for debian defaults with Puppet 2.7 (#28, @darktim).
* Add qemu_user and qemu_group parameters (#28, @darktim).
* Add support for RHEL7.
* Add version to the puppetlabs/stdlib dependency.

#### 2014-01-31 - 0.3.1
* Fixed typo in init.pp (#23, @gigawhat).

#### 2014-01-28 - 0.3.0
* Add /etc/default/libvirt-bin generation for debian systems (#15, @msimonin).
* Add type to manage storage pools (#16, @msimonin).
* Fix tests (#17, @igalic).
* Add initial configuration of qemu.conf (#18, @luisfdez).
* Add qemu_set_process_name parameter (#21).
* Add networks and networks_defaults parameters, useful from hiera (#9).

#### 2013-10-16 - 0.2.3
* Fix for default sysconfig setting on RedHat.
* Add listen_addr, tcp_auth and tls_auth parameters.

#### 2013-10-16 - 0.2.2
* Add sysconfig/libvirtd file management on RedHat osfamily.
* Add tls and tcp related parameters.

#### 2013-10-14 - 0.2.1
* Add new libvirt::network definition (Igor Galić).
* Move all current parameters to the params class.

#### 2013-10-07 - 0.2.0
* Add puppet-rspec and rspec system tests (Igor Galić).
* Add Debian/Ubuntu support (Igor Galić).

#### 2013-10-04 - 0.1.1
* Add syntax highlighting tags to the README.

#### 2013-05-24 - 0.1.0
* Update README and use markdown.
* Change to 2-space indent.

#### 2012-08-29 - 0.0.1
* Clean up existing module.

