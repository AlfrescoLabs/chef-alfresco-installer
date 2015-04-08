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

creds = Chef::EncryptedDataBagItem.load("bamboo", "pass")
creds["pass"] # will be decrypted

case node['platform_family']
when 'windows'

  directory node["installer"]["directory"] do
    rights :read, "Administrator"
    rights :write, "Administrator"
    rights :full_control, "Administrator"
    rights :full_control, "Administrator", :applies_to_children => true
    group "Administrators"
  end

  windows_package "Alfresco One" do
    source node["installer"]["downloadpath"]
    checksum checksum node["installer"]["checksum"]
    action :install
    installer_type :custom
    options "--mode unattended --alfresco_admin_password #{node["installer"]["alfresco_admin_password"]} --enable-components #{node["installer"]["enable-components"]} --disable-components #{node["installer"]["disable-components"]} --jdbc_username #{node["installer"]["jdbc_username"]} --jdbc_password #{node["installer"]["jdbc_password"]} --prefix #{node["installer"]["directory"]}"
  end

  template node["alfresco-global"]["directory"] do
    source 'alfresco-global.properties.erb'
    rights :read, "Administrator"
    rights :write, "Administrator"
    rights :full_control, "Administrator"
    rights :full_control, "Administrator", :applies_to_children => true
    group "Administrators"
    :top_level
  end

  service "alfrescoPostgreSQL" do
    action [:start, :enable]
    supports :status => false, :restart => true, :stop => true , :start => true
  end

  service "alfrescoTomcat" do
    action [:start, :enable]
    supports :status => true, :restart => true, :stop => true , :start => true
  end

else

  directory "/resources" do
    owner "root"
    group "root"
    mode "0775"
    action :create
  end

  remote_file node["installer"]["local"] do
    source node["installer"]["downloadpath"]
    checksum node["installer"]["checksum"]
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
    not_if { node["localPath"] == true }
  end

  execute "Install alfresco" do
    command "#{node["installer"]["local"]} --mode unattended --alfresco_admin_password #{node["installer"]["alfresco_admin_password"]} --enable-components #{node["installer"]["enable-components"]} --disable-components #{node["installer"]["disable-components"]} --jdbc_username #{node["installer"]["jdbc_username"]} --jdbc_password #{node["installer"]["jdbc_password"]} --prefix #{node["installer"]["directory"]}"
    creates '/opt/target/alf-installation/alfresco.sh'
  end

  template node["alfresco-global"]["directory"] do
    source 'alfresco-global.properties.erb'
    owner 'root'
    group 'root'
    mode '0755'
    :top_level
  end

  service "alfresco" do
    action [:restart, :enable]
    supports :status => false, :restart => true
  end

end

