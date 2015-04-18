require 'libvirt'
require 'erb'
require 'nokogiri'

Puppet::Type.type(:network).provide(:libvirt) do
  desc "Create domains with libvirt"
  
  mk_resource_methods

  $conn = Libvirt::open('qemu:///system')

  def self.parse_network(network)
    doc = Nokogiri::XML(network.xml_desc)
    definition = {}
    definition[:name] = doc.at_xpath('//name').content
    if doc.at_xpath('//bridge') and doc.at_xpath('//bridge').attribute('name')
      definition[:bridge] = doc.at_xpath('//bridge').attribute('name').content
    end
    if doc.at_xpath('//forward') and doc.at_xpath('//forward').attribute('mode')
      definition[:forward_mode] = doc.at_xpath('//forward').attribute('mode').content
    end
    if doc.at_xpath('//forward') and doc.at_xpath('//forward').attribute('dev')
      definition[:forward_mode] = doc.at_xpath('//forward').attribute('dev').content
    end
    definition[:mac] = doc.at_xpath('//mac').attribute('address').content
    definition[:uuid] = doc.at_xpath('//uuid').content
    return definition
  end

  def self.instances 
    networks = []
    for net in $conn.list_all_networks() do
      hash = parse_network(net)
      hash[:autostart] = net.autostart?
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
 #   @property_hash = @resource
  end


  def flush
  debug("flushing '" + @resource[:name] + "' with: " + @property_hash.to_s )
net_xml = <<EOF
<network>
  <name><%= @resource[:name] %></name>
  <% if @property_hash[:uuid] %><uuid><%= @property_hash[:uuid] %></uuid><% end %>
  <% if @property_hash[:mac] %>
  <mac address='<%= @property_hash[:mac] %>'/>
  <% end %>
  <% if @property_hash[:forward_mode] %>
  <forward<% if @property_hash[:forward_dev] %> dev='<%= @property_hash[:forward_dev] %>'<%end%> mode='<%= @property_hash[:forward_mode] %>'<% if !@property_hash[:forward_interfaces] %>/<%end%>>
  <%  if @property_hash[:forward_interfaces] %>
  <%    @property_hash[:forward_interfaces].each do |dev| %>
    <interface dev='<%= dev %>'/>
  <%    end %>
  </forward>
  <%  end %>
  <% end %>
  <% if @property_hash[:bridge] %>
  <bridge name='<%= @property_hash[:bridge] %>'<% if @property_hash[:forward_mode] and @property_hash[:forward_mode] != 'bridge' %> stp='on' delay='0'<%end%>/>
  <% end %>
  <%if @property_hash[:ip] %>
  <%  @property_hash[:ip].each do |ip| %>
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
  <% if @property_hash[:ipv6] %>
  <%  @property_hash[:ipv6].each do |ip| %>
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
    debug("generated: " + new_net_xml )
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

end
