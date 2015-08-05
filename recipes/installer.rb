# ~FC005
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
  node.default['paths']['solrPath'] = "#{node['installer']['directory']}/solr4"
when 'solr'
  node.default['paths']['solrPath'] = "#{node['installer']['directory']}/alf_data/solr"
end

node.default['paths']['solrcoreArchive'] = "#{node['paths']['solrPath']}/archive-SpacesStore/conf/solrcore.properties"
node.default['paths']['solrcoreWorkspace'] = "#{node['paths']['solrPath']}/workspace-SpacesStore/conf/solrcore.properties"

case node['platform_family']
  when 'windows'
    #uninstall file is required for installation idempotence
    node.default['paths']['uninstallFile'] = "#{node['installer']['directory']}\\uninstall.exe"
    node.default['paths']['alfrescoGlobal'] = "#{node['installer']['directory']}\\tomcat\\shared\\classes\\alfresco-global.properties"
    node.default['paths']['wqsCustomProperties'] = "#{node['installer']['directory']}\\tomcat\\shared\\classes\\wqsapi-custom.properties"
    node.default['paths']['tomcatServerXml'] = "#{node['installer']['directory']}\\tomcat\\conf\\server.xml"
    node.default['paths']['licensePath'] = "#{node['installer']['directory']}/qa50.lic"
    node.default['paths']['dbDriverLocation'] = "#{node['installer']['directory']}\\tomcat\\lib\\#{node['db.driver.filename']}"
  else
    node.default['paths']['uninstallFile'] = "#{node['installer']['directory']}/alfresco.sh"
    node.default['paths']['alfrescoGlobal'] = "#{node['installer']['directory']}/tomcat/shared/classes/alfresco-global.properties"
    node.default['paths']['wqsCustomProperties'] = "#{node['installer']['directory']}/tomcat/shared/classes/wqsapi-custom.properties"
    node.default['paths']['tomcatServerXml'] = "#{node['installer']['directory']}/tomcat/conf/server.xml"
    node.default['paths']['licensePath'] = "#{node['installer']['directory']}/qa50.lic"
    node.default['paths']['dbDriverLocation'] = "#{node['installer']['directory']}/tomcat/lib/#{node['db.driver.filename']}"
end
node.default["alfresco"]["keystore"] = "#{node['installer']['directory']}/alf_data/keystore"
node.default["alfresco"]["keystore_file"] = "#{node['alfresco']['keystore']}/ssl.keystore"
node.default["alfresco"]["truststore_file"] = "#{node['alfresco']['keystore']}/ssl.truststore"

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
      not_if { File.exists?(node['paths']['uninstallFile']) }
    end

    batch 'Waiting for installation to finish ...' do
      code <<-EOH
      dir /S /P \"#{node['paths']['uninstallFile']}\"
      EOH
      action :run
      retries 30
      retry_delay 10
      notifies :delete, 'windows_task[Install Alfresco]', :delayed
      not_if { File.exists?(node['paths']['uninstallFile']) }
    end

    when 'solaris', 'solaris2'

      Chef::Log.error("please use 'chef-alfresco-installer::tomcat' recipe for this platform")

    else

      execute 'Install alfresco' do
        command "#{node['installer']['local']} --mode unattended --alfresco_admin_password #{node['installer']['alfresco_admin_password']} --enable-components #{node['installer']['enable-components']} --disable-components #{node['installer']['disable-components']} --jdbc_username #{node['installer']['jdbc_username']} --jdbc_password #{node['installer']['jdbc_password']} --prefix #{node['installer']['directory']}"
        not_if { File.exists?(node['paths']['uninstallFile']) }
      end

end

    common_template node['paths']['alfrescoGlobal'] do
      source 'globalProps/alfresco-global.properties.erb'
    end

    common_template node['paths']['wqsCustomProperties'] do
      source 'customProps/wqsapi-custom.properties.erb'
    end

if node['installer.database-version'] != 'none'
  common_remote_file node['paths']['dbDriverLocation'] do
    source node['db.driver.url']
  end
end
    if node['paths']['licensePath']
      common_remote_file node['paths']['licensePath'] do
        source node['alfresco.cluster.prerequisites']
      end
    end

    common_template node['paths']['tomcatServerXml'] do
      source 'tomcat/server.xml.erb'
    end

    solrcoreProps = {
      "data.dir.root=" => node['paths']['solrPath'],
      "alfresco.version=" => node['alfresco.version'],
      "alfresco.host=" => node['solr.target.alfresco.host'],
      "alfresco.port=" => node['solr.target.alfresco.port'],
      "alfresco.port.ssl=" => node['solr.target.alfresco.port.ssl'],
      "alfresco.baseUrl=" => node['solr.target.alfresco.baseUrl']
    }

    solrcoreProps.each do |key,value|

      replace_or_add 'replace in solrcoreArchive' do
        path node['paths']['solrcoreArchive']
        pattern "#{key}.*"
        line "#{key}#{value}"
      end

      replace_or_add 'replace in solrcoreWorkspace' do
        path node['paths']['solrcoreWorkspace']
        pattern "#{key}.*"
        line "#{key}#{value}"
      end

    end

    replace_or_add node['paths']['solrcoreArchive'] do
      pattern "alfresco.secureComms=.*"
      line "data.dir.root=none"
      only_if { node['disable_solr_ssl'] }
    end

    replace_or_add node['paths']['solrcoreWorkspace'] do
      pattern "alfresco.secureComms=.*"
      line "data.dir.root=none"
      only_if { node['disable_solr_ssl'] }
    end

    remove_wars 'removing unnecesarry wars'

    solr_ssl_disabler 'disabling solr ssl'

    # %W(#{node['paths']['solrPath']}/templates/store
    # #{node['paths']['solrPath']}/templates/store/conf
    # #{node['certificates']['directory']}).each do |path|
    #   directory path do
    #     owner 'root'
    #     group 'root'
    #     mode 00775
    #     action :create
    #   end
    # end
    #
    # %W(browser.p12
    # ssl.keystore
    # ssl.repo.client.crt
    # ssl.repo.client.keystore
    # ssl.repo.client.truststore
    # ssl.repo.crt
    # ssl.truststore).each do |file|
    #   common_remote_file 'download certificates' do
    #     source "#{node['certificates']['downloadpath']}/#{file}"
    #     path "#{node['certificates']['directory']}/#{file}"
    #   end
    # end
    #
    # common_template "#{node['installer']['directory']}/applicert.sh" do
    #   source 'solr/applicert.sh.erb'
    # end
    #
    # execute 'Apply Certificates' do
    #   command "sh #{node['installer']['directory']}/applicert.sh"
    #   action :run
    # end

    case node['platform_family']
      when 'windows'

          service 'alfrescoPostgreSQL' do
            if node['START_POSGRES']
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
            only_if { node['START_SERVICES'] }
          end

    else

          service 'alfresco' do
            if node['START_SERVICES']
              action [:enable, :restart]
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
            only_if { node['START_SERVICES'] }
          end

    end
