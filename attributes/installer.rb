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

default["don't use installer"] = false
default["localPath"] = false

default["installer"]["alfresco_admin_password"]= "admin"
default["installer"]["enable-components"] = "alfrescowcmqs"
default["installer"]["disable-components"] = "javaalfresco"
default["installer"]["jdbc_username"] = "alfresco"
default["installer"]["jdbc_password"] = "alfresco"

case node['platform_family']
when 'windows'
  default["installer"]["local"] = "C:\\alfresco.exe"
  default["installer"]["downloadpath"] = "ftp://172.29.103.222/chef-resources/alfresco-enterprise-5.0-installer-win-x64.exe"
  default["installer"]["checksum"] = 'b635de4849eb9c3c508fcf7492ed1a286c6d231d88318abdfb97242581270d45'
  default["alfresco-global"]["directory"] = "C:\\alf-installation\\tomcat\\shared\\classes\\alfresco-global.properties"
  default["installer"]["directory"] = "C:\\alf-installation"
else
  default["installer"]["local"] = "/resources/alfresco.bin"
  default["installer"]["downloadpath"] = "ftp://172.29.103.222/chef-resources/alfresco-enterprise-5.0-installer-linux-x64.bin"
  default["installer"]["checksum"] = '90c61a7d7e73c03d5bfeb78de995d1c4b11959208e927e258b4b9e74b8ecfffa'
  default["alfresco-global"]["directory"] = "/opt/target/alf-installation/tomcat/shared/classes/alfresco-global.properties"
  default["installer"]["directory"] = "/opt/target/alf-installation"
end

default["install"]["component"]["use java from installer"]=false
default["install"]["component"]["wqs"]=false
default["install"]["component"]["solr1"]=false
default["install"]["component"]["googleDocs"]=false

default["installer"]["nodename"]="alf1"