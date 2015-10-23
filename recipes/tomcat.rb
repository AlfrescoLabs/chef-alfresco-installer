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

installDir = node['installer']['directory']

case node['platform_family']
when 'solaris', 'solaris2'

  template '/opt/opencsw.sh' do
    source 'machinePreps/opencsw.sh.erb'
    owner 'root'
    group 'root'
    mode 00755
  end

  file '/opt/opencsw.sh' do
    owner 'root'
    group 'root'
    mode 00755
    action :create
  end

  bash 'Install opencsw' do
    user 'root'
    cwd '/opt'
    code <<-EOH
  expect opencsw.sh
    EOH
    not_if { File.exist?('/opt/csw/bin/pkgutil') }
  end

  package 'gcc-45' do
    action :install
  end

  remote_file '/opt/freetype-2.5.5.tar.gz' do
    source node['url']['freetype']
    owner 'root'
    group 'root'
    mode 00775
    action :create_if_missing
    sensitive true
  end

  bash 'Install freetype' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf freetype-2.5.5.tar.gz
    cd freetype-2.5.5 && ./configure && gmake && gmake install
      EOH
    not_if { File.exist?('/usr/local/bin/freetype-config') }
  end

  remote_file '/opt/jpegsrc.v9.tar.gz' do
    source node['url']['jpegsrc']
    owner 'root'
    group 'root'
    mode 00775
    action :create_if_missing
  end

  bash 'Install jpegsrc' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf jpegsrc.v9.tar.gz
    cd jpeg-9 && ./configure && gmake && gmake install
      EOH
    not_if { File.exist?('/usr/local/bin/jpeg2swf') }
  end

  remote_file '/opt/xpdf-3.04.tar.gz' do
    source node['url']['xpdf']
    owner 'root'
    group 'root'
    mode 00775
    action :create_if_missing
  end

  remote_file '/opt/swftools-0.9.2.tar.gz' do
    source node['url']['swftools']
    owner 'root'
    group 'root'
    mode 00775
    action :create_if_missing
  end

  bash 'Install swftools' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf swftools-0.9.2.tar.gz
    cp xpdf-3.04.tar.gz swftools-0.9.2/lib/pdf
    crle -u -l /usr/local/lib
    cd swftools-0.9.2 && ./configure && gmake && gmake install
      EOH
    not_if { File.exist?('/usr/local/bin/png2swf') }
  end

  remote_file '/opt/ghostscript.tar.gz' do
    source node['url']['ghostscript']
    owner 'root'
    group 'root'
    mode 00775
    action :create_if_missing
  end

  bash 'Install ghostscript' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf ghostscript.tar.gz
    cd ghostscript-9.15
    ./configure --without-gnu-make && make && make install
      EOH
    not_if { File.exist?('/usr/local/bin/gs') }
  end

  bash 'Install ImageMagick' do
    user 'root'
    cwd '/opt'
    code <<-EOH
  /opt/csw/bin/pkgutil -y -i imagemagick
    EOH
    not_if { File.exist?('/opt/csw/bin/convert') }
  end

  remote_file '/opt/openOffice.tar.gz' do
    source node['url']['openOffice']
    owner 'root'
    group 'root'
    mode '775'
    action :create_if_missing
  end

  bash 'Install openOffice' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf openOffice.tar.gz
    mv Apache_OpenOffice_incubating_3.4.0_Solaris_x86_install-arc_en-US openOffice
    chmod -R 700 openOffice
      EOH
    not_if { File.exist?('/opt/openOffice/openoffice.org3/program/soffice') }
  end

end

directory '/resources' do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
end

directory node['installer']['directory'] do
  owner 'root'
  group 'root'
  mode 00775
  action :create
end

directory "#{installDir}/tomcat" do
  owner 'root'
  group 'root'
  mode 00775
  action :create
end

remote_file '/opt/tomcat.tar.gz' do
  source node['tomcat']['download_url']
  owner 'root'
  group 'root'
  mode 00775
  action :create_if_missing
