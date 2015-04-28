require 'rexml/document'
require 'tempfile'

Puppet::Type.type(:libvirt_pool).provide(:virsh) do

  commands :virsh => 'virsh'

  def self.instances
    list = virsh('-q', 'pool-list', '--all')
    list.split(/\n/)[0..-1].map do |line|
      values = line.strip.split(/ +/)
      new(
        :name      => values[0],
        :active    => values[1].match(/^act/)? :true : :false,
        :autostart => values[2].match(/no/) ? :false : :true,
        :provider  => self.name
      )
    end
  end

  def status
    list = virsh('-q', 'pool-list', '--all')
    list.split(/\n/)[0..-1].detect do |line|
      fields = line.strip.split(/ +/)
      if (fields[0].match(/^#{resource[:name]}$/))
        return :present
      end
    end
  return :absent

  end

  def self.prefetch(resources)
    pools = instances
    resources.keys.each do |name|
      if provider = pools.find{ |pool| pool.name == name}
        resources[name].provider = provider
      end
    end
  end

  def create
    defined = self.definePool
    if !defined
      # for some reason the pool has not been defined
      # malformed xml
      # or failed tmpfile creationa
      # or ?
      raise Puppet::Error.new("Unable to define the pool")
    end
    self.buildPool

    @property_hash[:ensure] = :present
    should_active = @resource.should(:active)
    unless self.active == should_active
      self.active = should_active
    end
    should_autostart = @resource.should(:autostart)
    unless self.autostart == should_autostart
      self.autostart = should_autostart
    end
  end

  def destroy
    self.destroyPool
    @property_hash.clear
  end

  def definePool
    result = false
    begin
      tmpFile = Tempfile.new("pool.#{resource[:name]}")
      xml = buildPoolXML resource
      tmpFile.write(xml)
      tmpFile.rewind
      virsh('pool-define', tmpFile.path)
      result = true
    ensure
      tmpFile.close
      tmpFile.unlink
    end
    return result
  end

  def buildPool
    begin
      virsh('pool-build', '--pool', resource[:name])
    rescue
      # Unable to build the pool maybe because
      # it is already defined (it this case we should consider
      # to continue execution)
      # or there is permission issue on the fs
      # or ?
      # in these cases we should consider raising something
      notice("Unable to build the pool")
    end

  end

  def destroyPool
    begin
      virsh('pool-destroy', resource[:name])
    rescue Puppet::ExecutionFailure => e
      notice(e.message)
    end
    virsh('pool-undefine', resource[:name])
  end

  def active
    @property_hash[:active] || :false
  end

  def active=(active)
    if (active == :true)
      virsh 'pool-start', '--pool', resource[:name]
      @property_hash[:active] = 'true'
    else
      virsh 'pool-destroy', '--pool', resource[:name]
      @property_hash[:active] = 'false'
    end
  end

  def autostart
    @property_hash[:autostart] || :false
  end

  def autostart=(autostart)
    if (autostart == :true)
      virsh 'pool-autostart', '--pool', resource[:name]
      @property_hash[:autostart] = :true
    else
      virsh 'pool-autostart', '--pool', resource[:name], '--disable'
      @property_hash[:autostart] = :false
    end
  end


  def exists?
    @property_hash[:ensure] != :absent
  end

  def buildPoolXML(resource)
    root = REXML::Document.new
    pool = root.add_element 'pool', {'type' => resource[:type]}
    name = pool.add_element 'name'
    name.add_text resource[:name]

    srcHost = resource[:sourcehost]
    srcPath = resource[:sourcepath]
    srcDev = resource[:sourcedev]
    srcName = resource[:sourcename]
    srcFormat = resource[:sourceformat]

    if (srcHost || srcPath || srcDev || srcName || srcFormat)
      source = pool.add_element 'source'

      source.add_element('host', {'name' => srcHost})     if srcHost
      source.add_element('dir', {'path' => srcPath})      if srcPath
      source.add_element('format', {'type' => srcFormat}) if (srcFormat)

      if (srcDev)
        Array(srcDev).each do |dev|
          source.add_element('device', {'path' => dev})
        end
      end

      if (srcName)
        srcNameEl = source.add_element 'name'
        srcNameEl.add_text srcName
      end
    end

    target = resource[:target]
    if target
      targetEl = pool.add_element 'target'
      targetPathEl = targetEl.add_element 'path'
      targetPathEl.add_text target
    end

    return root.to_s

  end # buildPoolXML

end
