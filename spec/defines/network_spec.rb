#   Copyright 2013 Brainsware
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'spec_helper'

describe 'libvirt::network' do
  network_dir = '/etc/libvirt/qemu/networks'
  autostart_dir = "#{network_dir}/autostart"

  let(:title) { 'direct-net' }
  let(:params) {{ :forward_mode => 'bridge', :forward_dev => 'eth0', :forward_interfaces => [ 'eth0', ] }}

  it { should contain_libvirt__network('direct-net').with({ 'ensure' => 'present'} )}
  it { should contain_exec("create-#{network_dir}/direct-net.xml").with({
    'command' => "cat > #{network_dir}/direct-net.xml <<EOF
<network>
  <name>direct-net</name>
  <forward dev='eth0' mode='bridge'>
    <interface dev='eth0'/>
  </forward>
</network>

EOF",
  })}

  context 'pxe boot network' do
    let(:title) { 'pxe' }
    dhcp = {
      'start' => '192.168.122.2',
      'end'   => '192.168.122.254',
      'bootp_file' => 'pxelinux.0',
    }
    ip = {
      'address' => '192.168.122.1',
      'netmask' => '255.255.255.0',
      'dhcp'    => dhcp,
    }
    let(:params) {{ :forward_mode => 'nat', :forward_dev => 'virbr0', :bridge => 'virbr0', :ip => [ ip ] }}

    it { should contain_libvirt__network('pxe').with({ 'ensure' => 'present'} )}
    it { should contain_exec("create-#{network_dir}/pxe.xml").with({
    'command' => "cat > #{network_dir}/pxe.xml <<EOF
<network>
  <name>pxe</name>
  <forward dev='virbr0' mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
      <bootp file='pxelinux.0'/>
    </dhcp>
  </ip>
</network>

EOF",
  })}
  end

  context 'dual stack' do
    let(:title) { 'dual-stack' }
    dhcp = {
      'start' => '192.168.122.2',
      'end'   => '192.168.122.254',
      'bootp_file' => 'pxelinux.0',
    }
    ip = {
      'address' => '192.168.122.1',
      'netmask' => '255.255.255.0',
      'dhcp'    => dhcp,
    }
    ipv6 = {
      'address' => '2001:db8:ca2:2::1',
      'prefix'  => '64',
    }
    let(:params) {{ :forward_mode => 'nat', :forward_dev => 'virbr0', :bridge => 'virbr0', :ip => [ ip ], :ipv6 => [ ipv6 ] }}

    it { should contain_libvirt__network('dual-stack').with({ 'ensure' => 'present'} )}
    it { should contain_exec("create-#{network_dir}/dual-stack.xml").with({
    'command' => "cat > #{network_dir}/dual-stack.xml <<EOF
<network>
  <name>dual-stack</name>
  <forward dev='virbr0' mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
      <bootp file='pxelinux.0'/>
    </dhcp>
  </ip>
  <ip family='ipv6' address='2001:db8:ca2:2::1' prefix='64'/>
</network>

EOF",
  })}
  end

end
