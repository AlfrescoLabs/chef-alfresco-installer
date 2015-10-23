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

define :remove_wars do
  file 'remove share war' do
    path "#{node['installer']['directory']}/tomcat/webapps/share.war"
    action :delete
    only_if { node['install_share_war'] == false }
  end
  file 'remove alfresco war' do
    path "#{node['installer']['directory']}/tomcat/webapps/alfresco.war"
    action :delete
    only_if { node['install_alfresco_war'] == false }
  end
  file 'remove solr4 war' do
    path "#{node['installer']['directory']}/tomcat/webapps/solr4.war"
    action :delete
    only_if { node['install_solr4_war'] == false }
  end
end
