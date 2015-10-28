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
bash 'Install package repos' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	rpm -Uvh #{node['mysql']['yum']['repository']}
	rm -rf /etc/yum.repos.d/dvd.repo
	EOH
end

bash 'setting repo for mysql55' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	yum-config-manager --disable mysql56-community
	yum-config-manager --enable mysql55-community
	EOH
  only_if { node['mysql']['yum']['version'].start_with?('5.5') }
end

package 'mysql-libs' do
	action :remove
end

package 'mysql-community-server' do
  action :install
  version node['mysql']['yum']['version']
end

service 'mysqld' do
	supports :status => true, :restart => true, :reload => true
	action [ :start, :enable ]
end

bash 'Create new user' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	mysql -e "CREATE USER #{node['mysql']['user']}@'%' IDENTIFIED BY '#{node['mysql']['password']}';"
	mysql -e "GRANT ALL PRIVILEGES ON *.* TO #{node['mysql']['user']}@'%' WITH GRANT OPTION;"
	EOH
	only_if { node['mysql']['createuser'] }
end

bash 'Create new db' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	mysql -e "create database #{node['mysql']['dbname']};"
	EOH
	only_if { node['mysql']['createdb'] }
	not_if 'mysql -e "show databases;" | grep alfresco'
end

bash 'Drop db' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	mysql -e "drop database #{node['mysql']['dbname']};"
	EOH
	only_if { node['mysql']['dropdb'] }
end
