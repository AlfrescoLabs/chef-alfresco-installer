gem_package 'chef-provisioning-ssh' do
  action :install
end

require 'chef/provisioning/ssh_driver/driver'

    with_driver 'ssh'

    machine "node1" do
      action [:ready, :setup]
      machine_options :transport_options => {
        :ip_address => '172.29.101.52',
        :username => 'root',
        :ssh_options => {
          :password => 'alfresco'
        }
      }
    end

    machine "node2" do
      action [:ready, :setup]
      machine_options :transport_options => {
        :ip_address => '172.29.101.46',
        :username => 'root',
        :ssh_options => {
          :password => 'alfresco'
        }
      }
    end