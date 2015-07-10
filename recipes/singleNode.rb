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

  nodeIp1='172.29.101.98'
  # nodeIp2='172.29.101.148'
  username='root'
  installerPath='ftp://172.29.101.56/50N/5.0.2/b302/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'
  version='5.0.2'
#
# machine_batch 'magic setup' do

  machine 'singleNode1' do
    action [:ready, :setup, :converge]
    machine_options :transport_options => {
                        :ip_address => nodeIp1,
                        :username => username,
                        :ssh_options => {
                            :password => 'alfresco'
                        }
                    }
    run_list %w(recipe[java-wrapper::java8]
            recipe[alfresco-dbwrapper::postgres] recipe[alfresco-chef::installer] )
    attributes 'installer' =>
                   {'nodename' => 'singleNode',
                    'disable-components' => 'javaalfresco,postgres',
                    'downloadpath' => installerPath,
                    'directory' => '/opt/alf-installation',
                    'local' => '/resources/alfresco.bin'},
               'alfresco.version' => version,
               'installer.database-type' => 'postgres',
               'installer.database-version' => '9.3.5',
               'db.url' => "jdbc:postgresql://#{nodeIp1}:5432/${db.name}",
               'db.password' => 'alfresco',
               'db.username' => 'alfresco',
               'replication.enabled' => 'false',
               'alfresco.cluster.enabled' => 'false',
               'START_SERVICES' => true,
               'START_POSGRES' => false,
               'solr.host' => nodeIp1

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

#   machine 'singleNode2' do
#     action [:ready, :setup, :converge]
#     machine_options :transport_options => {
#                         :ip_address => nodeIp2,
#                         :username => username,
#                         :ssh_options => {
#                             :password => 'alfresco'
#                         }
#                     }
#     run_list %w(recipe[java-wrapper::java8] recipe[alfresco-dbwrapper::mysql] recipe[alfresco-chef::installer] )
#     attributes 'installer' =>
#                    {'nodename' => 'singleNode',
#                     'disable-components' => 'javaalfresco,postgres',
#                     'downloadpath' => installerPath,
#                     'directory' => '/opt/alf-installation',
#                     'local' => '/resources/alfresco.bin'},
#                'alfresco.version' => version,
#                'installer.database-type' => 'mysql',
#                'installer.database-version' => '5.6.17',
#                'db.url' => "jdbc:mysql://#{nodeIp2}:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8",
#                'db.password' => 'alfresco',
#                'db.username' => 'alfresco',
#                'replication.enabled' => 'false',
#                'alfresco.cluster.enabled' => 'false',
#                'START_SERVICES' => true,
#                'START_POSGRES' => false,
#                'solr.host' => nodeIp2
#   end
# end

