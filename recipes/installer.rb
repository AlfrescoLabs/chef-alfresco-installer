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

  execute 'remove share war' do
    user 'root'
    command "del #{node["installer"]["directory"]}\\tomcat\\webapps\\share.war"
    action :run
    only_if { node["install_share_war"] == false }
  end

  execute 'remove alfresco war' do
    user 'root'
    command "del #{node["installer"]["directory"]}\\tomcat\\webapps\\alfresco.war"
    action :run
    only_if { node["install_alfresco_war"] == false }
  end

  execute 'remove solr4 war' do
    user 'root'
    command "del #{node["installer"]["directory"]}\\tomcat\\webapps\\solr4.war"
    action :run
    only_if { node["install_solr4_war"] == false }
  end

  case node['START_SERVICES']
    when true
    service "alfrescoPostgreSQL" do
      action [:start, :enable]
      supports :status => false, :restart => true, :stop => true , :start => true
      only_if { node["START_POSGRES"] == true }
    end
    service "alfrescoTomcat" do
      action [:start, :enable]
      supports :status => true, :restart => true, :stop => true , :start => true
    end
  else
    service "alfrescoPostgreSQL" do
      action :enable
      supports :status => false, :restart => true, :stop => true , :start => true
      only_if { node["START_POSGRES"] == true }
    end
    service "alfrescoTomcat" do
      action :enable
      supports :status => true, :restart => true, :stop => true , :start => true
    end
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

  template "#{node["installer"]["directory"]}/tomcat/conf/server.xml" do
    source 'server.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  template "#{node["installer"]["directory"]}/solr4/archive-SpacesStore/conf/solrcore.properties" do
    source 'solrcore-archive.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  template "#{node["installer"]["directory"]}/solr4/workspace-SpacesStore/conf/solrcore.properties" do
    source 'solrcore-workspace.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  execute 'remove share war' do
    user 'root'
    command "rm -rf #{node["installer"]["directory"]}/tomcat/webapps/share.war"
    action :run
    only_if { node["install_share_war"] == false }
  end

  execute 'remove alfresco war' do
    user 'root'
    command "rm -rf #{node["installer"]["directory"]}/tomcat/webapps/alfresco.war"
    action :run
    only_if { node["install_alfresco_war"] == false }
  end

  execute 'remove solr4 war' do
    user 'root'
    command "rm -rf #{node["installer"]["directory"]}/tomcat/webapps/solr4.war && rm -rf #{node["installer"]["directory"]}/tomcat/conf/Catalina/localhost/solr4.xml"
    action :run
    only_if { node["install_solr4_war"] == false }
  end

  remote_file "#{node["installer"]["directory"]}/qa50.lic" do
    source node['alfresco.cluster.prerequisites']
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
  end

  remote_file "#{node["installer"]["directory"]}/tomcat/libs/#{node["db.driver.filename"]}" do
    source node["db.driver.url"]
    owner "root"
    group "root"
    mode "775"
  end

  case node['START_SERVICES']
  when true
    service "alfresco" do
      action [:restart, :enable]
      supports :status => false, :restart => true
    end
    execute 'Waiting for tomcat to start' do
      command "tail -n2 #{node["installer"]["directory"]}/tomcat/logs/catalina.out | grep \"Server startup in .* ms\""
      action :run
      retries 60
      retry_delay 3
      returns 0
    end
  else
    service "alfresco" do
      action :enable
      supports :status => false, :restart => true
    end
  end

end

