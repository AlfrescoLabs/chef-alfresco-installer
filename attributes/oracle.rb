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

default['oracle']['installoracle'] = true
default['oracle']['base'] = '/opt/oracle/app/oracle'
default['oracle']['home'] = '/export/home/oracle/app/oracle/product/12.1.0.2/db_1'
default['oracle']['inventory'] = '/opt/oracle/app/oraInventory'
default['oracle']['downloaddir'] = '/opt/database'
default['oracle']['installdir'] = '/opt/oracle'
default['oracle']['user'] = 'alfresco'
default['oracle']['password'] = 'admin'
default['oracle']['SID'] = 'alfresco'
default['oracle']['dbname'] = 'alfresco'

default['oracle']['dropschema'] = false
default['oracle']['createschema'] = true

# User for additional schemas used for create and drop
default['oracle']['schema']['user'] = 'alfresco'
default['oracle']['schema']['password'] = 'alfresco'

default['url']['oracle_on_rhel1'] = 'ftp://172.29.101.56/databases/linuxamd64_12102_database_1of2.zip'
default['url']['oracle_on_rhel2'] = 'ftp://172.29.101.56/databases/linuxamd64_12102_database_2of2.zip'


