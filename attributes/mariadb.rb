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
default["mariadb"]["downloadpath"] = "ftp://172.29.103.222/databases/mariadb-10.0.14-winx64.msi"
default["mariadb"]["localpath"] = "C:\\mariadb.msi"

default['mariadb']['install']=true
default['mariadb']['createuser']=true
default['mariadb']['createdb']=true
default['mariadb']['dropdb']=false

default['mariadb']['user']="alfresco"
default['mariadb']['password']="alfresco"
default['mariadb']['dbname']="alfresco"