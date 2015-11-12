require 'chef/provisioning/ssh_driver/driver'

with_driver 'ssh'
# with_chef_server "https://chef-node-3:443/organizations/alfchef"
#                      :client_name => Chef::Config[:node_name],
#                      :signing_key_filename => Chef::Config[:client_key]
# with_chef_server "http://172.29.101.100:4000"
with_chef_local_server chef_repo_path: '/tmp/kitchen/cache', cookbook_path: '/tmp/kitchen/cache/cookbooks'

username = 'root'
installer_path = 'ftp://172.29.101.56/51/b431/alfresco-enterprise-installer-20151026-SNAPSHOT-431-linux-x64.bin'

node1_options = { transport_options: {
  ip_address: node['node1'],
  username: username,
  ssh_options: {
    password: 'alfresco'
  }
} }
node2_options = { transport_options: {
  ip_address: node['node2'],
  username: username,
  ssh_options: {
    password: 'alfresco'
  }
} }
lb_options = { transport_options: {
  ip_address: node['loadbalancer'],
  username: username,
  ssh_options: {
    password: 'alfresco'
  }
} }

machine_batch 'Initial setup on nodes and lb' do
  machine 'node1' do
    action [:ready, :setup, :converge]
    machine_options node1_options
    run_list %w(recipe[java-wrapper::java8] recipe[nfs::client4] recipe[alfresco-installer::installer])
    attributes 'installer' =>
                   { 'nodename' => 'node1',
                     'disable-components' => 'javaalfresco,postgres',
                     'downloadpath' => installer_path },
               'db.url' => "jdbc:postgresql://#{node['loadbalancer']}:5432/${db.name}",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => [node['node2']],
               'replication_remote_ip' => node['loadbalancer'],
               'install_solr4_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.host' => node['loadbalancer']
  end

  machine 'node2' do
    action [:ready, :setup, :converge]
    machine_options node2_options
    run_list %w(recipe[java-wrapper::java8] recipe[nfs::client4] recipe[alfresco-installer::installer])
    attributes 'installer' =>
                   { 'nodename' => 'node2',
                     'disable-components' => 'javaalfresco,postgres',
                     'downloadpath' => installer_path },
               'db.url' => "jdbc:postgresql://#{node['loadbalancer']}:5432/${db.name}",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => [node['node1']],
               'replication_remote_ip' => node['loadbalancer'],
               'install_solr4_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.host' => node['loadbalancer']
  end

  machine 'LB' do
    action [:ready, :setup, :converge]
    machine_options lb_options
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-dbwrapper::postgres] recipe[alfresco-installer::replication_server] recipe[alfresco-installer::loadbalancer] recipe[alfresco-installer::installer])
    attributes 'lb' => {
      'ips_and_nodenames' => [
        {
          'ip' => node['node1'],
          'nodename' => 'node1'
        },
        {
          'ip' => node['node2'],
          'nodename' => 'node2'
        }
      ] },
               'installer' =>
                   { 'nodename' => 'LB',
                     'disable-components' => 'javaalfresco,postgres,alfrescowcmqs,alfrescosolr,alfrescogoogledocs,libreofficecomponent',
                     'downloadpath' => installer_path },
               'postgres' =>
                   { 'installpostgres' => true,
                     'createdb' => true },
               'replication.enabled' => 'false',
               'alfresco.cluster.enabled' => 'true',
               'install_share_war' => false,
               'install_alfresco_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.target.alfresco.host' => node['node1'],
               'solr.target.alfresco.port' => '8080',
               'solr.target.alfresco.port.ssl' => '8443'
  end
end

machine_batch 'replication setup' do
  machine 'node1' do
    machine_options node1_options
    recipe 'alfresco-installer::replication_client'
    action :converge
  end
  machine 'node2' do
    machine_options node2_options
    recipe 'alfresco-installer::replication_client'
    action :converge
  end
end

machine 'LB' do
  action :converge
  machine_options lb_options
  attribute 'START_SERVICES', true
  attribute %w(postgres installpostgres), false
  attribute %w(postgres createdb), false
  notifies :converge, 'machine[node1]', :immediately
end

machine 'node1' do
  action :nothing
  machine_options node1_options
  attribute 'START_SERVICES', true
  notifies :converge, 'machine[node2]', :immediately
end

machine 'node2' do
  action :nothing
  machine_options node2_options
  attribute 'START_SERVICES', true
end