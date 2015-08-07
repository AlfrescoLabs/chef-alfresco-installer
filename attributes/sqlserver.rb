default['sql_server']['accept_eula'] = true
default['sql_server']['product_key'] = nil
default['sql_server']['version'] = '2008R2'

case node['sql_server']['version']
when '2008R2'
  default['sql_server']['reg_version'] = 'MSSQL10_50.'
when '2012'
  default['sql_server']['reg_version'] = 'MSSQL11.'
end

default['sql_server']['install_dir']    = 'C:\Program Files\Microsoft SQL Server'
default['sql_server']['port']           = 1433

default['sql_server']['instance_name']  = 'SQLEXPRESS'
default['sql_server']['instance_dir']   = 'C:\Program Files\Microsoft SQL Server'
default['sql_server']['shared_wow_dir']   = 'C:\Program Files (x86)\Microsoft SQL Server'
default['sql_server']['feature_list'] = 'SQLENGINE,REPLICATION,SNAC_SDK'
default['sql_server']['agent_account'] =  'NT AUTHORITY\NETWORK SERVICE'
default['sql_server']['agent_startup'] =  'Disabled'
default['sql_server']['rs_mode'] = 'FilesOnlyMode'
default['sql_server']['rs_account'] = 'NT AUTHORITY\NETWORK SERVICE'
default['sql_server']['rs_startup'] = 'Automatic'
default['sql_server']['browser_startup'] = 'Disabled'
default['sql_server']['sysadmins'] = ['Administrator']
default['sql_server']['sql_account'] = 'NT AUTHORITY\NETWORK SERVICE'

default['sql_server']['server']['installer_timeout'] = 1500

if kernel['machine'] =~ /x86_64/
  case node['sql_server']['version']
  when '2008R2'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/D/1/8/D1869DEC-2638-4854-81B7-0F37455F35EA/SQLEXPR_x64_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2008 R2 (64-bit)'
  when '2012'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLEXPR_x64_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2012 (64-bit)'
  end

else
  case node['sql_server']['version']
  when '2008R2'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/D/1/8/D1869DEC-2638-4854-81B7-0F37455F35EA/SQLEXPR32_x86_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2008 R2 (32-bit)'
  when '2012'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x86/SQLEXPR_x86_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2012 (32-bit)'
  end

end
