case node['platform_family']
  when 'windows'
    default['dir_client']='M:/'
    default['windows_drive']='M:'
    default['dir_server']='/Replicate'
    default['dir_server_local']='C:\\Replicate'
    normal['nfs']['service_provider']['lock'] = ''
	normal['nfs']['service_provider']['portmap'] = ''
	normal['nfs']['service_provider']['server'] = ''
  else
    default['dir_client']='/opt/Replicate'
    default['dir_server']='/opt/Replicate'
end

default['replication_remote_ip']=node['ipaddress']
default['replication.enabled']='false'