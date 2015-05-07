
directory node['dir_remote'] do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

nfs_export node['dir_remote'] do
	network "#{node['ipaddress']}/8"
	writeable false
	sync true
	options ['no_root_squash']
	only_if { node["NFS_server"] == true }
end

mount node['dir_remote'] do
	device "#{node['replication_remote_ip']}:/opt/Replicate"
	fstype 'nfs'
	only_if { node["NFS_client"] == true }
end