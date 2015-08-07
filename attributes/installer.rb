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

############ installer attributes ############

default['installer']['alfresco_admin_password']= 'admin'
default['installer']['enable-components'] = 'alfrescowcmqs'
default['installer']['disable-components'] = 'javaalfresco,postgres'
default['installer']['jdbc_username'] = 'alfresco'
default['installer']['jdbc_password'] = 'alfresco'
default['certificates']['downloadpath'] = 'ftp://172.29.103.222/chef-resources/certificates'

#use these arrays to apply amps example: default['amps']['alfresco']=['ftp://location/chef-resources/alfresco-rm-server-2.3-SNAPSHOT-amp.amp','ftp://location/chef-resources/alfresco-cmm-server-1.0-SNAPSHOT-amp.amp']
default['amps']['alfresco']=[]
default['amps']['share']=[]

case node['platform_family']
when 'windows'
  default['installer']['local'] = 'C:/alfresco.exe'
  default['installer']['downloadpath'] = 'ftp://172.29.103.222/chef-resources/alfresco-enterprise-5.0-installer-win-x64.exe'
  default['installer']['checksum'] = 'b635de4849eb9c3c508fcf7492ed1a286c6d231d88318abdfb97242581270d45'
  default['installer']['directory'] = 'C:/alf-installation'
  default['installer']['windirectory'] = 'C:\\\\alf-installation'
  default['certificates']['directory'] = 'C:/certificates'
else
  default['installer']['local'] = '/opt/alfresco.bin'
  default['installer']['downloadpath'] = 'ftp://172.29.101.56/50N/5.0.2/b302/alfresco-enterprise-5.0.2-SNAPSHOT-installer-linux-x64.bin'
  default['installer']['checksum'] = '90c61a7d7e73c03d5bfeb78de995d1c4b11959208e927e258b4b9e74b8ecfffa'
  default['installer']['directory'] = '/opt/alf-installation'
  default['certificates']['directory'] = '/opt/certificates'
end

# Derived attributes based on conditional assignment. If no value is assigned in the wrapping recipe then the installer recipe will set them.
# Do not uncomment these attributes. They are shown here just for info.
# default['paths']['uninstallFile'] = "#{node['installer']['directory']}\\uninstall.exe"
# default['paths']['alfrescoGlobal'] = "#{node['installer']['directory']}\\tomcat\\shared\\classes\\alfresco-global.properties"
# default['paths']['wqsCustomProperties'] = "#{node['installer']['directory']}\\tomcat\\shared\\classes\\wqsapi-custom.properties" do
# default['paths']['tomcatServerXml'] = "#{node['installer']['directory']}\\tomcat\\conf\\server.xml" do
# default['paths']['licensePath'] = "#{node['installer']['directory']}/qa50.lic"
# default['paths']['dbDriverLocation'] = "#{node['installer']['directory']}\\tomcat\\lib\\#{node['db.driver.filename']}"
# default['installer']['dir.keystore'] = "#{node['installer']['directory']}/alf_data"

#ssl attributes
# default["alfresco"]["keystore_file"] = "#{node['installer']['directory']}/alf_data/ssl.keystore"
default["alfresco"]["keystore_password"] = "kT9X6oe68t"
default["alfresco"]["keystore_type"] = "JCEKS"
# default["alfresco"]["truststore_file"] = "#{node['installer']['directory']}/alf_data/ssl.truststore"
default["alfresco"]["truststore_password"] = "kT9X6oe68t"
default["alfresco"]["truststore_type"] = "JCEKS"

############ conditional chef attributes ############
####### Services #######
default['START_SERVICES']=true
default['START_POSGRES']=true
default['install_alfresco_war']=true
default['install_share_war']=true
default['install_solr4_war']=true
default['disable_solr_ssl']=false

############ alfresco configuration properties ############

default['alfresco.version']='5.0.2'
default['installer']['nodename']='alf1'

### additional settings for wqs
default['wcmqs']['api']['repositoryPollMilliseconds'] = 500
default['wcmqs']['api']['sectionCacheSeconds'] = 2
default['wcmqs']['api']['websiteCacheSeconds'] = 2

