#tomcat
default['tomcat']['download_url']='http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.53/bin/apache-tomcat-7.0.53.tar.gz'
default['tomcat']['package_name']='apache-tomcat-7.0.53'
default['tomcat']['target_folder']="/opt/target"
default['tomcat']['installation_folder']="/opt/target/alf-installation"
default['tomcat']['tomcat_folder']="/opt/target/alf-installation/tomcat"

#alfresco zip
default["alfresco"]["local"] = "/opt/alfresco.zip"
default["alfresco"]["downloadpath"] = "ftp://172.29.103.222/chef-resources/alfresco-enterprise-5.0.2-SNAPSHOT.zip"
default["alfresco"]["zipfolder"] = "alfresco-enterprise-5.0.2-SNAPSHOT"

#external apps
default["url"]["freetype"]="http://download.savannah.gnu.org/releases/freetype/freetype-2.5.5.tar.gz"
default["url"]["jpegsrc"]="http://www.ijg.org/files/jpegsrc.v9.tar.gz"
default["url"]["ghostscript"]="http://downloads.ghostscript.com/public/ghostscript-9.15.tar.gz"
default["url"]["openOffice"]="http://adfinis-sygroup.ch/file-exchange-public/tag-AOO340-x86/Apache_OpenOffice_incubating_3.4.0_Solaris_x86_install-arc_en-US.tar.gz"
default["url"]["xpdf"]="ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.04.tar.gz"
default["url"]["swftools"]="http://www.swftools.org/swftools-0.9.2.tar.gz"


#alfresco global properties

#alfresco and share ports
default['alfresco.port']="8080"
default['share.port']="8080"
default['shutdown.port']="8005"
default['ajp.port']="8009"

#db prop
default['db.driver']="org.postgresql.Driver"
default['db.username']="alfresco"
default['db.password']="admin"
default['db.name']="alf_new"
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

#ftp
default['ftp.port']="21"

#solr
default['index.subsystem.name']="solr4"
default['dir.keystore']="${dir.root}/keystore"
default['solr.port.ssl']="8443"