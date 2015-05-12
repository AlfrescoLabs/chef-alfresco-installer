case node['NFS_server']
when true
include_recipe 'nfs::server'

directory node['dir_server'] do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

nfs_export node['dir_server'] do
	network "#{node['ipaddress']}/8"
	writeable true
	sync true
	options ['no_root_squash']
	notifies :restart, "service[#{node['nfs']['service']['server']}]", :immediately
end
end

directory node['dir_client'] do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
  only_if { node['NFS_client'] == true }
end

mount node['dir_client'] do
	device "#{node['replication_remote_ip']}:#{node['dir_server']}"
	fstype 'nfs'
	only_if { node['NFS_client'] == true }
end