####### If you are setting up solr only you will need to setup the alfresco target ######
default['solr.target.alfresco.host']='localhost'
default['solr.target.alfresco.port']='8080'
default['solr.target.alfresco.port.ssl']='8443'
default['solr.target.alfresco.baseUrl']='/alfresco'

##########################################
####### Alfresco Global Properties #######
##########################################

#alfresco and share ports
default['alfresco.port']='8080'
default['share.port']='8080'
default['alfresco.protocol']='http'
default['share.protocol']='http'

default['shutdown.port']='8005'
default['ajp.port']='8009'

#ftp
default['ftp.port']='21'

#solr
default['index.subsystem.name']='solr4'
default['dir.keystore']='${dir.root}/keystore'
default['solr.host']='localhost'
default['solr.port']='8080'
default['solr.port.ssl']='8443'


#external apps
default['ooo.enabled']='false'
default['ooo.port']='8100'

default['jodconverter.enabled']='true'
default['jodconverter.portNumbers']='8100'

default['force_specific_external_apps_path']=false
case node['platform_family']
  when 'solaris2'

    default['ooo.exe']='/opt/openOffice/openoffice.org3/program/soffice'

    default['img.root']='/opt/csw'
    default['img.dyn']='/opt/csw/lib'
    default['img.exe']='/opt/csw/bin/convert'

    default['swf.exe']='/usr/local/bin/pdf2swf'
    default['swf.languagedir']=''

    default['jodconverter.officeHome']=''

end


#################### !!! DATABASE TYPE !!! #################
## This is a constant and must be set as specified below ###
## This must be set to any of
## postgres / mysql / oracle / db2 / sqlserver / mariadb ###
default['installer.database-type']='postgres'

#################### !!! DATABASE VERSION !!! ##############
## This is a constant and must be set as specified below ###
## Currently supported versions are:
## postgres => 9.3.5
## oracle => 12c
## mysql => 5.6.17
## mariadb => 10.0.14
default['installer.database-version']='9.3.5'

case node['installer.database-type']

  when 'mariadb'

    case node['installer.database-version']

      when '10.0.14'

        default['db.driver']='org.gjt.mm.mysql.Driver'
        default['db.username']='alfresco'
        default['db.password']='alfresco'
        default['db.name']='alfresco'
        default['db.url']='jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
        default['db.pool.max']='275'
        default['db.driver.url']='ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar'
        default['db.driver.filename']='mysql-connector-java-5.1.32.jar'

    end

  when 'mysql'

    case node['installer.database-version']

      when '5.6.17'

        default['db.driver']='org.gjt.mm.mysql.Driver'
        default['db.username']='alfresco'
        default['db.password']='alfresco'
        default['db.name']='alfresco'
        default['db.url']='jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
        default['db.pool.max']='275'
        default['db.driver.url']='ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar'
        default['db.driver.filename']='mysql-connector-java-5.1.32.jar'

    end

  when 'postgres'

    default['db.driver']='org.postgresql.Driver'
    default['db.pool.max']='275'
    default['db.pool.validate.query']='SELECT 1'

    case node['installer.database-version']

      when '9.3.5'
        case node['platform_family']
          when 'solaris2'
            #db prop

            default['db.username']='alfresco'
            default['db.password']='admin'
            default['db.name']='alf_solaris'
            default['db.url']='jdbc:postgresql://172.29.100.200:5432/${db.name}'

          else

            default['db.username']='alfresco'
            default['db.password']='admin'
            default['db.name']='alfresco'
            default['db.url']='jdbc:postgresql://localhost:5432/${db.name}'

        end

        default['db.driver.url']='ftp://172.29.101.56/databases/postgresql-9.4-1201-jdbc41.jar'
        default['db.driver.filename']='postgresql-9.4-1201-jdbc41.jar'

    when 'none'

      default['db.username']='alfresco'
      default['db.password']='admin'
      default['db.name']='alfresco'
      default['db.url']='jdbc:postgresql://localhost:5432/${db.name}'

    end

end

default['sync.cloud.url']='TBD'
default['outbound.mail.host']='TBD'
default['outbound.mail.username']='TBD'
default['outbound.mail.password']='TBD'
