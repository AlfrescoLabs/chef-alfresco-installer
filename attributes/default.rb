case node['platform_family']
when 'windows'
  normal['installer']['downloadpath'] = 'ftp://172.29.103.222/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-win-x64.exe'
else
  normal['installer']['downloadpath'] = 'ftp://172.29.103.222/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'
end

default['single_node'] = false
default['cluster_schema'] = '2'

default['node1'] = '172.29.102.116'
default['node2'] = '172.29.102.117'
default['loadbalancer'] = '172.29.102.114'
default['single_node_ip'] = ''
