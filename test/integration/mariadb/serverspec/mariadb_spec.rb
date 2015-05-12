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

context 'When we verify if the service is enabled' do
  it { expect(service('mariadb')).to be_enabled }
end

context 'When we check if we can connect to mysql with default alfresco/alfresco user the mysql stdout' do
  it { expect(command("C:\\mariadb\\bin\\mysql.exe --host=172.29.101.51 --user=alfresco --password=alfresco --database=alfresco -e \"show processlist;\"")
  	.stdout).to match /alfresco.*alfresco/ }
end

context 'When we check if the alfresco database exists the mysql stdout' do
  it { expect(command("C:\\mariadb\\bin\\mysql.exe --host=172.29.101.51 --user=alfresco --password=alfresco --database=alfresco -e \"show databases;\"")
  	.stdout).to include('alfresco') }
end

context 'When we check if we can create a table the mysql stdout' do
  it { expect(command("C:\\mariadb\\bin\\mysql.exe --host=172.29.101.51 --user=alfresco --password=alfresco --database=alfresco -e \"create table test(col1 varchar(10));\"")
  	.stderr).not_to include('ERROR') }
end

context 'When we check if we can insert row "magic" in the table the mysql stdout' do
  it { expect(command("C:\\mariadb\\bin\\mysql.exe --host=172.29.101.51 --user=alfresco --password=alfresco --database=alfresco -e \"insert into test values ('magic');\"")
  	.stderr).not_to include('ERROR') }
end

context 'When we check if we can select from table the mysql stdout' do
  it { expect(command("C:\\mariadb\\bin\\mysql.exe --host=172.29.101.51 --user=alfresco --password=alfresco --database=alfresco -e \"select * from test;\"")
    .stdout).to include('magic')}
end

context 'When we check if we can drop a table the mysql stdout' do
  it { expect(command("C:\\mariadb\\bin\\mysql.exe --host=172.29.101.51 --user=alfresco --password=alfresco --database=alfresco -e \"drop table test;\"")
    .stderr).not_to include('ERROR') }
end

end