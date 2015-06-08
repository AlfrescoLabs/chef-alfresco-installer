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
# require 'busser/rubygems'
require 'serverspec'
require 'yarjuf'
require 'faraday'

set :backend, :exec
testProperties=''

case RbConfig::CONFIG['host_os']
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    testProperties = 'C:\\test.properties'
  else
    testProperties = '/opt/test.properties'
end

propertiesFile = {}
IO.foreach(testProperties) do |line|
  propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = "File Name #{testProperties} \n"
propertiesFile.each {|key,value| output += " #{key}= #{value} \n" }

describe 'Alfresco Global Checks' do

it 'When we check the status of alfresco port it' do
   expect(port(8080)).to be_listening
end

it 'When we check the status of Database port it' do
   expect(port(5432)).to be_listening
end

it 'When we check the status of SOLR port it' do
   expect(port(8443)).to be_listening
end

it 'When alfresco is set to start at boot then the service'  do
   expect(service('alfresco')).to be_enabled
end

connection = Faraday.new(:url => 'http://localhost:8080',
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
      
it 'When we are on the root of the server, the body' do
	 expect(connection.get('').body).to include('Welcome to Alfresco!')
end

it 'When share is up the http status' do
   expect(connection.get('/share/page').status).to eq 200
end

it 'When alfresco is up the http status' do
   expect(connection.get('/alfresco/').status).to eq 200
end

it 'When we are on the alfresco main page, the body' do
   expect(connection.get('/alfresco/').body).to include('Alfresco WebScripts Home')
end

connection2 = Faraday.new(:url => 'http://admin:admin@localhost:8080',
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

it 'When WebScripts page is up the http status' do
   expect(connection2.get('/alfresco/s/index').status).to eq 200
end

it 'When we are on the Web Scripts main page, the body'  do
   expect(connection2.get('/alfresco/s/index').body).to include('Browse all Web Scripts')
end

it 'When webdav is up the http response status' do
   expect(connection2.get('/alfresco/webdav').status).to eq 200
end

it 'When we are on the webdav main page, the body' do
   expect(connection2.get('/alfresco/webdav').body).to include('Data Dictionary')
end

it 'When we are on the webdav main page, the body' do
   expect(connection2.get('/alfresco/webdav').body).to include('Directory listing for /')
end

it 'When admin console is up the http status' do
   expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').status).to eq 200
end

it 'When we are on the admin console main page the body' do
   expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include('System Summary')
end

it 'When we have solr4 enabled on the admin console page the body' do
   expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled")
end

it 'When solr is started correctly, the http status of solrstats' do
   expect(connection2.get('/alfresco/s/api/solrstats').status).to eq 200
end 

end

  properties = {}
  IO.foreach(propertiesFile['alfrescoGlobalLocation']) do |line|
    properties[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
  end
  output = "File Name #{propertiesFile['alfrescoGlobalLocation']} \n"
  properties.each {|key,value| output += " #{key}= #{value} \n" }

describe 'FTP/FTPS settings' do
  it {expect(properties).to include('ftp.enabled' => 'true')}
  it {expect(properties).not_to include('ftp.port' => '')}
  context "and the port set : #{properties['ftp.port']}" do
    it {expect(port(properties['ftp.port'])).to be_listening}
  end
end

describe 'JBPM settings' do
  it {expect(properties).to include('system.workflow.engine.jbpm.enabled' => 'true')}
  it {expect(properties).to include('system.workflow.engine.jbpm.definitions.visible' => 'true')}
end