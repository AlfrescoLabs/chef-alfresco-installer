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

  machine 'node1' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => '172.29.101.99',
                        :username => 'root',
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::installer])
    attributes 'installer' =>
                   {'nodename' => 'node1',
                    'disable-components' => 'javaalfresco,postgres'},
               'db.url' => 'jdbc:postgresql://172.29.101.98:5432/${db.name}',
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'NFS_client' => true,
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => ['172.29.101.97'],
               'replication_remote_ip' => '172.29.101.98',
               'install_solr4_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.host' => '172.29.101.98'

  end

  machine 'node2' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => '172.29.101.97',
                        :username => 'root',
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::installer])
    attributes 'installer' =>
                   {'nodename' => 'node1',
                    'disable-components' => 'javaalfresco,postgres'},
               'db.url' => 'jdbc:postgresql://172.29.101.98:5432/${db.name}',
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'NFS_client' => true,
               'replication.enabled' => 'true',
               'alfresco.cluster.enabled' => 'true',
               'additional_cluster_members' => ['172.29.101.99'],
               'replication_remote_ip' => '172.29.101.98',
               'install_solr4_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.host' => '172.29.101.98'
  end

  machine 'LB' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => '172.29.101.98',
                        :username => 'root',
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8] recipe[alfresco-chef::replication] recipe[alfresco-chef::loadbalancer] recipe[alfresco-dbwrapper::postgres] recipe[alfresco-chef::installer])
    attributes 'lb' => {
                   'ips_and_nodenames' => [
                       {
                           'ip' => '172.29.101.97',
                           'nodename' => 'node2'
                       },
                       {
                           'ip' => '172.29.101.99',
                           'nodename' => 'node1'
                       }
                   ]},
               'installer' =>
                   {'nodename' => 'LB',
                    'disable-components' => 'javaalfresco,postgres,alfrescowcmqs,alfrescosolr,alfrescogoogledocs,libreofficecomponent'},
               'postgres' =>
                   {'installpostgres' => true,
                    'createdb' => true},
               'NFS_server' => true,
               'NFS_client' => false,
               'replication.enabled' => 'false',
               'alfresco.cluster.enabled' => 'true',
               'install_share_war' => false,
               'install_alfresco_war' => false,
               'START_SERVICES' => false,
               'START_POSGRES' => false,
               'solr.target.alfresco.host' => '172.29.101.99'
  end

end

machine_batch 'replication setup' do
  %w(node1 node2).each do |name|
    machine name do
      recipe 'alfresco-chef::replication'
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

