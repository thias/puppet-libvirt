require 'spec_helper_system'

describe 'libvirt class' do
  case node.facts['osfamily']
  when 'RedHat'
    package_name = 'libvirt'
    service_name = 'libvirtd'
    virtinst_package = 'python-virtinst'
  when 'Debian'
    package_name = 'libvirt-bin'
    service_name = 'libvirt-bin'
    virtinst_package = 'virtinst'
  end

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'libvirt': }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        r.exit_code.should_not == 1
        r.refresh
        r.exit_code.should be_zero
      end
    end

    describe package(package_name) do
      it { should be_installed }
    end
    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context 'with virtinst package' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'libvirt':
        virtinst => true,
      }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        r.exit_code.should_not == 1
        r.refresh
        r.exit_code.should be_zero
      end
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(virtinst_package) do
      it { should be_installed }
    end
  end

end
