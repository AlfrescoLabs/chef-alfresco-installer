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
default["localPath"] = false
default['java_7_download_path'] = "ftp://172.29.101.28/chef-resources/jdk-7u75-linux-x64.tar.gz"

case node['platform_family']
when 'windows'
  default['java_8_download_path'] = "ftp://172.29.101.28/chef-resources/jdk-8u40-windows-x64.exe"
  default["java_installer"]["local"] = "c:/jdk-8u40-windows-x64.exe"
  default["java_installer"]["java_home"] = "C:\\java\\jdk\\"
  default["java_installer"]["checksum"] = '71f28563968a5acdf5cbca19154a60f4bff3b400f30b87c0272ba770d4008dbd'
when 'solaris','solaris2'
  default['java']['java_folder'] = "jdk1.8.0_40"
  default['java']['package_name'] = "jdk-8u40-solaris-x64.tar.gz"
  default['java_8_download_path'] = "ftp://172.29.101.28/chef-resources/jdk-8u40-solaris-x64.tar.gz"
  default["java_installer"]["local"] = "resources/jdk-8u40-solaris-x64.tar.gz"
  default["java_installer"]["checksum"] = '8d880e24a12197b8349493f15092a6b19468f8dfe22466325961bbfc2020d7f4'
else
  default['java_8_download_path'] = "ftp://172.29.101.28/chef-resources/jdk-8u31-linux-x64.tar.gz"
  default["java_installer"]["local"] = "resources/jdk-8u31-linux-x64.tar.gz"
  default["java_installer"]["checksum"] = 'efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437'
end