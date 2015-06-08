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

machine_batch 'Initial setup on nodes and lb' do

  clusternode1='172.29.101.121'
  clusternode2='172.29.101.122'
  loadbalancer='172.29.101.120'
  username='root'
  installerPath='ftp://172.29.103.222/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'

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
                    'disable-components' => 'javaalfresco,postgres',
                    'downloadpath' => installerPath},
               'db.url' => "jdbc:postgresql://#{loadbalancer}:5432/${db.name}",
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
                    'disable-components' => 'javaalfresco,postgres',
                    'downloadpath' => installerPath},
               'db.url' => "jdbc:postgresql://#{loadbalancer}:5432/${db.name}",
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
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::replication_server] recipe[alfresco-chef::loadbalancer] recipe[alfresco-dbwrapper::postgres] recipe[alfresco-chef::installer])
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
                    'disable-components' => 'javaalfresco,postgres,alfrescowcmqs,alfrescosolr,alfrescogoogledocs,libreofficecomponent',
                    'downloadpath' => installerPath},
               'postgres' =>
                   {'installpostgres' => true,
                    'createdb' => true},
               'replication.enabled' => 'false',
               'alfresco.cluster.enabled' => 'true',
               'disable_solr_ssl' => true,
               'install_share_war' => false,
               'install_alfresco_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
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
  attribute %w[postgres installpostgres], false
  attribute %w[postgres createdb], false
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

