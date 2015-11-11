require 'chef/provisioning/ssh_driver/driver'

with_driver 'ssh'
# with_chef_server "https://chef-node-3/organizations/alfchef",
#                     :client_name => 'bamboo1',
#                     :signing_key_filename => '/opt/.chef/bamboo1.pem'
# with_chef_server "http://172.29.101.100:4000"
with_chef_local_server chef_repo_path: '/tmp/kitchen/cache', cookbook_path: '/tmp/kitchen/cache/cookbooks'

machine_batch 'Initial setup on nodes and lb' do
  clusternode1 = node['node1']
  clusternode2 = node['node2']
  loadbalancer = node['loadbalancer']
  username = 'root'

  installer_path = 'ftp://172.29.101.56/51/b295/alfresco-enterprise-installer-20150904-SNAPSHOT-295-linux-x64.bin'

  machine 'node1' do
    action [:ready, :setup, :converge]
    machine_options transport_options: {
      ip_address: clusternode1,
      username: username,
      ssh_options: {
        password: 'alfresco'
      }
    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-installer::loadbalancer] recipe[alfresco-installer::installer])
    attributes 'installer' =>
                   { 'nodename' => 'node1',
                     'disable-components' => 'javaalfresco,postgres',
                     'downloadpath' => installer_path },
               'installer.database-type' => 'postgres',
               'installer.database-version' => '9.3.5',
               'db.url' => "jdbc:postgresql://#{nodeIp1}:5432/${db.name}",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => [clusternode2],
               'replication_remote_ip' => loadbalancer,
               'install_solr4_war' => false,
               'install_share_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.host' => loadbalancer
  end

  machine 'node2' do
    action [:ready, :setup, :converge]
    machine_options transport_options: {
      ip_address: clusternode2,
      username: username,
      ssh_options: {
        password: 'alfresco'
      }
    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-installer::installer])
    attributes 'installer' =>
                   { 'nodename' => 'node2',
                     'disable-components' => 'javaalfresco,postgres',
                     'downloadpath' => installer_path },
               'installer.database-type' => 'postgres',
               'installer.database-version' => '9.3.5',
               'db.url' => "jdbc:postgresql://#{nodeIp1}:5432/${db.name}",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => [clusternode1],
               'replication_remote_ip' => loadbalancer,
               'install_solr4_war' => false,
               'install_share_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.host' => loadbalancer
  end

  machine 'DB' do
    action [:ready, :setup, :converge]
    machine_options transport_options: {
      ip_address: loadbalancer,
      username: username,
      ssh_options: {
        password: 'alfresco'
      }
    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-installer::replication_server] recipe[alfresco-dbwrapper::postgres] recipe[alfresco-installer::installer])
    attributes 'lb' => {
      'ips_and_nodenames' => [
        {
          'ip' => clusternode1,
          'nodename' => 'node1'
        },
        {
          'ip' => clusternode2,
          'nodename' => 'node2'
        }
      ] },
               'installer' =>
                   { 'nodename' => 'LB',
                     'disable-components' => 'javaalfresco,postgres',
                     'downloadpath' => installer_path },
               'replication.enabled' => 'false',
               'alfresco.cluster.enabled' => 'true',
               'install_alfresco_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.target.alfresco.host' => clusternode1,
               'solr.target.alfresco.port' => '8080',
               'solr.target.alfresco.port.ssl' => '8443'
  end
end

machine_batch 'replication setup' do
  %w(node1 node2).each do |name|
    machine name do
      recipe 'alfresco-installer::replication_client'
      action :converge
    end
  end
end

machine 'LB' do
  action :converge
  attribute 'START_SERVICES', true
  attribute %w(postgres installpostgres), false
  attribute %w(postgres createdb), false
  notifies :converge, 'machine[node1]', :immediately
end

machine 'node1' do
  action :nothing
  attribute 'START_SERVICES', true
  notifies :converge, 'machine[node2]', :immediately
end

machine 'node2' do
  action :nothing
  attribute 'START_SERVICES', true
end
