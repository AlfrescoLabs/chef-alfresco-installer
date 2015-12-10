case node['platform_family']
when 'windows'
  normal['installer']['downloadpath'] = 'ftp://172.29.101.56/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-win-x64.exe'
else
  normal['installer']['downloadpath'] = 'ftp://172.29.101.56/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'
end

default['single_node'] = false
default['cluster_schema'] = '2'

default['node1'] = '172.29.102.116'
default['node2'] = '172.29.102.117'
default['loadbalancer'] = '172.29.102.114'
default['single_node_ip'] = ''

default['cluster_node']['recipies'] = ['recipe[java-wrapper::java8]', 'recipe[nfs::client4]', 'recipe[alfresco-installer::installer]']
default['cluster_node']['attributes'] = { 'installer' =>
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
                                  'solr.host' => node['loadbalancer'] }
# default['load_balancer']['attributes'] =
