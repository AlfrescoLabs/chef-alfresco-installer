#
# Cookbook Name:: alfrescotest
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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
    source "ftp://#{creds["bamboo_username"]}:#{creds["bamboo_password"]}@ftp.alfresco.com/#{node["installer"]["downloadpath"]}"
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

when 'solaris','solaris2'
  
  include recipe "tomcat"
  
else

  directory "/resources" do
    owner "root"
    group "root"
    mode "0775"
    action :create
  end

  remote_file node["installer"]["local"] do
    source "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node["installer"]["downloadpath"]}"
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

