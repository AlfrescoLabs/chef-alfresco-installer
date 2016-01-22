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
useradd -g db2grp1 -G dasadm1 -m db2inst1 -p db2inst1
useradd -g dasadm1 -G db2grp1 -m dasusr1 -p dasusr1
useradd -g db2fgrp1 -m db2fenc1 -p db2fenc1
  EOH
  not_if { File.exist?("#{node['db2']['install_location']}/instance") }
end

template "/opt/responsefile.rsp" do
  source 'db2/responsefile.erb'
  owner 'root'
  group 'root'
  mode '0744'
  variables(install_path: node['db2']['install_location'])
end

execute 'install server' do
  command './db2setup -r /opt/responsefile.rsp'
  cwd '/opt/universal'
  not_if { File.exist?("#{node['db2']['install_location']}/instance") }
end

bash 'additional config and server start' do
  cwd "#{node['db2']['install_location']}/instance"
  code <<-EOH
./dascrt -u dasusr1
./db2icrt -u db2fenc1 db2inst1
su - db2inst1
db2set DB2COMM=tcpip
db2 update dbm cfg using SVCENAME 50000
db2start
  EOH
  not_if { File.exist?("#{node['db2']['install_location']}/instance") }
end

bash 'create database' do
  cwd "#{node['db2']['install_location']}/instance"
  code <<-EOH
db2
ATTACH TO db2inst1
CREATE DATABASE alfresco USING CODESET UTF-8 TERRITORY US PAGESIZE 32 K
CONNECT TO alfresco USER alfresco USING alfresco
CREATE BUFFERPOOL alfresco_buffer PAGESIZE 32 K
CREATE REGULAR TABLESPACE alfresco_data PAGESIZE 32 K MANAGED BY DATABASE USING (file '#{node['db2']['install_location']}/alfresco_TBS' 19200) EXTENTSIZE 16 OVERHEAD 10.5 PREFETCHSIZE 16 TRANSFERRATE 0.33 BUFFERPOOL alfresco_buffer DROPPED TABLE RECOVERY ON
  EOH
end
