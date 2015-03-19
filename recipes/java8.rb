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
creds["pass"]

case node["platform"]
when "windows"

  windows_package "Java SE Development Kit 8 Update 40 (64-bit)" do
    source "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node['java_8_download_path']}"
    checksum node["java_installer"]["checksum"]
    action :install
    installer_type :custom
    options "/s INSTALLDIR:#{node["java_installer"]["java_home"]}"
  end

  env "JAVA_HOME" do
    value node["java_installer"]["java_home"]
  end

  windows_path "#{node["java_installer"]["java_home"]}bin" do
    action :add
  end

when 'solaris','solaris2'
  
  directory "/resources" do
    owner "root"
    group "root"
    mode "0775"
    action :create
  end

  remote_file node["java_installer"]["local"] do
    source "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node['java_8_download_path']}"
    checksum node["java_installer"]["checksum"]
    owner "root"
    group "root"
    mode "644"
    action :create
    sensitive true
    not_if { node["localPath"] == true }
  end
  
  bash 'install_java' do
    user 'root'
    cwd '/resources'
    code <<-EOH
    tar xvf #{node['java']['package_name']}
    rm -rf /usr/java/*
    mv #{node['java']['java_folder']}/* /usr/java/
    EOH
    not_if { ::File.directory?("/usr/java/") }
  end

else

  directory "/resources" do
    owner "root"
    group "root"
    mode "0775"
    action :create
  end

  remote_file node["java_installer"]["local"] do
    source "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node['java_8_download_path']}"
    checksum node["java_installer"]["checksum"]
    owner "root"
    group "root"
    mode "644"
    action :create
    sensitive true
    not_if { node["localPath"] == true }
  end

  node.set['java']['install_flavor'] = 'oracle'
  node.set['java']['oracle']['accept_oracle_download_terms'] = false
  node.set['java']['jdk_version'] = 8
  node.set['java']['jdk']['8']['x86_64']['url'] = "file:///#{node["java_installer"]["local"]}"
  node.set['java']['jdk']['8']['x86_64']['checksum'] = node["java_installer"]["checksum"]

  include_recipe "java"

end
