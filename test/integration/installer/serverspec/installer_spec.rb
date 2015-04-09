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
require 'busser/rubygems'
Busser::RubyGems.install_gem('yarjuf', '~> 2.0.0')
Busser::RubyGems.install_gem('faraday', '~> 0.9.1')

require 'serverspec'
require 'yarjuf'
require 'faraday'

set :backend, :exec

RSpec.configure do |c|
  c.output_stream = File.open('/resources/serverspec-result.xml', 'w')
  c.formatter = 'JUnit'
end

describe port(8080) do
  it { should be_listening.on(host_inventory['ip']).with('tcp') }
end

describe port(5432) do
  it { should be_listening.on(host_inventory['ip']).with('tcp') }
end

describe port(8443) do
  it { should be_listening }
end

describe service('alfresco') do
  it { should be_enabled }
end

connection = Faraday.new(:url => "http://localhost:8080",
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

describe connection.get('/share/page').status do
  it { should eq 200 }
end

describe connection.get('').body do
  it { should include("Welcome to Alfresco!") }
end

describe connection.get('/alfresco/').status do
  it { should eq 200 }
end

describe connection.get('/alfresco/').body do
  it { should include("Alfresco WebScripts Home") }
end

connection2 = Faraday.new(:url => "http://admin:admin@localhost:8080",
	:headers => {'Host' => host_inventory['hostname']}) do |faraday|
        faraday.adapter Faraday.default_adapter
      end

describe connection2.get('/alfresco/s/index').status do
  it { should eq 200 }
end

describe connection2.get('/alfresco/s/index').body do
  it { should include("505 Web Scripts") }
end

describe connection2.get('/alfresco/webdav').status do
  it { should eq 200 }
end

describe connection2.get('/alfresco/webdav').body do
  it { should include("Data Dictionary") }
end

describe connection2.get('/alfresco/webdav').body do
  it { should include("Directory listing for /") }
end

describe connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').status do
  it { should eq 200 }
end

describe connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body do
  it { should include("System Summary") }
end

         
      

