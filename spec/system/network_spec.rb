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

require 'spec_helper_system'

describe 'libvirt::network' do
  network_dir = '/etc/libvirt/qemu/networks'

  context 'enable default network' do
    it 'should enable the default network' do
      puppet_apply(%{
         class { 'libvirt':
           defaultnetwork => true
         }
      }) { |r| [0,2].should include r.exit_code}
    end

    it 'respond to ping on IP 192.168.122.1 (for interface virbr0)' do
      shell('ping -c1 -q -I virbr0 192.168.122.1') do |r|
        r.exit_code.should == 0
      end
    end
  end

  context 'network directly connected via bridge' do
    it 'should create a network directly connected via a bridge' do
      puppet_apply(%{
         class { 'libvirt': }
         libvirt::network { 'direct-net':
           forward_mode       => 'bridge',
           forward_dev        => 'eth0',
           forward_interfaces => [ 'eth0']
         }
      }) { |r| [0,2].should include r.exit_code}
    end

    describe file("#{network_dir}/direct-net.xml") do
      it { should contain "<forward dev='eth0' mode='bridge'>" }
      it { should contain "<interface dev='eth0'/>" }
    end
  end

  context 'network directly connected via autostarted bridge' do
    it 'should create an autostarted network directly connected via a bridge' do
      puppet_apply(%{
         class { 'libvirt': }
         libvirt::network { 'direct-net':
           autostart          => true,
           forward_mode       => 'bridge',
           forward_dev        => 'eth0',
           forward_interfaces => [ 'eth0']
         }
      }) { |r| [0,2].should include r.exit_code}
    end

    it 'respond to ping on public IPs (for interface eth0)' do
      shell('ping -c1 -q -I eth0 8.8.8.8') do |r|
        r.exit_code.should == 0
      end
    end
  end

  context 'autostarted pxe boot via dhcp' do
    it 'should create an autostarted network for booting from DHCP' do
      puppet_apply(%{
         class { 'libvirt': }
         $dhcp = {
           'start' => '192.168.122.2',
           'end'   => '192.168.122.254',
           'bootp_file' => 'pxelinux.0',
         }
         $ip = {
           'address' => '192.168.122.1',
           'netmask' => '255.255.255.0',
           'dhcp'    => $dhcp,
         }
         libvirt::network { 'pxe':
           autostart    => true,
           ensure       => 'running',
           forward_mode => 'nat',
           forward_dev  => 'virbr0',
           bridge       => 'virbr0',
           ip           => [ $ip]
         }
      }) { |r| [0,2].should include r.exit_code}
    end

    it 'respond to ping on IP 192.168.122.1 (for interface virbr0)' do
      shell('ping -c1 -q -I virbr0 192.168.122.1') do |r|
        r.exit_code.should == 0
      end
    end
  end

  context 'autostarted dual-stack' do
    it 'should create an autostarted network with NATed IPv4 network and an IPv6 address' do
      puppet_apply(%{
         class { 'libvirt': }
         $dhcp = {
           'start' => '192.168.222.2',
           'end'   => '192.168.222.254',
         }
         $ip = {
           'address' => '192.168.222.1',
           'netmask' => '255.255.255.0',
         }
         $ipv6 = {
           address => '2001:db8:ca2:2::1',
           prefix  => '64',
         }
         libvirt::network { 'dual-stack':
           autostart    => true,
           ensure       => 'running',
           forward_mode => 'nat',
           forward_dev  => 'virbr2',
           bridge       => 'virbr2',
           ip           => [ $ip],
           ipv6         => [ $ipv6 ],
         }
      }) { |r| [0,2].should include r.exit_code}
    end

    it 'respond to ping on IP 192.168.222.1 (for interface virbr2)' do
      shell('ping -c1 -q -I virbr2 192.168.222.1') do |r|
        r.exit_code.should == 0
      end
    end

    it 'respond to ping6 on IP 2001:db8:ca2:2::1 (for interface virbr2)' do
      shell('ping6 -c1 -q -I virbr2 2001:db8:ca2:2::1') do |r|
        r.exit_code.should == 0
      end
    end
  end

end
