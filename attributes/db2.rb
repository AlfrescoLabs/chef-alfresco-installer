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

default['db2']['install_location'] = '/opt/db2installation'
default['db2']['create_database'] = false
default['db2']['user'] = 'alfresco'
default['db2']['password'] = 'alfresco'
default['db2']['dbname'] = 'alfresco'
default['db2']['port'] = '50000'

case node['db2']['version']
when '10.1'
  default['db2']['downloadpath'] = 'ftp://172.29.101.56/databases/v10.1fp4_linuxx64_universal_fixpack.tar'
when '10.5'
  default['db2']['downloadpath'] = 'ftp://172.29.101.56/databases/v10.5_linuxx64_server_t.tar.gz'
end
