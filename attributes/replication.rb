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
  default['dir_client'] = 'M:/'
  default['windows_drive'] = 'M:'
  default['dir_server'] = '/Replicate'
  default['dir_server_local'] = 'C:\\Replicate'

  normal['nfs']['service_provider']['lock'] = ''
  normal['nfs']['service_provider']['portmap'] = ''
  normal['nfs']['service_provider']['server'] = ''
  normal['nfs']['service_provider']['idmap'] = ''
else
  default['dir_client'] = '/opt/Replicate'
  default['dir_server'] = '/opt/Replicate'
end

default['replication_remote_ip'] = node['ipaddress']
default['replication.enabled'] = 'false'
