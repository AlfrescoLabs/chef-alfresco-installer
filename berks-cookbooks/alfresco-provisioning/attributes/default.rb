case node['platform_family']
when 'windows'
  normal['installer']['downloadpath'] = 'ftp://172.29.103.222/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-win-x64.exe'
else
  normal['installer']['downloadpath'] = 'ftp://172.29.103.222/50N/5.0.2/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'
end

default['singleNode'] = false
default['clusterSchema'] = '2'

default['node1'] = '172.29.102.108'
default['node2'] = '172.29.102.110'
default['loadbalancer'] = '172.29.102.109'
default['singleNode'] = ''
