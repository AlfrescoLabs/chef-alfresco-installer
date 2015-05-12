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

connection = Faraday.new(:url => 'http://172.29.101.51:8080',
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
     
describe 'When we are on the root of the server, the body' do
  it { expect(connection.get('').body).to include('Welcome to Alfresco!') }
end

describe 'When share is up the http status' do
  it { expect(connection.get('/share/page').status).to eq 200 }
end

describe 'When alfresco is up the http status' do
  it { expect(connection.get('/alfresco/').status).to eq 200 }
end

describe 'When we are on the alfresco main page, the body' do
  it { expect(connection.get('/alfresco/').body).to include('Alfresco WebScripts Home') }
end

connection2 = Faraday.new(:url => 'http://admin:admin@172.29.101.51:8080',
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

describe 'When WebScripts page is up the http status' do
  it { expect(connection2.get('/alfresco/s/index').status).to eq 200 }
end

describe 'When we are on the Web Scripts main page, the body'  do
  it { expect(connection2.get('/alfresco/s/index').body).to include('Browse all Web Scripts') }
end

describe 'When webdav is up the http response status' do
  it { expect(connection2.get('/alfresco/webdav').status).to eq 200 }
end

describe 'When we are on the webdav main page, the body' do
  it { expect(connection2.get('/alfresco/webdav').body).to include('Data Dictionary') }
end

describe 'When we are on the webdav main page, the body' do
  it { expect(connection2.get('/alfresco/webdav').body).to include('Directory listing for /') }
end

describe 'When admin console is up the http status' do
  it { expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').status).to eq 200 }
end

describe 'When we are on the admin console main page the body' do
  it { expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include('System Summary') }
end

describe 'When we have solr4 enabled on the admin console page the body' do
  it { expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled") }
end

describe 'When solr is started correctly, the http status of solrstats' do
  it { expect(connection2.get('/alfresco/s/api/solrstats').status).to eq 200 }
end 
