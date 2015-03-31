require 'chef/provisioning'


controller_config = <<-ENDCONFIG
  config.ssh.username = ''
  config.ssh.password = ''
  config.vm.provider :vsphere do |vsphere|
  end
ENDCONFIG

machine 'vagranttest' do
	add_machine_options vagrant_config: controller_config
	ready true
end