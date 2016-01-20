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
# /
include_recipe 'alfresco-installer::_db_attributes'
include_recipe 'alfresco-installer::_installer_attributes'

win_user = node['installer']['win_user']
win_group = node['installer']['win_group']
unix_user = node['installer']['unix_user']
unix_group = node['installer']['unix_group']

if node['platform_family'] == 'windows' && win_user != 'Administrator'
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

alfRemoteFile 'download alfresco build' do
  source_url node['installer']['downloadpath']
  path node['installer']['local']
  win_user 'Administrator'
  win_group 'Administrators'
  unix_user 'root'
  unix_group 'root'
end

alfTemplate node['installer']['optionfile'] do
  source_url 'install_opts.erb'
  win_user win_user
  win_group win_group
  unix_user unix_user
  unix_group unix_group
end

case node['platform_family']
when 'windows'

  windows_task 'Install Alfresco' do
    user 'Administrator'
    password 'alfresco'
    command "#{node['installer']['local']} --optionfile #{node['installer']['optionfile']}"
    run_level :highest
    frequency :monthly
    action [:create, :run]
    not_if { File.exist?(node['paths']['uninstallFile']) }
  end

  batch 'Waiting for installation to finish ...' do
    code <<-EOH
      dir /S /P \"#{node['paths']['uninstallFile']}\"
      EOH
    action :run
    retries 30
    retry_delay 10
    notifies :delete, 'windows_task[Install Alfresco]', :delayed
    not_if { File.exist?(node['paths']['uninstallFile']) }
  end

when 'solaris', 'solaris2'

  Chef::Log.error("please use 'chef-alfresco-installer::tomcat' recipe for this platform")

else

  bash 'Set SHMMAX for ubuntu 10.04' do
    user 'root'
    cwd '/opt'
    code <<-EOH
  sudo sysctl -w kernel.shmmax=1024000000
    EOH
    only_if { node['platform'] == 'ubuntu' }
    only_if { node['platform_version'] == '10.04' }
  end

  replace_or_add 'make SHMMAX permanent' do
    path '/etc/sysctl.conf'
    pattern 'kernel.shmmax=.*'
    line 'kernel.shmmax=1024000000'
    only_if { node['platform'] == 'ubuntu' }
    only_if { node['platform_version'] == '10.04' }
  end

  execute 'Install alfresco' do
    command "#{node['installer']['local']} --optionfile #{node['installer']['optionfile']}"
    not_if { File.exist?(node['paths']['uninstallFile']) }
  end

  if unix_user != 'root'
    if node['alfresco.version'].start_with?('5')
      chown_folders = ['alf_data', 'alfresco.sh', 'amps', 'amps_share', 'bin', 'common', 'libreoffice', 'licenses', 'scripts', 'solr4', 'tomcat']
    else
      chown_folders = ['alf_data', 'alfresco.sh', 'amps', 'amps_share', 'bin', 'common', 'libreoffice', 'licenses', 'scripts', 'tomcat']
    end

    chown_folders.each do |folderName|
      execute "chown-#{folderName}-to-#{unix_user}" do
        command "chown -R #{unix_user}:#{unix_group} #{node['installer']['directory']}/#{folderName}"
      end
    end

    # postgresql.log must be writeable by non-root user
    execute "chown-postgresql-to-#{unix_user}" do
      command "chown -R #{unix_user}:#{unix_group} #{node['installer']['directory']}/postgresql"
      not_if { node['installer.database-type'] != 'postgres' }
    end

    execute 'hacking-alfresco-startup-script-ty-installer' do
      command "sed -i '3,7d' #{node['installer']['directory']}/alfresco.sh"
      only_if "cat #{node['installer']['directory']}/alfresco.sh | grep 'This script requires root privileges'"
    end
  end

  # This is how it should be done, though it doesn't work due the error below
  # Using templates/init/alfresco.erb instead
  #
  # TypeError: no implicit conversion of nil into String
  #
  # replace_or_add '/etc/init.d/alfresco' do
  #   pattern "alfresco.sh\ start"
  #   line "su - #{unix_user} -c \"/alfresco/4.2.0/alfresco.sh start \\\"$2\\\"\""
  # end
  #
  # replace_or_add '/etc/init.d/alfresco' do
  #   pattern "alfresco.sh\ stop"
  #   line "su - #{unix_user} -c \"/alfresco/4.2.0/alfresco.sh stop \\\"$2\\\"\""
  # end
  template '/etc/init.d/alfresco' do
    source 'init/alfresco.erb'
  end
end

