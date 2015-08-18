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

win_user = node['installer']['win_user']
win_group = node['installer']['win_group']
unix_user = node['installer']['unix_user']
unix_group = node['installer']['unix_group']

if node['platform_family'] == 'windows' and win_user != 'Administrator'
  user win_user
  group win_group do
    members win_user
    append true
  end
elsif unix_user != 'root'
  user unix_user do
    only_if
  end
  group unix_group do
    members unix_user
    append true
  end
end

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
  win_user "Administrator"
  win_group "Administrators"
  unix_user "root"
  unix_group "root"
end

%W(#{node['installer']['directory']}
#{node['installer']['directory']}/amps
#{node['installer']['directory']}/amps_share).each do |dir|
  directory dir do
    case node['platform_family']
      when 'windows'
        rights :read, "Administrator"
        rights :write, "Administrator"
        rights :full_control, "Administrator"
        rights :full_control, "Administrator", :applies_to_children => true
        group "Administrators"
      else
        owner "root"
        group "root"
        mode 00755
        :top_level
    end
  end
end

if node['amps']['alfresco'] and node['amps']['alfresco'].length > 0
  node['amps']['alfresco'].each do |url|
    common_remote_file "#{node['installer']['directory']}/amps/#{::File.basename(url)}" do
      source url
      win_user win_user
      win_group win_group
      unix_user unix_user
      unix_group unix_group
    end
  end
end

if node['amps']['share'] and node['amps']['share'].length > 0
  node['amps']['share'].each do |url|
    common_remote_file "#{node['installer']['directory']}/amps_share/#{::File.basename(url)}" do
      source url
      win_user win_user
      win_group win_group
      unix_user unix_user
      unix_group unix_group
    end
  end
end

case node['platform_family']
  when 'windows'

    windows_task 'Install Alfresco' do
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

      # Must be done by root, otherwise alfresco cannot be installed as a service (enabled by default)
      execute 'Install alfresco' do
        command "#{node['installer']['local']} --mode unattended --alfresco_admin_password #{node['installer']['alfresco_admin_password']} --enable-components #{node['installer']['enable-components']} --disable-components #{node['installer']['disable-components']} --jdbc_username #{node['installer']['jdbc_username']} --jdbc_password #{node['installer']['jdbc_password']} --prefix #{node['installer']['directory']}"
        not_if { File.exists?(node['paths']['uninstallFile']) }
      end

      %w(alf_data alfresco.sh amps amps_share apps bin common libreoffice licenses scripts solr4 tomcat).each do |folderName|
        directory "#{node['installer']['directory']}/#{folderName}" do
          owner unix_user
          group unix_group
          recursive true
        end
      end

      # postgresql.log must be writeable by non-root user
      directory "#{node['installer']['directory']}/postgresql" do
        owner unix_user
        group unix_group
        recursive false
      end

      execute 'hacking-alfresco-startup-script-ty-installer' do
        command "sed -i '3,7d' #{node['installer']['directory']}/alfresco.sh"
        not_if "cat #{node['installer']['directory']}/alfresco.sh | grep 'This script requires root privileges'"
      end

      replace_or_add '/etc/init.d/alfresco' do
        pattern "alfresco.sh\ start"
        line "su - #{unix_user} -c \"/alfresco/4.2.0/alfresco.sh start \\\"$2\\\"\""
      end

      replace_or_add '/etc/init.d/alfresco' do
        pattern "alfresco.sh\ stop"
        line "su - #{unix_user} -c \"/alfresco/4.2.0/alfresco.sh stop \\\"$2\\\"\""
      end
end

    common_template node['paths']['alfrescoGlobal'] do
      source 'globalProps/alfresco-global.properties.erb'
      win_user win_user
      win_group win_group
      unix_user unix_user
      unix_group unix_group
    end

    common_template node['paths']['wqsCustomProperties'] do
      source 'customProps/wqsapi-custom.properties.erb'
      win_user win_user
      win_group win_group
      unix_user unix_user
      unix_group unix_group
    end

    if node['installer.database-version'] != 'none'
      common_remote_file node['paths']['dbDriverLocation'] do
        source node['db.driver.url']
        win_user win_user
        win_group win_group
        unix_user unix_user
        unix_group unix_group
      end
    end

    if node['paths']['licensePath'] and node['paths']['licensePath'].length > 0
      common_remote_file node['paths']['licensePath'] do
        source node['alfresco.cluster.prerequisites']
        win_user win_user
        win_group win_group
        unix_user unix_user
        unix_group unix_group
      end
    end

    common_template node['paths']['tomcatServerXml'] do
      source 'tomcat/server.xml.erb'
      win_user win_user
      win_group win_group
      unix_user unix_user
      unix_group unix_group
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

    solr_ssl_disabler 'disabling solr ssl' do
      win_user win_user
      win_group win_group
      unix_user unix_user
      unix_group unix_group
    end

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
