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
  default["installer"]["downloadpath"] = "qa/QA_Applications/Alfresco%205.0%20311/alfresco-enterprise-5.0-installer-win-x64.exe"
  default["installer"]["checksum"] = 'b635de4849eb9c3c508fcf7492ed1a286c6d231d88318abdfb97242581270d45'
  default["alfresco-global"]["directory"] = "C:\\alf-installation\\tomcat\\shared\\classes\\alfresco-global.properties'"
  default["installer"]["directory"] = "C:\\alf-installation"
when 'solaris'
else
  default["installer"]["local"] = "/resources/alfresco.bin"
  default["installer"]["downloadpath"] = "qa/QA_Applications/Alfresco%205.0%20311/alfresco-enterprise-5.0-installer-linux-x64.bin"
  default["installer"]["checksum"] = '90c61a7d7e73c03d5bfeb78de995d1c4b11959208e927e258b4b9e74b8ecfffa'
  default["alfresco-global"]["directory"] = "/opt/target/alf-installation/tomcat/shared/classes/alfresco-global.properties'"
  default["installer"]["directory"] = "/opt/target/alf-installation"
end

default["install"]["component"]["use java from installer"]=false
default["install"]["component"]["wqs"]=false
default["install"]["component"]["solr1"]=false
default["install"]["component"]["googleDocs"]=false