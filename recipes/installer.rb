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

remote_file "/opt/alfresco.bin" do
   source "ftp://#{creds["bamboo_username"]}:#{creds["bamboo_password"]}@ftp.alfresco.com/#{node["alfresco_download_path"]}"
   checksum '90c61a7d7e73c03d5bfeb78de995d1c4b11959208e927e258b4b9e74b8ecfffa'
   owner "root"
   group "root"
   mode "755"
   action :create_if_missing
end

execute "install alfresco" do
	command "/opt/alfresco.bin --mode unattended --alfresco_admin_password admin --disable-components postgres,javaalfresco,alfrescogoogledocs --jdbc_username alfresco --jdbc_password alfresco --prefix /opt/target/alf-installation --tomcat_server_domain #{node["fqdn"]}"
	creates '/opt/target/alf-installation/alfresco.sh'
end

# template '/opt/target/alf-installation/tomcat/shared/classes/alfresco-global.properties' do
#   source 'alfresco-global.properties.erb'
#   owner 'root'
#   group 'root'
#   mode '0755'
#   :top_level
# end

service "alfresco" do
  action [:start, :enable]
  supports :status => false, :restart => true
end
