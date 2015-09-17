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

default['sql_server']['accept_eula'] = true
default['sql_server']['product_key'] = nil
default['sql_server']['version'] = '2008R2'

case node['sql_server']['version']
when '2008R2'
  default['sql_server']['reg_version'] = 'MSSQL10_50.'
when '2012'
  default['sql_server']['reg_version'] = 'MSSQL11.'
when '2014'
  default['sql_server']['reg_version'] = 'MSSQL12.'
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
    default['sql_server']['native_client']['url']               = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/sqlncli.msi'
    default['sql_server']['native_client']['checksum']          = '012aca6cef50ed784f239d1ed5f6923b741d8530b70d14e9abcb3c7299a826cc'
    default['sql_server']['native_client']['package_name']      = 'Microsoft SQL Server 2008 R2 Native Client'
    default['sql_server']['command_line_utils']['url']          = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/SqlCmdLnUtils.msi'
    default['sql_server']['command_line_utils']['checksum']     = '5a321cad6c5f0f5280aa73ab8ed695f8a6369fa00937df538a971729552340b8'
    default['sql_server']['command_line_utils']['package_name'] = 'Microsoft SQL Server 2008 R2 Command Line Utilities'
    default['sql_server']['clr_types']['url']                   = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/SQLSysClrTypes.msi'
    default['sql_server']['clr_types']['checksum']              = '0ad774b0d124c83bbf0f31838ed9c628dd76d83ab2c8c57fd5e2f5305580fff2'
    default['sql_server']['clr_types']['package_name']          = 'Microsoft SQL Server System CLR Types (x64)'
    default['sql_server']['smo']['url']                         = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/SharedManagementObjects.msi'
    default['sql_server']['smo']['checksum']                    = 'dccec315e3c345a7efb5951f3e9b27512b4e91d73ec48c7196633b7449115b7c'
    default['sql_server']['smo']['package_name']                = 'Microsoft SQL Server 2008 R2 Management Objects (x64)'
    default['sql_server']['ps_extensions']['url']               = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/PowerShellTools.msi'
    default['sql_server']['ps_extensions']['checksum']          = 'eeb46c297523c7de388188ba27263a51b75e85efd478036a12040cc04d4ab344'
    default['sql_server']['ps_extensions']['package_name']      = 'Windows PowerShell Extensions for SQL Server 2008 R2'
  when '2012'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLEXPR_x64_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2012 (64-bit)'
    default['sql_server']['native_client']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/sqlncli.msi'
    default['sql_server']['native_client']['checksum']          = '1364bf4c37a09ce3c87b029a2db4708f066074b1eaa22aa4e86d437b7b05203d'
    default['sql_server']['native_client']['package_name']      = 'Microsoft SQL Server 2012 Native Client'
    default['sql_server']['command_line_utils']['url']          = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/SqlCmdLnUtils.msi'
    default['sql_server']['command_line_utils']['checksum']     = 'ad9186c1acc786c116d0520fc642f6b315c4b8b62fc589d8e2763a2da4c80347'
    default['sql_server']['command_line_utils']['package_name'] = 'Microsoft SQL Server 2012 Command Line Utilities'
    default['sql_server']['clr_types']['url']                   = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/SQLSysClrTypes.msi'
    default['sql_server']['clr_types']['checksum']              = '674c396e9c9bf389dd21cec0780b3b4c808ff50c570fa927b07fa620db7d4537'
    default['sql_server']['clr_types']['package_name']          = 'Microsoft SQL Server System CLR Types (x64)'
    default['sql_server']['smo']['url']                         = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/SharedManagementObjects.msi'
    default['sql_server']['smo']['checksum']                    = 'ed753d85b51e7eae381085cad3dcc0f29c0b72f014f8f8fba1ad4e0fe387ce0a'
    default['sql_server']['smo']['package_name']                = 'Microsoft SQL Server 2008 R2 Management Objects (x64)'
    default['sql_server']['ps_extensions']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/PowerShellTools.MSI'
    default['sql_server']['ps_extensions']['checksum']          = '532261175cc6116439b89be476fa403737d85f2ee742f2958cf9c066bcbdeaba'
    default['sql_server']['ps_extensions']['package_name']      = 'Windows PowerShell Extensions for SQL Server 2008 R2'
  when '2014'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/1/5/6/156992E6-F7C7-4E55-833D-249BD2348138/ENU/x64/SQLEXPR_x64_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2014 (64-bit)'
    default['sql_server']['native_client']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/sqlncli.msi'
    default['sql_server']['native_client']['checksum']          = '1364bf4c37a09ce3c87b029a2db4708f066074b1eaa22aa4e86d437b7b05203d'
    default['sql_server']['native_client']['package_name']      = 'Microsoft SQL Server 2012 Native Client'
    default['sql_server']['command_line_utils']['url']          = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/SqlCmdLnUtils.msi'
    default['sql_server']['command_line_utils']['checksum']     = 'ad9186c1acc786c116d0520fc642f6b315c4b8b62fc589d8e2763a2da4c80347'
    default['sql_server']['command_line_utils']['package_name'] = 'Microsoft SQL Server 2012 Command Line Utilities'
    default['sql_server']['clr_types']['url']                   = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/SQLSysClrTypes.msi'
    default['sql_server']['clr_types']['checksum']              = '674c396e9c9bf389dd21cec0780b3b4c808ff50c570fa927b07fa620db7d4537'
    default['sql_server']['clr_types']['package_name']          = 'Microsoft SQL Server System CLR Types (x64)'
    default['sql_server']['smo']['url']                         = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/SharedManagementObjects.msi'
    default['sql_server']['smo']['checksum']                    = 'ed753d85b51e7eae381085cad3dcc0f29c0b72f014f8f8fba1ad4e0fe387ce0a'
    default['sql_server']['smo']['package_name']                = 'Microsoft SQL Server 2008 R2 Management Objects (x64)'
    default['sql_server']['ps_extensions']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/PowerShellTools.MSI'
    default['sql_server']['ps_extensions']['checksum']          = '532261175cc6116439b89be476fa403737d85f2ee742f2958cf9c066bcbdeaba'
    default['sql_server']['ps_extensions']['package_name']      = 'Windows PowerShell Extensions for SQL Server 2008 R2'
  end

