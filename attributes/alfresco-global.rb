#alfresco global properties

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


#alfresco and share ports
default['alfresco.port']='8080'
default['share.port']='8080'
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
case node['platform_family']
  when 'solaris2'

    default['ooo.exe']='/opt/openOffice/openoffice.org3/program/soffice'
    default['ooo.enabled']='true'
    default['ooo.port']='8100'
    default['img.dyn']='/opt/csw/lib'
    default['img.exe']='/opt/csw/bin/convert'
    default['swf.exe']='/usr/local/bin/pdf2swf'
    default['swf.languagedir']=''
    default['jodconverter.enabled']='false'
    default['jodconverter.officeHome']=''
    default['jodconverter.portNumbers']=''

  when 'windows'
    default['ooo.exe']='C:/alf-installation/libreoffice/App/libreoffice/program/soffice.exe'
    default['ooo.enabled']='false'
    default['ooo.port']='8100'
    default['img.root']='C:\\\\alf-installation\\\\imagemagick'
    default['img.coders']='C:\\\\alf-installation\\\\imagemagick\\\\modules\\\\coders'
    default['img.gslib']='C:\\\\alf-installation\\\\common\\\\lib'
    default['img.exe']='C:\\\\alf-installation\\\\imagemagick\\\\convert.exe'
    default['swf.exe']='C:/alf-installation/swftools/pdf2swf.exe'
    default['swf.languagedir']='C:/alf-installation/swftools/japanese'
    default['jodconverter.enabled']='true'
    default['jodconverter.officeHome']='C:/alf-installation/libreoffice/App/libreoffice'
    default['jodconverter.portNumbers']='8100'
  else

    default['ooo.exe']='/opt/target/alf-installation/libreoffice/program/soffice'
    default['ooo.enabled']='false'
    default['ooo.port']='8100'
    default['img.dyn']='/opt/target/alf-installation/common/lib'
    default['img.exe']='/opt/target/alf-installation/common/bin/convert'
    default['swf.exe']='/opt/target/alf-installation/common/bin/pdf2swf'
    default['swf.languagedir']='/opt/target/alf-installation/common/japanese'
    default['jodconverter.enabled']='true'
    default['jodconverter.officeHome']='/opt/target/alf-installation/libreoffice'
    default['jodconverter.portNumbers']='8100'

end
