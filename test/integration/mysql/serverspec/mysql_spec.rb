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
require 'spec_helper'

describe 'Validate mysql installation' do

context 'When we check the status of mysql 3306 port it' do
  it { expect(port(3306)).to be_listening }
end

context 'When we verify if mysql is installed yum list install ' do
  it { expect(command('yum list installed | grep mysql-community-server').stdout).to include("mysql-community-server.x86_64        5.6.17-4.el6") }
end

context 'When we verify if the service is enabled' do
  it { expect(service('mysqld')).to be_enabled }
end

context 'When we check if we can connect to mysql with default alfresco/alfresco user the mysql stdout' do
  it { expect(command("mysql -h172.29.101.52 -ualfresco -palfresco alfresco -e \"show processlist;\"")
  	.stdout).to match /alfresco.*172.29.101.52.*alfresco/ }
end

context 'When we check if the alfresco database exists the mysql stdout' do
  it { expect(command("mysql -h172.29.101.52 -ualfresco -palfresco alfresco -e \"show databases;\"")
  	.stdout).to match /| alfresco |/ }
end

context 'When we check if we can create a table the mysql stdout' do
  it { expect(command("mysql -h172.29.101.52 -ualfresco -palfresco alfresco -e \"create table test(col1 varchar(10));\"")
  	.stdout).not_to include("ERROR") }
end

context 'When we check if we can insert row "magic" in the table the mysql stdout' do
  it { expect(command("mysql -h172.29.101.52 -ualfresco -palfresco alfresco -e \"insert into test values ('magic');\"")
  	.stdout).not_to include("ERROR") }
end

context 'When we check if we can select from table the mysql stdout' do
  it { expect(command("mysql -h172.29.101.52 -ualfresco -palfresco alfresco << EOF 
  	select * from test;
  	exit
  	EOF").stdout).to match /| magic |/ }
end

context 'When we check if we can drop a table the mysql stdout' do
  it { expect(command("mysql -h172.29.101.52 -ualfresco -palfresco alfresco << EOF 
  	drop table test;
  	exit
  	EOF").stdout).not_to include("ERROR") }
end

end