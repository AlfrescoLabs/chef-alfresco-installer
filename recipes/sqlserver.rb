#
# Copyright (C) 2005-2015 Alfresco Software Limited.
#
# This file is part of Alfresco
#
# Alfresco is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Alfresco is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Alfresco. If not, see <http://www.gnu.org/licenses/>.
#/

service_name = node['sql_server']['instance_name']
if node['sql_server']['instance_name'] == 'SQLEXPRESS'
  service_name = "MSSQL$#{node['sql_server']['instance_name']}"
end

static_tcp_reg_key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\\' + node['sql_server']['reg_version'] +
  node['sql_server']['instance_name'] + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'

node.set_unless['sql_server']['server_sa_password'] = "Alfresco1"

node.save unless Chef::Config[:solo]

installer_file_path = 'C:\sqlserver.exe'
config_file_path = 'C:\Configuration.ini'

if node['sql_server']['sysadmins'].is_a? Array
  sql_sys_admin_list = node['sql_server']['sysadmins'].join(' ')
else
  sql_sys_admin_list = node['sql_server']['sysadmins']
end

template config_file_path do
  source 'sqlserver/Configuration.ini.erb'
  variables(
    sqlSysAdminList: sql_sys_admin_list
  )
end

remote_file installer_file_path do
  source node['sql_server']['server']['url']
  rights :read, 'Administrator'
  rights :write, 'Administrator'
  rights :full_control, 'Administrator'
  rights :full_control, 'Administrator', :applies_to_children => true
  group 'Administrators'
end

if node['sql_server']['version'] == '2014'

  batch 'extract sqlserver Installation' do
  code <<-EOH
    #{installer_file_path} /Q /X:C:\\sqlserver
    EOH
  not_if { Registry.key_exists?('HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS') }
  end

  setup_file_path = 'C:\sqlserver\SETUP.exe'

else
  setup_file_path = 'C:\sqlserver.exe'
end

windows_task "Install #{node['sql_server']['server']['package_name']}" do
  user 'Administrator'
  password 'alfresco'
  command "#{setup_file_path} /q /ConfigurationFile=#{config_file_path}"
  run_level :highest
  frequency :monthly
  action :create
  not_if { Registry.key_exists?('HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS') }
end

windows_task "Install #{node['sql_server']['server']['package_name']}" do
  action :run
  not_if { Registry.key_exists?('HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS') }
end

batch 'Waiting for installation to finish ...' do
  code <<-EOH
  dir /S /P \"C:\\Program Files\\Microsoft SQL Server\\#{node['sql_server']['reg_version']}SQLEXPRESS\\MSSQL\\Log\\ERRORLOG\"
  EOH
  action :run
  retries 40
  retry_delay 10
  notifies :delete, "windows_task[Install #{node['sql_server']['server']['package_name']}]", :delayed
  not_if { File.exists?("C:\\Program Files\\Microsoft SQL Server\\#{node['sql_server']['reg_version']}SQLEXPRESS\\MSSQL\\Log\\ERRORLOG") }
end

service service_name do
  action :nothing
end

# set the static tcp port
registry_key static_tcp_reg_key do
  values [{ :name => 'TcpPort', :type => :string, :data => node['sql_server']['port'].to_s },
    { :name => 'TcpDynamicPorts', :type => :string, :data => '' }]
  recursive true
  notifies :restart, "service[#{service_name}]", :immediately
end

#TODO Fix startup on sqlserver 2014

  %W( native_client
    command_line_utils
    clr_types
    smo
    ps_extensions ).each do |pkg|

    windows_package node['sql_server'][pkg]['package_name'] do
      source node['sql_server'][pkg]['url']
      checksum node['sql_server'][pkg]['checksum']
      installer_type :msi
      options "IACCEPTSQLNCLILICENSETERMS=#{node['sql_server']['accept_eula'] ? 'YES' : 'NO'}"
      action :install
    end

  end

# update path
windows_path 'C:\Program Files\Microsoft SQL Server\100\Tools\Binn' do
 action :add
end

# used by SQL Server providers for
# database and database_user resources
chef_gem "tiny_tds"


# Creating the alfresco user and database
batch 'Creating alfresco db' do
  code <<-EOH
  sqlcmd -E -S localhost -Q "create database alfresco"
  sqlcmd -E -S localhost -d alfresco -Q "create login alfresco with password alfresco"
  sqlcmd -E -S localhost -d alfresco -Q "create user alfresco for login alfresco"
  sqlcmd -E -S localhost -d alfresco -Q "grant alter to alfresco"
  sqlcmd -E -S localhost -d alfresco -Q "grant control to alfresco"
  EOH
  action :run
end
