case node['platform_family']
  when 'windows'
    default['dir_client']='M:/'
    default['windows_drive']='M:'
    default['dir_server']='/Replicate'
    default['dir_server_local']='C:\\Replicate'
  else
    default['dir_client']='/opt/Replicate'
    default['dir_server']='/opt/Replicate'
end

default['replication_remote_ip']=node['ipaddress']
default['replication.enabled']='false'