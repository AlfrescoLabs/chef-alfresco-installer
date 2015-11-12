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

default['java_7_download_path'] = 'ftp://172.29.103.222/chef-resources/jdk-7u75-linux-x64.tar.gz'

case node['platform_family']
when 'windows'
  default['java_8_download_path'] = 'ftp://172.29.103.222/chef-resources/jdk-8u25-windows-x64.exe'
  default['java_installer']['local'] = 'c:/jdk-8u25-windows-x64.exe'
  default['java_installer']['java_home'] = 'C:\\java'
  default['java_installer']['checksum'] = 'b68acf3048672b7e744fe8d0d2dcf201c6aacedb75fb8ed90db23a806fc47c2b'
when 'solaris', 'solaris2'
  default['java']['java_folder'] = 'jdk1.8.0_40'
  default['java']['package_name'] = 'jdk-8u40-solaris-x64.tar.gz'
  default['java_8_download_path'] = 'ftp://172.29.103.222/chef-resources/jdk-8u25-solaris-x64.tar.gz'
  default['java_installer']['local'] = '/opt/jdk-8u25-solaris-x64.tar.gz'
  default['java_installer']['checksum'] = '84b505a841eb1e206fbe6f58dee4247ef7609c5fd639e094d01f1334ca579b21'
else
  default['java_8_download_path'] = 'ftp://172.29.103.222/chef-resources/jdk-8u25-linux-x64.tar.gz'
  default['java_installer']['local'] = '/opt/jdk-8u25-linux-x64.tar.gz'
  default['java_installer']['checksum'] = '057f660799be2307d2eefa694da9d3fce8e165807948f5bcaa04f72845d2f529'
end
