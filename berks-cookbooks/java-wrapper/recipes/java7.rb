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

remote_file '/opt/jdk-7u75-linux-x64.tar.gz' do
   source node['java_7_download_path']
   checksum '460959219b534dc23e34d77abc306e180b364069b9fc2b2265d964fa2c281610'
   owner 'root'
   group 'root'
   mode '644'
   action :create
end

node.set['java']['install_flavor'] = 'oracle'
node.set['java']['oracle']['accept_oracle_download_terms'] = false
node.set['java']['jdk_version'] = 7
node.set['java']['jdk']['7']['x86_64']['url'] = 'file:///opt/jdk-7u75-linux-x64.tar.gz'
node.set['java']['jdk']['7']['x86_64']['checksum'] = '460959219b534dc23e34d77abc306e180b364069b9fc2b2265d964fa2c281610'

include_recipe 'java'