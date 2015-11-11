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
# /
case node['platform_family']
when 'windows'

  powershell_script 'Install-nfs-feature' do
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
    mode '0755'
    action :create
  end

  mount node['dir_client'] do
    device "#{node['replication_remote_ip']}:#{node['dir_server']}"
    fstype 'nfs'
  end

end