templates = { node['paths']['alfrescoGlobal'] => 'globalProps/alfresco-global.properties.erb',
              node['paths']['wqsCustomProperties'] => 'customProps/wqsapi-custom.properties.erb',
              node['paths']['tomcatServerXml'] => 'tomcat/server.xml.erb' }

templates.each do |key, value|
  alfTemplate key do
    source_url value
    win_user win_user
    win_group win_group
    unix_user unix_user
    unix_group unix_group
  end
end

alfRemoteFile node['paths']['dbDriverLocation'] do
  source_url node['db.driver.url']
  win_user win_user
  win_group win_group
  unix_user unix_user
  unix_group unix_group
  only_if { node['installer.database-version'] != 'none' }
end

alfRemoteFile node['paths']['licensePath'] do
  source_url node['alfresco.cluster.prerequisites']
  win_user win_user
  win_group win_group
  unix_user unix_user
  unix_group unix_group
  only_if { node['paths']['licensePath'] && node['paths']['licensePath'].length > 0 }
end

solrcore_props = {
  'data.dir.root=' => node['paths']['solrPath'],
  'alfresco.version=' => node['alfresco.version'],
  'alfresco.host=' => node['solr.target.alfresco.host'],
  'alfresco.port=' => node['solr.target.alfresco.port'],
  'alfresco.port.ssl=' => node['solr.target.alfresco.port.ssl'],
  'alfresco.baseUrl=' => node['solr.target.alfresco.baseUrl']
}

solrcore_props.each do |key, value|
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
  pattern 'alfresco.secureComms=.*'
  line 'data.dir.root=none'
  only_if { node['disable_solr_ssl'] }
end

replace_or_add node['paths']['solrcoreWorkspace'] do
  pattern 'alfresco.secureComms=.*'
  line 'data.dir.root=none'
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
#   alfRemoteFile 'download certificates' do
#     source_url "#{node['certificates']['downloadpath']}/#{file}"
#     path "#{node['certificates']['directory']}/#{file}"
#   end
# end
#
# alfTemplate "#{node['installer']['directory']}/applicert.sh" do
#   source_url 'solr/applicert.sh.erb'
# end
#
# execute 'Apply Certificates' do
#   command "sh #{node['installer']['directory']}/applicert.sh"
#   action :run
# end

case node['platform_family']
when 'windows'

  windows_service 'alfrescoTomcat' do
    action [:enable, :stop]
    supports status: true, restart: true, stop: true, start: true
    timeout 400
  end

  windows_service 'alfrescoPostgreSQL' do
    action [:enable, :stop]
    supports status: false, restart: true, stop: true, start: true
    timeout 400
  end

  alfApplyAmps 'apply alfresco and share amps' do
    bin_folder "#{node['installer']['directory']}/bin"
    alfresco_webapps "#{node['installer']['directory']}/tomcat/webapps"
    share_webapps "#{node['installer']['directory']}/tomcat/webapps"
    amps_folder "#{node['installer']['directory']}/amps"
    amps_share_folder "#{node['installer']['directory']}/amps_share"
    tomcat_folder "#{node['installer']['directory']}/tomcat"
    windowsUser win_user
    windowsGroup win_group
    unixUser unix_user
    unixGroup unix_group
    only_if { node['apply_amps'] }
    only_if { node['amps'] }
  end

  service 'alfrescoPostgreSQL' do
    action :restart
    only_if { node['START_POSGRES'] }
  end

  service 'alfrescoTomcat' do
    action :restart
    only_if { node['START_SERVICES'] }
  end

else

  service 'alfresco' do
    action [:enable, :stop]
    supports status: false, restart: true
  end

  alfApplyAmps 'apply alfresco and share amps' do
    bin_folder "#{node['installer']['directory']}/bin"
    alfresco_webapps "#{node['installer']['directory']}/tomcat/webapps"
    share_webapps "#{node['installer']['directory']}/tomcat/webapps"
    amps_folder "#{node['installer']['directory']}/amps"
    amps_share_folder "#{node['installer']['directory']}/amps_share"
    tomcat_folder "#{node['installer']['directory']}/tomcat"
    windowsUser win_user
    windowsGroup win_group
    unixUser unix_user
    unixGroup unix_group
    only_if { node['apply_amps'] }
    only_if { node['amps'] }
  end

  service 'alfresco' do
    action :restart
    only_if { node['START_SERVICES'] }
  end

  execute 'Waiting for tomcat to start' do
    # command "tail -n2 #{node['installer']['directory']}/tomcat/logs/catalina.out | grep \"Server startup in .* ms\""
    command "curl --silent --show-error --connect-timeout 1 -I http://localhost:8080 | grep 'Coyote'"
    action :run
    retries 100
    retry_delay 5
    returns 0
    only_if { node['START_SERVICES'] }
  end

end
