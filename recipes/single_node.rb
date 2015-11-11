require 'chef/provisioning/ssh_driver/driver'

with_driver 'ssh'
# with_chef_server "https://chef-node-3/organizations/alfchef",
#                     :client_name => 'bamboo1',
#                     :signing_key_filename => '/opt/.chef/bamboo1.pem'
# with_chef_server "http://172.29.101.100:4000"
with_chef_local_server chef_repo_path: '/tmp/kitchen/cache', cookbook_path: '/tmp/kitchen/cache/cookbooks'

username = 'root'
installer_path = 'ftp://172.29.101.56/50N/5.0.2/b302/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'
version = '5.0.2'
#
# machine_batch 'magic setup' do

machine 'singleNode1' do
  action [:ready, :setup, :converge]
  machine_options transport_options: {
    ip_address: node['single_node_ip'],
    username: username,
    ssh_options: {
      password: 'alfresco'
    }
  }
  run_list %w(recipe[java-wrapper::java8]
              recipe[alfresco-dbwrapper::postgres] recipe[alfresco-chef::installer] )
  attributes 'installer' =>
                 { 'nodename' => 'singleNode',
                   'disable-components' => 'javaalfresco,postgres',
                   'downloadpath' => installer_path,
                   'directory' => '/opt/alf-installation',
                   'local' => '/resources/alfresco.bin' },
             'alfresco.version' => version,
             'installer.database-type' => 'postgres',
             'installer.database-version' => '9.3.5',
             'db.url' => "jdbc:postgresql://#{node['single_node_ip']}:5432/${db.name}",
             'db.password' => 'alfresco',
             'db.username' => 'alfresco',
             'replication.enabled' => 'false',
             'alfresco.cluster.enabled' => 'false',
             'START_SERVICES' => true,
             'START_POSGRES' => false,
             'solr.host' => node['single_node_ip']
end
