[![Build Status](https://travis-ci.org/AlfrescoTestAutomation/chef-alfresco-installer.svg?branch=alfresco-metal)](https://travis-ci.org/AlfrescoTestAutomation/chef-alfresco-installer)
# alfresco-metal-cookbook

This cookbook uses chef-provisioning to deploy alfresco cluster on redhat

## Supported Platforms (tested)
redhat 6,7

## Attributes

['alfresco-metal']['single_node'] = boolean
['alfresco-metal']['cluster_schema'] = '2' or '1'
['alfresco-metal']['node1'] = String IP
['alfresco-metal']['node2'] = String IP
['alfresco-metal']['loadbalancer'] =  String IP
['alfresco-metal']['single_node_ip'] = String IP

Other attributes belong to alfresco-installer, alfresco-dbwrapper and java-wrapper:

Default node attributes for schema2:
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

Default node attributes for load balancer on schema2:
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

## Usage

### alfresco-metal::default

Include `alfresco-metal` in your node's `run_list`:

this will by default create a schema2 cluster
