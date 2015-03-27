require 'libvirt'
require 'erb'

Puppet::Type.type(:network).provide(:libvirt) do
  desc "Create domains with libvirt"

  $conn = Libvirt::open('qemu:///system')

  def self.instances 
    networks = []
    for net in $conn.list_all_networks() do
      hash = {
        :name => net.name,
        :autostart => net.autostart?,
        :bridge => net.bridge_name,
        :uuid => net.uuid   #the uuid is needed for updates to apply corectly
        }
      networks << new(hash)
    end
    return networks
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def create
    #this only exists because puppet demands it
    #the flush function will create as needed
  end


  def flush
net_xml = <<EOF
<network>
  <name><%= @resource[:name] %></name>
  <% if @property_hash[:uuid] %><uuid><%= @property_hash[:uuid] %></uuid><% end %>
  <% if @resource[:mac] %>
  <mac address='<%= @resource[:mac] %>'/>
  <% end %>
  <% if @resource[:forward_mode] %>
  <forward<% if @resource[:forward_dev] %> dev='<%= @resource[:forward_dev] %>'<%end%> mode='<%= @resource[:forward_mode] %>'<% if @resource[:forward_interfaces] %>/<%end%>>
  <%  if !@resource[:forward_interfaces] %>
  <%    @resource[:forward_interfaces].each do |dev| %>
    <interface dev='<%= dev %>'/>
  <%    end %>
  </forward>
  <%  end %>
  <% end %>
  <% if @resource[:bridge] %>
  <bridge name='<%= @resource[:bridge] %>'<% if @resource[:forward_mode] and @resource[:forward_mode] != 'bridge' %> stp='on' delay='0'<%end%>/>
  <% end %>
  <%if @resource[:ip] %>
  <%  @resource[:ip].each do |ip| %>
  <ip<%if ip['address']%> address='<%=ip['address']%>'<%end%><% if ip['netmask']%> netmask='<%=ip['netmask']%>'<%end%><% if ip['prefix']%> prefix='<%=ip['prefix']%>'<%end%><% unless ip['dhcp'] %>/<% end %>>
    <% if ip['dhcp'] %>
    <% dhcp = ip['dhcp'] %>
    <dhcp>
      <% if dhcp['start'] and dhcp['end']%>
      <range start='<%=dhcp['start']%>' end='<%=dhcp['end']%>'/>
      <%end%>
      <% if dhcp['bootp_file']%>
      <bootp file='<%= dhcp['bootp_file'] %>'<% if dhcp['bootp_server']%> server='<%=dhcp['bootp_server']%>'<%end%>/>
      <%end%>
    </dhcp>
  </ip>
    <% end%>
  <%  end%>
  <%end%>
  <% if @resource[:ipv6] %>
  <%  @resource[:ipv6].each do |ip| %>
  <ip family='ipv6'<% if ip['address']%> address='<%=ip['address']%>'<%end%><% if ip['netmask']%> netmask='<%=ip['netmask']%>'<%end%><% if ip['prefix']%> prefix='<%=ip['prefix']%>'<%end%><% unless ip['dhcp'] %>/<% end %>>
    <% if ip['dhcp'] %>
    <% dhcp = ip['dhcp'] %>
    <dhcp>
      <% if dhcp['start'] and dhcp['end']%>
      <range start='<%=dhcp['start']%>' end='<%=dhcp['end']%>'/>
      <%end%>
    </dhcp>
  </ip>
    <% end%>
  <%  end%>
  <%end%>
</network>
EOF
    new_net_xml = ERB.new(net_xml).result(binding)
    begin
      net = $conn.define_network_xml(new_net_xml)
    rescue Libvirt::Error => e
puts "error", e
   end
  end

  def exists?
    begin
      net = $conn.lookup_network_by_name(name)
      true
    rescue Libvirt::RetrieveError => e
      false
    end
  end
  
  def destroy
    net = $conn.lookup_network_by_name(name)
    net.destroy
    net.undefine
  end
  
  def autostart
    @property_hash[:autostart] == true
  end
  
  def autostart=(value)
    net = $conn.lookup_network_by_name(name)
    net.autostart = value
  end
  
  def bridge
    @property_hash[:bridge]
  end
  
  def bridge=(value)
  end
  
end
