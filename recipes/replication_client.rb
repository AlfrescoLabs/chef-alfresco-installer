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
    end

    mount node['dir_client'] do
      device "#{node['replication_remote_ip']}:#{node['dir_server']}"
      fstype 'nfs'
    end

end
