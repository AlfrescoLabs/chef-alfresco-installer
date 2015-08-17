# ~FC015
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
#

win_user = node['installer']['win_user']
win_group = node['installer']['win_group']
unix_user = node['installer']['unix_user']
unix_group = node['installer']['unix_group']

define :solr_ssl_disabler do

  if node['disable_solr_ssl']

    directory node['installer']['directory'] do
      case node['platform_family']
      when 'windows'
        rights :read, win_user
        rights :write, win_user
        rights :full_control, win_user
        rights :full_control, win_user, :applies_to_children => true
        group win_group
      else
          owner unix_user
          group unix_group
          mode 00775
      end
    end

    if node['install_alfresco_war']

      bash 'unzip alfresco war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    mkdir /opt/tmp-alfrescowar
    cp #{node['installer']['directory']}/tomcat/webapps/alfresco.war /opt/tmp-alfrescowar/
    cd /opt/tmp-alfrescowar
    jar -xvf alfresco.war
    rm -rf alfresco.war
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
      end

      template 'set web.xml for alfresco.war' do
        source 'globalProps/web.xml-alfresco.erb'
        path '/opt/tmp-alfrescowar/WEB-INF/web.xml'
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
        only_if { ::File.exist?('/opt/tmp-alfrescowar/WEB-INF/web.xml') }
      end

      template 'set web.xml for alfresco' do
        source 'globalProps/web.xml-alfresco.erb'
        path "#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml"
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        only_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
      end

      bash 'archive and move alfresco war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    jar -cvf alfresco.war -C tmp-alfrescowar/ .
    cp -rf alfresco.war #{node['installer']['directory']}/tomcat/webapps/
    rm -rf alfresco.war
    rm -rf tmp-alfrescowar
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
      end

    end

    if node['install_solr4_war']

      bash 'unzip solr4 war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    mkdir /opt/tmp-solr4war
    cp #{node['installer']['directory']}/tomcat/webapps/solr4.war /opt/tmp-solr4war/
    cd /opt/tmp-solr4war
    jar -xvf solr4.war
    rm -rf solr4.war
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
      end

      template 'set web.xml for solr4.war' do
        source 'solr/web.xml-solr4.erb'
        path '/opt/tmp-solr4war/WEB-INF/web.xml'
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
        only_if { ::File.exist?('/opt/tmp-solr4war/WEB-INF/web.xml') }
      end

      template 'set web.xml for solr4' do
        source 'solr/web.xml-solr4.erb'
        path "#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml"
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        only_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
      end

      bash 'archive and move alfresco war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    jar -cvf solr4.war -C tmp-solr4war/ .
    cp -rf solr4.war #{node['installer']['directory']}/tomcat/webapps/
    rm -rf solr4.war
    rm -rf tmp-solr4war
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
      end

    end

  end

end