else
  case node['sql_server']['version']
  when '2008R2'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/D/1/8/D1869DEC-2638-4854-81B7-0F37455F35EA/SQLEXPR32_x86_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2008 R2 (32-bit)'
    default['sql_server']['native_client']['url']               = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x86/sqlncli.msi'
    default['sql_server']['native_client']['checksum']          = '35c4b98f7f5f951cae9939c637593333c44aee920efbd4763b7bdca1e23ac335'
    default['sql_server']['native_client']['package_name']      = 'Microsoft SQL Server 2008 R2 Native Client'
    default['sql_server']['command_line_utils']['url']          = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x86/SqlCmdLnUtils.msi'
    default['sql_server']['command_line_utils']['checksum']     = 'b39981fa713feedaaf532ab393bf312ec7b5f63bb5f726b9d0e1ae5a65350eee'
    default['sql_server']['command_line_utils']['package_name'] = 'Microsoft SQL Server 2008 R2 Command Line Utilities'
    default['sql_server']['clr_types']['url']                   = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x86/SQLSysClrTypes.msi'
    default['sql_server']['clr_types']['checksum']              = '6166f2fa57fb971699ff66461434b2418820306c094b5dc3e7df1b827275bf20'
    default['sql_server']['clr_types']['package_name']          = 'Microsoft SQL Server System CLR Types (x86)'
    default['sql_server']['smo']['url']                         = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x86/SharedManagementObjects.msi'
    default['sql_server']['smo']['checksum']                    = '4b1ec03bc5cc69481b9da6b2db41ae6d3adeacffe854cc209d125e83a739f937'
    default['sql_server']['smo']['package_name']                = 'Microsoft SQL Server 2008 R2 Management Objects (x86)'
    default['sql_server']['ps_extensions']['url']               = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x86/PowerShellTools.msi'
    default['sql_server']['ps_extensions']['checksum']          = 'b0d63f8d3e3455fd390dfa0fefebde245bf1a272eb96a968d025f2cbd7842b6c'
    default['sql_server']['ps_extensions']['package_name']      = 'Windows PowerShell Extensions for SQL Server 2008 R2'
  when '2012'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x86/SQLEXPR_x86_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2012 (32-bit)'
    default['sql_server']['native_client']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/sqlncli.msi'
    default['sql_server']['native_client']['checksum']          = '9bb7b584ecd2cbe480607c4a51728693b2c99c6bc38fa9213b5b54a13c34b7e2'
    default['sql_server']['native_client']['package_name']      = 'Microsoft SQL Server 2012 Native Client'
    default['sql_server']['command_line_utils']['url']          = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/SqlCmdLnUtils.msi'
    default['sql_server']['command_line_utils']['checksum']     = '0257292d2b038f012777489c9af51ea75b7bee92efa9c7d56bc25803c9e39801'
    default['sql_server']['command_line_utils']['package_name'] = 'Microsoft SQL Server 2012 Command Line Utilities'
    default['sql_server']['clr_types']['url']                   = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/SQLSysClrTypes.msi'
    default['sql_server']['clr_types']['checksum']              = 'a9cf3e40c9a06dd9e9d0f689f3636ba3f58ec701b9405ba67881a802271bbba1'
    default['sql_server']['clr_types']['package_name']          = 'Microsoft SQL Server System CLR Types (x86)'
    default['sql_server']['smo']['url']                         = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/SharedManagementObjects.msi'
    default['sql_server']['smo']['checksum']                    = 'afc0eccb35c979801344b0dc04556c23c8b957f1bdee3530bc1a59d5c704ce64'
    default['sql_server']['smo']['package_name']                = 'Microsoft SQL Server 2008 R2 Management Objects (x86)'
    default['sql_server']['ps_extensions']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/PowerShellTools.MSI'
    default['sql_server']['ps_extensions']['checksum']          = '6a181aeb27b4baec88172c2e80f33ea3419c7e86f6aea0ed1846137bc9144fc6'
    default['sql_server']['ps_extensions']['package_name']      = 'Windows PowerShell Extensions for SQL Server 2008 R2'
  when '2014'
    default['sql_server']['server']['url']          = 'http://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/Express%2032BIT/SQLEXPR_x86_ENU.exe'
    default['sql_server']['server']['package_name'] = 'Microsoft SQL Server 2014 (32-bit)'
    default['sql_server']['native_client']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/sqlncli.msi'
    default['sql_server']['native_client']['checksum']          = '9bb7b584ecd2cbe480607c4a51728693b2c99c6bc38fa9213b5b54a13c34b7e2'
    default['sql_server']['native_client']['package_name']      = 'Microsoft SQL Server 2012 Native Client'
    default['sql_server']['command_line_utils']['url']          = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/SqlCmdLnUtils.msi'
    default['sql_server']['command_line_utils']['checksum']     = '0257292d2b038f012777489c9af51ea75b7bee92efa9c7d56bc25803c9e39801'
    default['sql_server']['command_line_utils']['package_name'] = 'Microsoft SQL Server 2012 Command Line Utilities'
    default['sql_server']['clr_types']['url']                   = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/SQLSysClrTypes.msi'
    default['sql_server']['clr_types']['checksum']              = 'a9cf3e40c9a06dd9e9d0f689f3636ba3f58ec701b9405ba67881a802271bbba1'
    default['sql_server']['clr_types']['package_name']          = 'Microsoft SQL Server System CLR Types (x86)'
    default['sql_server']['smo']['url']                         = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/SharedManagementObjects.msi'
    default['sql_server']['smo']['checksum']                    = 'afc0eccb35c979801344b0dc04556c23c8b957f1bdee3530bc1a59d5c704ce64'
    default['sql_server']['smo']['package_name']                = 'Microsoft SQL Server 2008 R2 Management Objects (x86)'
    default['sql_server']['ps_extensions']['url']               = 'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x86/PowerShellTools.MSI'
    default['sql_server']['ps_extensions']['checksum']          = '6a181aeb27b4baec88172c2e80f33ea3419c7e86f6aea0ed1846137bc9144fc6'
    default['sql_server']['ps_extensions']['package_name']      = 'Windows PowerShell Extensions for SQL Server 2008 R2'
  end
end
