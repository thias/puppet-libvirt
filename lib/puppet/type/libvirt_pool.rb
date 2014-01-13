Puppet::Type.newtype(:libvirt_pool) do
@doc = %q{Manages libvirt pools

          Example : 
            libvirt_pool { 'default' : 
              ensure => absent
            }


            libvirt_pool { 'mydirpool' :
              ensure    => present,
              active    => true,
              autostart => true,
              type      => 'dir',
              target    => '/tmp/mypool',
            }

            libvirt_pool { 'vm_storage':
              ensure    => 'present',
              active    => 'true',
              type      => 'logical',
              sourcedev => ['/dev/sdb', '/dev/sdc'],
              target    => '/dev/vg0'
            }


        }

  ensurable do

    desc 'Manages the creation or the removal of a pool
    `present` means that the pool will be defined and created
    `absent` means that the pool will be purged from the system'

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
    desc 'The pool name.'
    newvalues(/^\S+$/)
  end

  newparam(:type) do
    desc 'The pool type.'
    newvalues(:dir, :netfs, :fs, :logical, :disk, :iscsi, :mpath, :rbd, :sheepdog)
  end

  newparam(:sourcehost) do
    desc 'The source host.'   
    newvalues(/^\S+$/)
  end

  newparam(:sourcepath) do
    desc 'The source path.'
    newvalues(/(\/)?(\w)/)
  end

  newparam(:sourcedev) do
    desc 'The source device.'
    newvalues(/(\/)?(\w)/)
  end

  newparam(:sourcename) do
    desc 'The source name.'
    newvalues(/^\S+$/)
  end

  newparam(:sourceformat) do
    desc 'The source format.'
    newvalues(:auto, :nfs, :glusterfs, :cifs)
  end
  
  newparam(:target) do
    desc 'The target.'
    newvalues(/(\/)?(\w)/)
  end

  newproperty(:active) do
    desc 'Whether the pool should be started.'
    defaultto(:true)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:autostart) do
    desc 'Whether the pool should be autostarted.'
    defaultto(:false)
    newvalues(:true)
    newvalues(:false)
  end

end
