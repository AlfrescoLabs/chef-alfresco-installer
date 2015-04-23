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

describe 'Validate postgres Installation' do

context 'When we check the status postgres 5432 port it' do
  it { expect(port(5432)).to be_listening }
end

context 'When we verify if psql executable in the default path' do
  it { expect(file('/usr/local/pgsql/bin/psql')).to be_file }
end

context 'When we run ps -u postgres -f | grep postgres: to check if postgres is running the exit status  ' do
  it { expect(command("ps -u postgres -f | grep postgres:").exit_status).to eq 0 }
end

context 'When we login as postgres user then whoami' do
  it { expect(command("su - postgres -c 'whoami'").stdout).to match /postgres/ }
end

context 'When we check the list of databases on the server it' do
  it { expect(command("su - postgres -c /usr/local/pgsql/bin/psql << EOF
		\\list
		\\q 
		EOF").stdout).to include("alfresco") }
end

context 'When we check the list of users on the server it' do
  it { expect(command("su - postgres -c /usr/local/pgsql/bin/psql << EOF
		\\du
		\\q 
		EOF").stdout).to include("alfresco") }
end

end