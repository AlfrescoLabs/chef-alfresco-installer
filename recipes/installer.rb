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

    directory node['installer']['directory'] do
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
    end

    remote_file node['installer']['local'] do
      source node['installer']['downloadpath']
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      action :create_if_missing
    end

    windows_task 'Install Alfresco' do
      user 'Administrator'
      password 'alfresco'
      command "#{node['installer']['local']} --mode unattended --alfresco_admin_password #{node['installer']['alfresco_admin_password']} --enable-components #{node['installer']['enable-components']} --disable-components #{node['installer']['disable-components']} --jdbc_username #{node['installer']['jdbc_username']} --jdbc_password #{node['installer']['jdbc_password']} --prefix #{node['installer']['directory']}"
      run_level :highest
      frequency :monthly
      action [:create, :run]
      not_if { File.exists?("#{node['installer']['directory']}\\uninstall.exe") }
    end

    batch 'Waiting for installation to finish ...' do
      code <<-EOH
      dir /S /P \"C:\\alf-installation\\uninstall.exe\"
      EOH
      action :run
      retries 30
      retry_delay 10
      notifies :delete, 'windows_task[Install Alfresco]', :delayed
      not_if { File.exists?("#{node['installer']['directory']}\\uninstall.exe") }
    end

    template node['alfresco-global']['directory'] do
      source 'alfresco-global.properties.erb'
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      :top_level
    end

    template "#{node['installer']['directory']}\\tomcat\\conf\\server.xml" do
      source 'server.xml.erb'
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      :top_level
    end

    template "#{node['installer']['directory']}\\solr4\\archive-SpacesStore\\conf\\solrcore.properties" do
      source 'solrcore-archive.erb'
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      :top_level
    end

    template "#{node['installer']['directory']}\\solr4\\workspace-SpacesStore\\conf\\solrcore.properties" do
      source 'solrcore-workspace.erb'
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      :top_level
    end

    execute 'remove share war' do
      user 'root'
      command "del #{node['installer']['directory']}\\tomcat\\webapps\\share.war"
      action :run
      only_if { !node['install_share_war'] }
    end

    execute 'remove alfresco war' do
      user 'root'
      command "del #{node['installer']['directory']}\\tomcat\\webapps\\alfresco.war"
      action :run
      only_if { !node['install_alfresco_war'] }
    end

    execute 'remove solr4 war' do
      user 'root'
      command "del #{node['installer']['directory']}\\tomcat\\webapps\\solr4.war"
      action :run
      only_if { !node['install_solr4_war'] }
    end

    remote_file "#{node['installer']['directory']}/qa50.lic" do
      source node['alfresco.cluster.prerequisites']
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      action :create_if_missing
    end

    remote_file "#{node['installer']['directory']}\\tomcat\\lib\\#{node['db.driver.filename']}" do
      source node['db.driver.url']
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      action :create_if_missing
    end

    case node['START_SERVICES']
      when true
        service 'alfrescoPostgreSQL' do
          action [:enable, :start]
          supports :status => false, :restart => true, :stop => true, :start => true
          only_if { node['START_POSGRES'] }
        end
        service 'alfrescoTomcat' do
          action [:enable, :start]
          supports :status => true, :restart => true, :stop => true, :start => true
        end
      else
        service 'alfrescoPostgreSQL' do
          action :enable
          supports :status => false, :restart => true, :stop => true, :start => true
          only_if { node['START_POSGRES'] }
        end
        service 'alfrescoTomcat' do
          action :enable
          supports :status => true, :restart => true, :stop => true, :start => true
        end
    end


  when 'solaris', 'solaris2'

    include recipe 'tomcat'

  else

    directory '/resources' do
      owner 'root'
      group 'root'
      mode '0775'
      action :create
    end

    remote_file node['installer']['local'] do
      source node['installer']['downloadpath']
      owner 'root'
      group 'root'
      mode '775'
      action :create_if_missing
      sensitive true
      not_if { node['localPath'] }
    end

    execute 'Install alfresco' do
      command "#{node['installer']['local']} --mode unattended --alfresco_admin_password #{node['installer']['alfresco_admin_password']} --enable-components #{node['installer']['enable-components']} --disable-components #{node['installer']['disable-components']} --jdbc_username #{node['installer']['jdbc_username']} --jdbc_password #{node['installer']['jdbc_password']} --prefix #{node['installer']['directory']}"
      not_if { File.exists?("#{node['installer']['directory']}//alfresco.sh") }
    end

    template node['alfresco-global']['directory'] do
      source 'alfresco-global.properties.erb'
      owner 'root'
      group 'root'
      mode '0755'
      :top_level
    end

    template "#{node['installer']['directory']}/tomcat/conf/server.xml" do
      source 'server.xml.erb'
      owner 'root'
      group 'root'
      mode 00755
      :top_level
    end

    template "#{node['installer']['directory']}/solr4/archive-SpacesStore/conf/solrcore.properties" do
      source 'solrcore-archive.erb'
      owner 'root'
      group 'root'
      mode 00755
      :top_level
    end

    template "#{node['installer']['directory']}/solr4/workspace-SpacesStore/conf/solrcore.properties" do
      source 'solrcore-workspace.erb'
      owner 'root'
      group 'root'
      mode 00755
      :top_level
    end

    if node['disable_solr_ssl']
      unless node['install_alfresco_war']

      end
      unless node['install_solr4_war']

      end
    end

    execute 'remove share war' do
      user 'root'
      command "rm -rf #{node['installer']['directory']}/tomcat/webapps/share.war"
      action :run
      only_if { !node['install_share_war'] }
    end

    execute 'remove alfresco war' do
      user 'root'
      command "rm -rf #{node['installer']['directory']}/tomcat/webapps/alfresco.war"
      action :run
      only_if { !node['install_alfresco_war'] }
    end

    execute 'remove solr4 war' do
      user 'root'
      command "rm -rf #{node['installer']['directory']}/tomcat/webapps/solr4.war && rm -rf #{node['installer']['directory']}/tomcat/conf/Catalina/localhost/solr4.xml"
      action :run
      only_if { !node['install_solr4_war'] }
    end

    remote_file "#{node['installer']['directory']}/qa50.lic" do
      source node['alfresco.cluster.prerequisites']
      owner 'root'
      group 'root'
      mode '775'
      action :create_if_missing
    end

    remote_file "#{node['installer']['directory']}/tomcat/lib/#{node['db.driver.filename']}" do
      source node['db.driver.url']
      owner 'root'
      group 'root'
      mode '775'
    end

    case node['START_SERVICES']
      when true
        service 'alfresco' do
          action [:restart, :enable]
          supports :status => false, :restart => true
        end
        execute 'Waiting for tomcat to start' do
          command "tail -n2 #{node['installer']['directory']}/tomcat/logs/catalina.out | grep \"Server startup in .* ms\""
          action :run
          retries 60
          retry_delay 3
          returns 0
        end
      else
        service 'alfresco' do
          action :enable
          supports :status => false, :restart => true
        end
    end

end

