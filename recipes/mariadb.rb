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

  directory "C:\\mariadb" do
    rights :read, 'Administrator'
    rights :write, 'Administrator'
    rights :full_control, 'Administrator'
    rights :full_control, 'Administrator', :applies_to_children => true
    group 'Administrators'
  end

  remote_file node['mariadb']['localpath'] do
    rights :read, 'Administrator'
    rights :write, 'Administrator'
    rights :full_control, 'Administrator'
  	source node['mariadb']['downloadpath']
  	:create_if_missing
  end

  windows_package 'MariaDB 10.0 (x64)' do
    source node['mariadb']['localpath']
    action :install
    installer_type :msi
    options " INSTALLDIR=C:\\mariadb SERVICENAME=mariadb /qn"
  end

  service 'mariadb' do
  	supports :status => true, :restart => true, :reload => true
  	action [ :start, :enable ]
  end
  
  batch 'Create new user' do
	code <<-EOH
	C:\\mariadb\\bin\\mysql.exe -uroot -e "CREATE USER #{node['mariadb']['user']}@'%' IDENTIFIED BY '#{node['mariadb']['password']}';"
	C:\\mariadb\\bin\\mysql.exe -uroot -e "GRANT ALL PRIVILEGES ON *.* TO #{node['mariadb']['user']}@'%' WITH GRANT OPTION;"
	EOH
	only_if { node['mariadb']['createuser'] }
end

batch 'Create new db' do
	code <<-EOH
	C:\\mariadb\\bin\\mysql.exe -uroot -e "create database #{node['mariadb']['dbname']};"
	EOH
	only_if { node['mariadb']['createdb'] }
end

batch 'Drop db' do
	code <<-EOH
	C:\\mariadb\\bin\\mysql.exe -uroot -e "drop database #{node['mariadb']['dbname']};"
	EOH
	only_if { node['mariadb']['dropdb'] }
end