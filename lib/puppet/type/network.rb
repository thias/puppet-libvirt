Puppet::Type.newtype(:network) do
  @doc = "manages domains with libvirt" 
  
  ensurable

  newparam(:name) do
    desc "The name of the domain."
  end
  
  newproperty(:autostart) do
    desc "Whether to start this network at boot time"
  end
  
  newproperty(:bridge) do
    desc "Name of the bridge this network will be attached to"
  end
  
  newproperty(:forward_mode) do
    desc "One of nat, route, bridge, vepa, passthrough, private, hostdev"
  end
  
  newparam(:forward_dev) do
    desc "The interface to forward, useful in bridge and route mode"
  end
  
  newparam(:forward_interfaces) do
    desc "An array of interfaces to forwad"
  end
  
  newparam(:ip) do
    desc "a hash with
    address
    netmask (or alterntively prefix)
    dhcp This is another hash that consists of
      start - start of the range
      end - end of the range
      host - an array of hosts"
  end
  
  newparam(:ipv6) do
    desc "a hash with
    address
    netmask (or alterntively prefix)
    dhcp This is another hash that consists of
      start - start of the range
      end - end of the range
      host - an array of hosts
  Note: The following options are not supported on IPv6 networks
    bootp_file - A file to serve for servers booting from PXE
    bootp_server - Which server that file is served from"
  end
  
  newproperty(:mac) do
    desc "mac address for the bridge"
  end

end
