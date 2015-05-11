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

#tomcat
default['tomcat']['download_url']='ftp://172.29.103.222/tomcat/apache-tomcat-7.0.53.tar.gz'
default['tomcat']['package_name']='apache-tomcat-7.0.53'
default['tomcat']['target_folder']="/opt/target"
default['tomcat']['installation_folder']="/opt/target/alf-installation"
default['tomcat']['tomcat_folder']="/opt/target/alf-installation/tomcat"

#alfresco zip
default["alfresco"]["local"] = "/opt/alfresco.zip"
default["alfresco"]["downloadpath"] = "ftp://172.29.103.222/chef-resources/alfresco-enterprise-5.0.2-SNAPSHOT.zip"
default["alfresco"]["zipfolder"] = "alfresco-enterprise-5.0.2-SNAPSHOT"

#external apps
default["url"]["freetype"]="ftp://172.29.103.222/external_apps/freetype-2.5.5.tar.gz"
default["url"]["jpegsrc"]="ftp://172.29.103.222/external_apps/jpegsrc.v9.tar.gz"
default["url"]["ghostscript"]="ftp://172.29.103.222/external_apps/ghostscript-9.15.tar.gz"
default["url"]["openOffice"]="ftp://172.29.103.222/external_apps/Apache_OpenOffice_incubating_3.4.0_Solaris_x86_install-arc_en-US.tar.gz"
default["url"]["xpdf"]="ftp://172.29.103.222/external_apps/xpdf-3.04.tar.gz"
default["url"]["swftools"]="ftp://172.29.103.222/external_apps/swftools-0.9.2.tar.gz"


#alfresco global properties

#alfresco and share ports
default['alfresco.port']="8080"
default['share.port']="8080"
default['shutdown.port']="8005"
default['ajp.port']="8009"

#ftp
default['ftp.port']="21"

#solr
default['index.subsystem.name']="solr4"
default['dir.keystore']="${dir.root}/keystore"
default['solr.port.ssl']="8443"

case node['platform_family']
when 'solaris2'
#db prop

default['db.driver']="org.postgresql.Driver"
default['db.username']="alfresco"
default['db.password']="admin"
default['db.name']="alf_solaris"
default['db.url']="jdbc:postgresql://172.29.100.200:5432/${db.name}"
default['db.pool.max']="275"
default['db.pool.validate.query']="SELECT 1"

#external apps
default['ooo.exe']="/opt/openOffice/openoffice.org3/program/soffice"
default['ooo.enabled']="true"
default['ooo.port']="8100"
default['img.dyn']="/opt/csw/lib"
default['img.exe']="/opt/csw/bin/convert"
default['swf.exe']="/usr/local/bin/pdf2swf"
default['swf.languagedir']=""
default['jodconverter.enabled']="false"
default['jodconverter.officeHome']=""
default['jodconverter.portNumbers']=""

else

default['db.driver']="org.postgresql.Driver"
default['db.username']="alfresco"
default['db.password']="admin"
default['db.name']="alfresco"
default['db.url']="jdbc:postgresql://localhost:5432/${db.name}"
default['db.pool.max']="275"
default['db.pool.validate.query']="SELECT 1"

#external apps
default['ooo.exe']="/opt/target/alf-installation/libreoffice/program/soffice"
default['ooo.enabled']="false"
default['ooo.port']="8100"
default['img.dyn']="/opt/target/alf-installation/common/lib"
default['img.exe']="/opt/target/alf-installation/common/bin/convert"
default['swf.exe']="/opt/target/alf-installation/common/bin/pdf2swf"
default['swf.languagedir']="/opt/target/alf-installation/common/japanese"
default['jodconverter.enabled']="true"
default['jodconverter.officeHome']="/opt/target/alf-installation/libreoffice"
default['jodconverter.portNumbers']="8100"

end
