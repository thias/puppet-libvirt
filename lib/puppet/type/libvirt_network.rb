Puppet::Type.newtype(:libvirt_network) do
@doc = %q{Manages libvirt networks

          Example : 
            libvirt_network { 'default' : 
              ensure => absent
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
            libvirt_network { 'pxe' :
              ensure    => present,
              active    => true,
              autostart    => true,
              forward_mode => 'nat',
              forward_dev  => 'virbr0',
              ip           => [ $ip ],
            }

        }

  ensurable do

    desc 'Manages the creation or the removal of a network
    `present` means that the network will be defined and created
    `absent` means that the network will be purged from the system'

    defaultto(:present)
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      if (provider.exists?)
        provider.destroy
      end
    end

    def retrieve
      provider.status
    end

  end

  newparam(:name, :namevar => true) do
    desc 'The network name.'
    newvalues(/^\S+$/)
  end

  newproperty(:active) do
    desc 'Whether the network should be started.'
    defaultto(:true)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:autostart) do
    desc 'Whether the network should be autostarted.'
    defaultto(:false)
    newvalues(:true)
    newvalues(:false)
  end

end
