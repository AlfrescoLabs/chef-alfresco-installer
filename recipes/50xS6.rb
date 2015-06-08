gem_package 'chef-provisioning-ssh' do
  action :install
end

require 'chef/provisioning/ssh_driver/driver'

with_driver 'ssh'
# with_chef_server "https://chef-node-3/organizations/alfchef",
#                     :client_name => 'bamboo1',
#                     :signing_key_filename => '/opt/.chef/bamboo1.pem'
# with_chef_server "http://172.29.101.100:4000"
with_chef_local_server :chef_repo_path => '/tmp/kitchen/cache', :cookbook_path => '/tmp/kitchen/cache/cookbooks'


clusternode1='172.29.101.126'
clusternode2='172.29.101.127'
loadbalancer='172.29.101.51'
username='Administrator'

machine_batch 'Initial setup on nodes and lb' do

  machine 'node1' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => clusternode1,
                        :username => username,
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::installer])
    attributes 'installer' =>
                   {'nodename' => 'node1',
                    'disable-components' => 'javaalfresco,postgres'},
               'installer.database-type' => 'mariadb',
               'installer.database-version' => '10.0.14',
               'db.url' => "jdbc:mysql://#{loadbalancer}:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => [clusternode2],
               'replication_remote_ip' => loadbalancer,
               'install_solr4_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'disable_solr_ssl' => true,
               'solr.host' => loadbalancer

  end

  machine 'node2' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => clusternode2,
                        :username => username,
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::installer])
    attributes 'installer' =>
                   {'nodename' => 'node2',
                    'disable-components' => 'javaalfresco,postgres'},
               'installer.database-type' => 'mariadb',
               'installer.database-version' => '10.0.14',
               'db.url' => "jdbc:mysql://#{loadbalancer}:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => [clusternode1],
               'replication_remote_ip' => loadbalancer,
               'install_solr4_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'disable_solr_ssl' => true,
               'solr.host' => loadbalancer
  end

  machine 'LB' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => loadbalancer,
                        :username => username,
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::replication_server] recipe[alfresco-chef::loadbalancer] recipe[alfresco-dbwrapper::mysql] recipe[alfresco-chef::installer])
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
                   ]},
               'installer' =>
                   {'nodename' => 'LB',
                    'disable-components' => 'javaalfresco,postgres,alfrescowcmqs,alfrescosolr,alfrescogoogledocs,libreofficecomponent'},
               'replication.enabled' => 'false',
               'alfresco.cluster.enabled' => 'true',
               'install_share_war' => false,
               'install_alfresco_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'disable_solr_ssl' => true,
               'solr.target.alfresco.host' => loadbalancer,
               'solr.target.alfresco.port' => '80'
  end

end

machine_batch 'replication setup' do
  %w(node1 node2).each do |name|
    machine name do
      recipe 'alfresco-chef::replication_client'
      action :converge
    end
  end
end

machine 'LB' do
  action :converge
  attribute 'START_SERVICES', true
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

