#   Copyright 2015 any number of authors
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

describe 'libvirt', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os} #{facts}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          let(:title) { 'libvirt' }

          it { should contain_class('libvirt') }
          it { should contain_file('/etc/libvirt/qemu/networks/autostart/default.xml')
               .with_ensure('absent')
          }
        end

        context 'with default network enabled' do
          let(:params) {{ :defaultnetwork => true }}

          it { should contain_class('libvirt') }
          it { should contain_exec('virsh-net-autostart-default') }
        end
      end
    end
  end

end
