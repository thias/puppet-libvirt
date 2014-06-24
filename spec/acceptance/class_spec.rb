require 'spec_helper_acceptance'

describe 'libvirt class' do
  case fact('osfamily')
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
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
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
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
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
