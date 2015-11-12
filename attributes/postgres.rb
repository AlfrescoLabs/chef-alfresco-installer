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
default['url']['postgresql'] = 'ftp://172.29.103.222/databases/postgresql-9.3.5.tar.gz'
default['url']['package'] = 'postgresql-9.3.5'
default['postgres']['installpostgres'] = true
default['postgres']['dropdb'] = false
default['postgres']['createdb'] = true
default['postgres']['dbname'] = 'alfresco'
default['postgres']['user'] = 'alfresco'
default['postgres']['password'] = 'admin'
default['postgres']['client']['ip'] = '172.29.101.52'
