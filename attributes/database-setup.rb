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
case node['installer.database-type']

when 'mariadb'

	case node['installer.database-version']

	when '10.0.14'

	default['db.driver']='org.gjt.mm.mysql.Driver'
	default['db.username']='alfresco'
	default['db.password']='alfresco'
	default['db.name']='alfresco'
	default['db.url']='jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
	default['db.pool.max']='275'
	default['db.driver.url']='ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar'
	default['db.driver.filename']='mysql-connector-java-5.1.32.jar'

	end

when 'mysql'

	case node['installer.database-version']

	when '5.6.17'

	default['db.driver']='org.gjt.mm.mysql.Driver'
	default['db.username']='alfresco'
	default['db.password']='alfresco'
	default['db.name']='alfresco'
	default['db.url']='jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
	default['db.pool.max']='275'
	default['db.driver.url']='ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar'
	default['db.driver.filename']='mysql-connector-java-5.1.32.jar'

	end

when 'postgres'

	case node['installer.database-version']

	when '9.3.5'
		case node['platform_family']
		when 'solaris2'
		#db prop

		default['db.username']='alfresco'
		default['db.password']='admin'
		default['db.name']='alf_solaris'
		default['db.url']='jdbc:postgresql://172.29.100.200:5432/${db.name}'

		else

		default['db.username']='alfresco'
		default['db.password']='admin'
		default['db.name']='alfresco'
		default['db.url']='jdbc:postgresql://localhost:5432/${db.name}'

		end

		default['db.driver']='org.postgresql.Driver'
		default['db.pool.max']='275'
		default['db.pool.validate.query']='SELECT 1'
		default['db.driver.url']='ftp://172.29.101.56/databases/postgresql-9.4-1201-jdbc41.jar'
		default['db.driver.filename']='postgresql-9.4-1201-jdbc41.jar'

	end

end