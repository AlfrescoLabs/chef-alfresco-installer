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

creds = Chef::EncryptedDataBagItem.load("bamboo", "pass", secret = "sergiu")
creds["pass"]
remote_file "/opt/jdk-8u31-linux-x64.tar.gz" do
   source "ftp://#{creds["bamboo_username"]}:#{creds["bamboo_passwprd"]}@ftp.alfresco.com/#{node["java_download_path"]}"
   checksum 'efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437'
   owner "root"
   group "root"
   mode "644"
   action :create
end

node.set['java']['install_flavor'] = 'oracle'
node.set['java']['oracle']['accept_oracle_download_terms'] = false
node.set['java']['jdk_version'] = 8
node.set['java']['jdk']['8']['x86_64']['url'] = 'file:///opt/jdk-8u31-linux-x64.tar.gz'
node.set['java']['jdk']['8']['x86_64']['checksum'] = 'efe015e8402064bce298160538aa1c18470b78603257784ec6cd07ddfa98e437'

include_recipe "java"