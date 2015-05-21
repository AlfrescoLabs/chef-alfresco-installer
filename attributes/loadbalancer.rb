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
default['lb']['ips_and_nodenames'] = [{:ip=> '172.29.101.97', :nodename=> 'alf1'},{:ip=> '172.29.101.99', :nodename=> 'alf2'}]

default['loadbalancer']['url'] = 'ftp://172.29.101.56/tomcat/httpd2412win64.zip'
default['loadbalancer']['rootFolder'] = 'c:/httpd/httpd2412win64'
default['loadbalancer']['unzipFolder'] = 'c:/httpd'