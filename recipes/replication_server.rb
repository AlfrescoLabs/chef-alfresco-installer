case node['platform_family']
  when 'windows'

    powershell_script "Install-nfs-server" do
      code <<-EOH
      Add-WindowsFeature 'FS-NFS-Service'
      EOH
    end

    directory node['dir_server_local'] do
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
    end

    powershell_script 'Setup-shared-folder' do
      code <<-EOH
      New-NfsShare -Name "Replicate" -Path "#{node['dir_server_local']}" -Permission "readwrite" -AllowRootAccess $true
      EOH
      action :run
      not_if { ::File.directory?(node['dir_server_local']) }
    end

    
  else

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