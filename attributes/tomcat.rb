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
case node['platform_family']
  when 'windows'
    default['alfresco']['local'] = 'C:\\alfresco.zip'
  else
    default['alfresco']['local'] = '/opt/alfresco.zip'
end

#alfresco zip

default['alfresco']['downloadpath'] = 'ftp://172.29.103.222/chef-resources/alfresco-enterprise-5.0.2-SNAPSHOT.zip'
default['alfresco']['zipfolder'] = 'alfresco-enterprise-5.0.2-SNAPSHOT'

#external apps
default['url']['freetype']='ftp://172.29.103.222/external_apps/freetype-2.5.5.tar.gz'
default['url']['jpegsrc']='ftp://172.29.103.222/external_apps/jpegsrc.v9.tar.gz'
default['url']['ghostscript']='ftp://172.29.103.222/external_apps/ghostscript-9.15.tar.gz'
default['url']['openOffice']='ftp://172.29.103.222/external_apps/Apache_OpenOffice_incubating_3.4.0_Solaris_x86_install-arc_en-US.tar.gz'
default['url']['xpdf']='ftp://172.29.103.222/external_apps/xpdf-3.04.tar.gz'
default['url']['swftools']='ftp://172.29.103.222/external_apps/swftools-0.9.2.tar.gz'


#solr spacesstore
default['alfresco.version']='5.0.0'
case node['platform_family']
  when 'windows'
    default['data.dir.root'] = "#{node['installer']['directory']}/alf_data/solr4/index"
  else
    default['data.dir.root'] = "#{node['installer']['directory']}/alf_data/solr4/index"
end