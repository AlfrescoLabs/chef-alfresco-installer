case node["NFS_server"]
when true
	include_recipe 'nfs::server'
end

directory node['dir_remote'] do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
  only_if { node["NFS_client"] == true }
end

directory node['dir_server'] do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
  only_if { node["NFS_server"] == true }
end

nfs_export node['dir_server'] do
	network "#{node['ipaddress']}/8"
	writeable false
	sync true
	options ['no_root_squash']
	only_if { node["NFS_server"] == true }
	notifies :restart, "service[#{node['nfs']['service']['server']}]", :immediately
end

mount node['dir_remote'] do
	device "#{node['replication_remote_ip']}:#{node['dir_server']}"
	fstype 'nfs'
	only_if { node["NFS_client"] == true }
end
