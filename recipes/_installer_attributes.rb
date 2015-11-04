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

# Setting derived attributes as needed.
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
  # uninstall file is required for installation idempotence
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
node.default['alfresco']['keystore'] = "#{node['installer']['directory']}/alf_data/keystore"
node.default['alfresco']['keystore_file'] = "#{node['alfresco']['keystore']}/ssl.keystore"
node.default['alfresco']['truststore_file'] = "#{node['alfresco']['keystore']}/ssl.truststore"
