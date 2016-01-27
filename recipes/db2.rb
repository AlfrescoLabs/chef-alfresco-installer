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

remote_file '/opt/db2.tar' do
  source node['db2']['downloadpath']
  owner 'root'
  group 'root'
  mode 00775
end

execute 'unpack db2 installer' do
  command 'tar xvf db2.tar'
  cwd '/opt'
end

bash 'create users and groups' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
groupadd db2grp1
groupadd dasadm1
groupadd db2fgrp1
useradd -g db2grp1 -G dasadm1 -m db2inst1 -p $(openssl passwd -crypt #{node['db2']['password']})
useradd -g dasadm1 -G db2grp1 -m dasusr1 -p  $(openssl passwd -crypt #{node['db2']['password']})
useradd -g db2fgrp1 -m db2fenc1 -p  $(openssl passwd -crypt #{node['db2']['password']})
useradd -g dasadm1 -G db2grp1 -m  #{node['db2']['user']} -p  $(openssl passwd -crypt #{node['db2']['password']})
  EOH
  not_if 'cat /etc/passwd | grep db2inst1'
end

case node['db2']['version']
when '10.1'
  server_edition = 'ENTERPRISE_SERVER_EDITION'
  unzip_folder = '/opt/universal'
when '10.5'
  server_edition = 'DB2_SERVER_EDITION'
  unzip_folder = '/opt/server_t'
end

file '/opt/responsefile.rsp' do
  content "PROD                      = #{server_edition}
FILE                      = #{node['db2']['install_location']}
LIC_AGREEMENT             = ACCEPT
INSTALL_TYPE              = TYPICAL"
  mode '0755'
  owner 'db2inst1'
end

execute 'install server' do
  command './db2setup -r /opt/responsefile.rsp'
  case node['db2']['version']
  cwd unzip_folder
  not_if { File.exist?("#{node['db2']['install_location']}/instance") }
end

bash 'additional config' do
  cwd "#{node['db2']['install_location']}/instance"
  code <<-EOH
./dascrt -u dasusr1
./db2icrt -u db2fenc1 db2inst1
  EOH
end

execute 'enable tcpi and server start' do
  command "su - db2inst1 -c 'db2set DB2COMM=tcpip; db2 update dbm cfg using SVCENAME #{node['db2']['port']}; db2start'"
  cwd "/opt"
end

file '/opt/create_database.sql' do
  content "ATTACH TO db2inst1;
CREATE DATABASE #{node['db2']['dbname']} USING CODESET UTF-8 TERRITORY US PAGESIZE 32 K;
CONNECT TO #{node['db2']['dbname']} USER #{node['db2']['user']} USING #{node['db2']['password']};"
  mode '0755'
  owner 'db2inst1'
  only_if { node['db2']['create_database'] }
end

execute 'create database' do
  command "su - db2inst1 -c 'db2 -tvmf /opt/create_database.sql'"
  only_if { node['db2']['create_database'] }
end

bash 'cleanup installation artifacts' do
  cwd "/opt"
  code <<-EOH
rm -rf db2.tar
rm -rf #{unzip_folder}
rm -rf /opt/responsefile.rsp
rm -rf /opt/create_database.sql
  EOH
  only_if { File.exist?(unzip_folder) }
end
