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
      it { should contain "<forward mode='bridge' dev='eth0'/>" }
      it { should contain "<interface dev='eth0'/>" }
    end
  end

end
