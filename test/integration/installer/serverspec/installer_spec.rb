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

describe port(8080) do
context 'When we check the status of alfresco port it' do
  it { should be_listening }
end
end

describe port(5432) do
context 'When we check the status of Database port it' do
  it { should be_listening }
end
end

describe port(8443) do
context 'When we check the status of SOLR port it' do
  it { should be_listening }
end
end

describe service('alfresco') do
context 'When alfresco is set to start at boot then the service' do
  it { should be_enabled }
end
end

connection = Faraday.new(:url => "http://localhost:8080",
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
      
describe 'When we are on the root of the server,' do
  it "the body should include Welcome to Alfresco!" do
	expect(connection.get('').body).to include("Welcome to Alfresco!")
  end
end

describe 'When share is up the http status' do
  it { expect(connection.get('/share/page').status).to eq 200 }
end


describe connection.get('/alfresco/').status do
context 'When alfresco is up the http status' do
  it { should eq 200 }
end
end

describe 'When we are on the alfresco main page, the body should include Alfresco WebScripts Home' do
  it { expect(connection.get('/alfresco/').body).to include("Alfresco WebScripts Home") }
end

connection2 = Faraday.new(:url => "http://admin:admin@localhost:8080",
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

describe connection2.get('/alfresco/s/index').status do
context 'When WebScripts page is up the http status' do
  it { should eq 200 }
end
end

describe 'When we are on the Web Scripts main page, the body should include 505 Web Scripts'  do
  it { expect(connection2.get('/alfresco/s/index').body).to include("505 Web Scripts") }
end

describe connection2.get('/alfresco/webdav').status do
context 'When webdav is up the http status' do
  it { should eq 200 }
end
end

describe 'When we are on the webdav main page, the body should include Data Dictionary' do
  it { expect(connection2.get('/alfresco/webdav').body).to include("Data Dictionary") }
end

describe 'When we are on the webdav main page, the body should include Directory listing for /' do
  it { expect(connection2.get('/alfresco/webdav').body).to include("Directory listing for /") }
end

describe connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').status do
context 'When admin console is up the http status' do
  it { should eq 200 }
end
end

describe 'When we are on the admin console main page the body should include System Summary' do
  it { expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include("System Summary") }
end

describe 'When we have solr4 enabled on the admin console page the body' do
  it { expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled") }
end

describe connection2.get('/alfresco/s/api/solrstats').status do
context 'When solr is started correctly, the http status of solrstats' do
  it { should eq 200 }
end
end 
