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

case node['platform_family']
  when 'windows'

    powershell_script "Install-nfs-feature" do
      code <<-EOH
Install-WindowsFeature NFS-Client, RSAT-NFS-Admin
      EOH
    end

    batch 'mount persistent drive' do
      code <<-EOH
      net use #{node['windows_drive']} \\\\#{node['replication_remote_ip']}#{node['dir_server']}  /persistent:yes
      EOH
      action :run
      not_if { ::File.directory?(node['dir_client']) }
    end

  else

    directory node['dir_client'] do
      owner 'root'
      group 'root'
      mode '0777'
      action :create
      only_if { node['NFS_client'] }
    end

    mount node['dir_client'] do
      device "#{node['replication_remote_ip']}:#{node['dir_server']}"
      fstype 'nfs'
      only_if { node['NFS_client'] }
    end

end