end

bash 'unzip tomcat' do
  user 'root'
  cwd '/opt'
  code <<-EOH
    tar xvf tomcat.tar.gz
    mv #{node['tomcat']['package_name']}/* #{installDir}/tomcat
  EOH
  not_if { ::File.directory?("#{installDir}/tomcat/bin") }
end

%W(#{installDir}/tomcat/shared
   #{installDir}/tomcat/shared/classes
   #{installDir}/tomcat/shared/lib
   #{installDir}/tomcat/conf/Catalina
   #{installDir}/tomcat/conf/Catalina/localhost).each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode 00775
    action :create
  end
end

template "#{installDir}/tomcat/conf/catalina.properties" do
  source 'tomcat/catalina.properties.erb'
  owner 'root'
  group 'root'
  mode 00755
  :top_level
end

template "#{installDir}/tomcat/conf/server.xml" do
  source 'tomcat/server.xml.erb'
  owner 'root'
  group 'root'
  mode 00755
  :top_level
end

template "#{node['installer']['directory']}/tomcat/shared/classes/wqsapi-custom.properties" do
  source 'customProps/wqsapi-custom.properties.erb'
  owner 'root'
  group 'root'
  mode '0755'
  :top_level
end

template "#{installDir}/tomcat/conf/context.xml" do
  source 'tomcat/context.xml.erb'
  owner 'root'
  group 'root'
  mode 00755
  :top_level
end

template "#{installDir}/tomcat/conf/Catalina/localhost/solr4.xml" do
  source 'solr/solr4.xml.erb'
  owner 'root'
  group 'root'
  mode 00755
  :top_level
end

template "#{installDir}/tomcat/conf/tomcat-users.xml" do
  source 'tomcat/tomcat-users.xml.erb'
  owner 'root'
  group 'root'
  mode 00755
  :top_level
end

remote_file node['alfresco']['local'] do
  source node['alfresco']['downloadpath']
  owner 'root'
  group 'root'
  mode 00775
  action :create_if_missing
  sensitive true
end

bash 'place alfresco in tomcat folder' do
  user 'root'
  cwd '/opt'
  code <<-EOH
    unzip alfresco.zip
    cp -rf #{node['alfresco']['zipfolder']}/* #{installDir}
    cp -rf  #{installDir}web-server/* #{installDir}/tomcat/
    rm -rf #{installDir}/web-server
  EOH
  not_if { File.exist?("#{installDir}/web-server/shared/classes/alfresco-global.properties.sample") }
end

template "#{installDir}/tomcat/shared/classes/alfresco-global.properties" do
  source 'globalProps/alfresco-global.properties.erb'
  owner 'root'
  group 'root'
  mode 00755
  :top_level
end

execute 'remove share war' do
  user 'root'
  command "rm -rf #{installDir}/tomcat/webapps/share.war"
  action :run
  only_if { !node['install_share_war'] }
end

execute 'remove alfresco war' do
  user 'root'
  command "rm -rf #{installDir}/tomcat/webapps/alfresco.war"
  action :run
  only_if { !node['install_alfresco_war'] }
end

execute 'remove solr4 war' do
  user 'root'
  command "rm -rf #{installDir}/tomcat/webapps/solr4.war"
  action :run
  only_if { !node['install_solr4_war'] }
end

case node['platform_family']
when 'solaris', 'solaris2'

  service 'application/tomcat' do
    supports restart: true, disable: true, enable: true
    action :nothing
    notifies :run, 'execute[wait for tomcat]', :immediately
  end

  execute 'wait for tomcat' do
    command 'sleep 100'
    action :nothing
  end

  template "#{installDir}tomcat.xml" do
    source 'machinePreps/solaris-tomcat-service.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
  end

  execute 'Import solaris tomcat service' do
    user 'root'
    command "svccfg import #{installDir}tomcat.xml"
    notifies :restart, 'service[application/tomcat]'
  end

end
