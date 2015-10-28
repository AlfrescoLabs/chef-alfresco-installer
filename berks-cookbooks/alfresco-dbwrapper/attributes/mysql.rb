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
default['mysql']['yum']['version']='5.6.17-4.el6'
default['mysql']['yum']['repository']='http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'

default['mysql']['createuser']=true
default['mysql']['createdb']=true
default['mysql']['dropdb']=false

default['mysql']['user']='alfresco'
default['mysql']['password']='alfresco'
default['mysql']['dbname']='alfresco'