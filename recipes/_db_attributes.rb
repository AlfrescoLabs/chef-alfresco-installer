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

#################### !!! DATABASE TYPE !!! #################
## This is a constant and must be set as specified below ###
## This must be set to any of
## postgres / mysql / oracle / db2 / sqlserver / mariadb ###
## default['installer.database-type'] = 'postgres'

#################### !!! DATABASE VERSION !!! ##############
## This is a constant and must be set as specified below ###
## Currently supported versions are:
## postgres => 9.3.5
## oracle => 12c
## mysql => 5.6.17
## mariadb => 10.0.14
## default['installer.database-version'] = '9.3.5'

case node['installer.database-type']

when 'oracle'

  case node['installer.database-version']

  when '12c'

    node.default['db.driver'] = 'oracle.jdbc.OracleDriver'
    node.default['db.username'] = 'alfresco'
    node.default['db.password'] = 'alfresco'
    node.default['db.name'] = 'alfresco'
    node.default['db.url'] = 'jdbc:oracle:thin:@localhost:5432:${db.name}'
    node.default['db.pool.max'] = '275'
    node.default['db.driver.url'] = 'ftp://172.29.101.56/databases/ojdbc7.jar'
    node.default['db.driver.filename'] = 'ojdbc7.jar'

  end

when 'mariadb'

  case node['installer.database-version']

  when '10.0.14'

    node.default['db.driver'] = 'org.gjt.mm.mysql.Driver'
    node.default['db.username'] = 'alfresco'
    node.default['db.password'] = 'alfresco'
    node.default['db.name'] = 'alfresco'
    node.default['db.url'] = 'jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
    node.default['db.pool.max'] = '275'
    node.default['db.driver.url'] = 'ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar'
    node.default['db.driver.filename'] = 'mysql-connector-java-5.1.32.jar'

  end

when 'mysql'

  case node['installer.database-version']

  when '5.6.17'

    node.default['db.driver'] = 'org.gjt.mm.mysql.Driver'
    node.default['db.username'] = 'alfresco'
    node.default['db.password'] = 'alfresco'
    node.default['db.name'] = 'alfresco'
    node.default['db.url'] = 'jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
    node.default['db.pool.max'] = '275'
    node.default['db.driver.url'] = 'ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar'
    node.default['db.driver.filename'] = 'mysql-connector-java-5.1.32.jar'

  end

when 'postgres'

  node.default['db.driver'] = 'org.postgresql.Driver'
  node.default['db.pool.max'] = '275'
  node.default['db.pool.validate.query'] = 'SELECT 1'

  case node['installer.database-version']

  when '9.3.5'
    case node['platform_family']
    when 'solaris2'

      node.default['db.username'] = 'alfresco'
      node.default['db.password'] = 'admin'
      node.default['db.name'] = 'alf_solaris'
      node.default['db.url'] = 'jdbc:postgresql://172.29.100.200:5432/${db.name}'

    else

      node.default['db.username'] = 'alfresco'
      node.default['db.password'] = 'admin'
      node.default['db.name'] = 'alfresco'
      node.default['db.url'] = 'jdbc:postgresql://localhost:5432/${db.name}'

    end

    node.default['db.driver.url'] = 'ftp://172.29.101.56/databases/postgresql-9.4-1201-jdbc41.jar'
    node.default['db.driver.filename'] = 'postgresql-9.4-1201-jdbc41.jar'

  when 'none'

    node.default['db.username'] = 'alfresco'
    node.default['db.password'] = 'admin'
    node.default['db.name'] = 'alfresco'
    node.default['db.url'] = 'jdbc:postgresql://localhost:5432/${db.name}'

  end

end
