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

#Setting derived attributes as needed.
case node['index.subsystem.name']
when 'solr4'
  solrcoreArchive = node['paths']['solrcoreArchive'] || "#{node['installer']['directory']}/solr4/archive-SpacesStore/conf/solrcore.properties"
  solrcoreWorkspace = node['paths']['solrcoreWorkspace'] || "#{node['installer']['directory']}/solr4/archive-SpacesStore/conf/solrcore.properties"
when 'solr'
  solrcoreArchive = node['paths']['solrcoreArchive'] || "#{node['installer']['directory']}/alf_data/solr/archive-SpacesStore/conf/solrcore.properties"
  solrcoreWorkspace = node['paths']['solrcoreWorkspace'] || "#{node['installer']['directory']}/alf_data/solr/workspace-SpacesStore/conf/solrcore.properties"
end
case node['platform_family']
  when 'windows'
    #uninstall file is required for installation idempotence
    uninstallFile = node['paths']['uninstallFile'] || "#{node['installer']['directory']}\\uninstall.exe"
    alfrescoGlobal = node['paths']['alfrescoGlobal'] || "#{node['installer']['directory']}\\tomcat\\shared\\classes\\alfresco-global.properties"
    wqsCustomProperties = node['paths']['wqsCustomProperties'] || "#{node['installer']['directory']}\\tomcat\\shared\\classes\\wqsapi-custom.properties" do
    tomcatServerXml = node['paths']['tomcatServerXml'] || "#{node['installer']['directory']}\\tomcat\\conf\\server.xml" do
    licensePath = node['paths']['licensePath'] || "#{node['installer']['directory']}/qa50.lic"
    dbDriverLocation = node['paths']['dbDriverLocation'] || "#{node['installer']['directory']}\\tomcat\\lib\\#{node['db.driver.filename']}"
  else
    uninstallFile = node['paths']['uninstallFile'] || "#{node['installer']['directory']}/alfresco.sh"
    alfrescoGlobal = node['paths']['alfrescoGlobal'] || "#{node['installer']['directory']}/tomcat/shared/classes/alfresco-global.properties"
    wqsCustomProperties = node['paths']['wqsCustomProperties'] || "#{node['installer']['directory']}/tomcat/shared/classes/wqsapi-custom.properties" do
    tomcatServerXml = node['paths']['tomcatServerXml'] || "#{node['installer']['directory']}/tomcat/conf/server.xml" do
    licensePath = node['paths']['licensePath'] || "#{node['installer']['directory']}/qa50.lic"
    dbDriverLocation = node['paths']['dbDriverLocation'] || "#{node['installer']['directory']}/tomcat/lib/#{node['db.driver.filename']}"
end

common_remote_file 'download alfresco build' do
  source node['installer']['downloadpath']
  path node['installer']['local']
end

case node['platform_family']
  when 'windows'

    directory node['installer']['directory'] do
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
    end

    windows_task 'Install Alfresco' do
      user 'Administrator'
      password 'alfresco'
      command "#{node['installer']['local']} --mode unattended --alfresco_admin_password #{node['installer']['alfresco_admin_password']} --enable-components #{node['installer']['enable-components']} --disable-components #{node['installer']['disable-components']} --jdbc_username #{node['installer']['jdbc_username']} --jdbc_password #{node['installer']['jdbc_password']} --prefix #{node['installer']['directory']}"
      run_level :highest
      frequency :monthly
      action [:create, :run]
      not_if { File.exists?(uninstallFile) }
    end

    batch 'Waiting for installation to finish ...' do
      code <<-EOH
      dir /S /P \"#{uninstallFile}\"
      EOH
      action :run
      retries 30
      retry_delay 10
      notifies :delete, 'windows_task[Install Alfresco]', :delayed
      not_if { File.exists?(uninstallFile) }
    end

    when 'solaris', 'solaris2'

      Chef::Log.error("please use 'chef-alfresco-installer::tomcat' recipe for this platform")

    else

      directory '/resources' do
        owner 'root'
        group 'root'
        mode '0775'
        action :create
      end

      execute 'Install alfresco' do
        command "#{node['installer']['local']} --mode unattended --alfresco_admin_password #{node['installer']['alfresco_admin_password']} --enable-components #{node['installer']['enable-components']} --disable-components #{node['installer']['disable-components']} --jdbc_username #{node['installer']['jdbc_username']} --jdbc_password #{node['installer']['jdbc_password']} --prefix #{node['installer']['directory']}"
        not_if { File.exists?(uninstallFile) }
      end

end

    common_template alfrescoGlobal do
      source 'alfresco-global.properties.erb'
    end

    common_template wqsCustomProperties do
      source 'wqsapi-custom.properties.erb'
    end

    common_template tomcatServerXml do
      source 'server.xml.erb'
    end

    common_template solrcoreArchive do
      source 'solrcore-archive.erb'
    end

    common_template solrcoreWorkspace do
      source 'solrcore-workspace.erb'
    end

    common_remote_file licensePath do
      source node['alfresco.cluster.prerequisites']
    end

    common_remote_file dbDriverLocation do
      source node['db.driver.url']
    end

    remove_wars 'removing unnecesarry wars'
    solr_ssl_disabler 'disabling solr ssl'

    case node['platform_family']
      when 'windows'

          service 'alfrescoPostgreSQL' do
            if node['START_SERVICES']
              action [:enable, :start]
            else
              action :enable
            end
            supports :status => false, :restart => true, :stop => true, :start => true
            only_if { node['START_POSGRES'] }
          end

          service 'alfrescoTomcat' do
            if node['START_SERVICES']
              action [:enable, :start]
            else
              action :enable
            end
            supports :status => true, :restart => true, :stop => true, :start => true
          end

    else

          service 'alfresco' do
            if node['START_SERVICES']
              action [:enable, :start]
            else
              action :enable
            end
            supports :status => false, :restart => true
          end

          execute 'Waiting for tomcat to start' do
            command "tail -n2 #{node['installer']['directory']}/tomcat/logs/catalina.out | grep \"Server startup in .* ms\""
            action :run
            retries 120
            retry_delay 3
            returns 0
          end

    end
