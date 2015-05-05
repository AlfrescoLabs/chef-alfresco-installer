gem_package 'chef-provisioning-ssh' do
  action :install
end

require 'chef/provisioning/ssh_driver/driver'

    with_driver 'ssh'

	# with_chef_server "https://chef-node-3/organizations/alfchef",
 #                     :client_name => 'provisioning',
 #                     :signing_key_filename => '/etc/chef/client.pem'
#  with_chef_server "chefzero://172.29.101.100:8889", {
# :client_name => Chef::Config[:node_name],
# :signing_key_filename => Chef::Config[:client_key]
# }
 # with_chef_local_server chef_repo_path: '/tmp/kitchen'


    machine "node1" do
      action [:ready, :setup]
      machine_options :transport_options => {
        :ip_address => '172.29.101.99',
        :username => 'root',
        :ssh_options => {
          :password => 'alfresco'
        }
      }
        run_list ['recipe[java-wrapper::java8]','recipe[alfresco-chef::installer]']
        converge false
    end

    machine "node2" do
      action [:ready, :setup]
      machine_options :transport_options => {
        :ip_address => '172.29.101.97',
        :username => 'root',
        :ssh_options => {
          :password => 'alfresco'
        }
      }	
        run_list ['recipe[java-wrapper::java8]','recipe[alfresco-chef::installer]']
        converge false
    end

    machine "LB" do
      action [:ready, :setup]
      machine_options :transport_options => {
        :ip_address => '172.29.101.98',
        :username => 'root',
        :ssh_options => {
          :password => 'alfresco'
        }
      }
        run_list ['recipe[java-wrapper::java8]','recipe[alfresco-dbwrapper::postgres]']
        converge false
    end

machine_batch do
  %w(node1 node2 LB).each do |name|
    machine name do        
    	action :converge
    end
  end
end
