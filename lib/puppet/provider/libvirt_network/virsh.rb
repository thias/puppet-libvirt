require 'rexml/document'
require 'tempfile'

Puppet::Type.type(:libvirt_network).provide(:virsh) do

  commands :virsh => 'virsh' 

  def self.instances
    networks = []
    hash = {}
    list = virsh '-q', 'net-list', '--all'
    list.split(/\n/)[0..-1].map do |line|
      values = line.split(/ +/)
      hash = { 
        :name      => values[0],
        :active    => values[1].match(/^act/)? :true : :false,
        :autostart => values[2].match(/no/) ? :false : :true,
        :provider  => self.name
      }
      networks << new(hash)
      hash = {}
    end
    return networks
  end

  def status
    list = virsh '-q', 'net-list', '--all'
    list.split(/\n/)[0..-1].detect do |line|  
      fields = line.split(/ +/)
      if (fields[0].match(/^#{resource[:name]}$/))
        return :present
      end
    end
  return :absent

  end

  def self.prefetch(resources)
    networks = instances
    resources.keys.each do |name|
      if provider = networks.find{ |network| network.name == name}
        resources[name].provider = provider
      end
    end
  end

  def destroy
    self.destroy_network
    @property_hash.clear
  end

  def defineNetwork
    result = false
    begin
      tmpFile = Tempfile.new("network.#{resource[:name]}")
      xml = createNetworkXML resource
      tmpFile.write(xml)
      tmpFile.rewind
      virsh 'net-define', tmpFile.path
      result = true
    ensure
      tmpFile.close
      tmpFile.unlink
    end
    return result
  end

  def destroy_network
    begin
      virsh 'net-destroy', resource[:name]
    rescue Puppet::ExecutionFailure => e
      notice(e.message)
    end
    virsh 'net-undefine', resource[:name]
  end

  def active
    @property_hash[:active] || :false 
  end

  def active=(active)
    if (active == :true)
      virsh 'net-start', '--network', resource[:name]
      @property_hash[:active] = 'true'
    else
      virsh 'net-destroy', '--network', resource[:name]
      @property_hash[:active] = 'false'
    end
  end

  def autostart
    @property_hash[:autostart] || :false
  end

  def autostart=(autostart)
    if (autostart == :true)
      virsh 'net-autostart', '--network', resource[:name]
      @property_hash[:autostart] = :true
    else
      virsh 'net-autostart', '--network', resource[:name], '--disable'
      @property_hash[:autostart] = :false
    end
  end


  def exists?
    @property_hash[:ensure] != :absent
  end

end
