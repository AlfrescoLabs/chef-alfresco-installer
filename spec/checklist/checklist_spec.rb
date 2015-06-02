require 'spec_helper'

currentDir=Dir.pwd
propertiesFile = {}
IO.foreach("#{currentDir}/test.properties") do |line|
  propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = "File Name #{"#{currentDir}/test.properties"} \n"
propertiesFile.each {|key,value| output += " #{key}= #{value} \n" }


puts "\n Running tests on: \n" + command('ifconfig | grep "inet .*"').stdout

target_host = ENV['checklist_target_host']

describe 'Alfresco Global Checks' do

  context 'When we check the status of alfresco port it' do
   it  {expect(port(8080)).to be_listening}
  end

  context 'When we check the status of Database port it' do
   it  {expect(port(5432)).to be_listening}
  end

  context 'When we check the status of SOLR port it' do
   it  {expect(port(8443)).to be_listening}
  end

  context 'When alfresco is set to start at boot then the service'  do
   it  {expect(service('alfresco')).to be_enabled}
  end

  connection = Faraday.new(:url => "http://#{target_host}:8080",
                           :headers => {'Host' => host_inventory['hostname']}) do |faraday|
    faraday.adapter Faraday.default_adapter
  end

  context 'When we are on the root of the server, the body' do
   it  {expect(connection.get('').body).to include('Welcome to Alfresco!')}
  end

  context 'When share is up the http status' do
   it  {expect(connection.get('/share/page').status).to eq 200}
  end

  context 'When alfresco is up the http status' do
   it  {expect(connection.get('/alfresco/').status).to eq 200}
  end

  context 'When we are on the alfresco main page, the body' do
   it  {expect(connection.get('/alfresco/').body).to include('Alfresco WebScripts Home')}
  end

  connection2 = Faraday.new(:url => "http://admin:admin@#{target_host}:8080",
                            :headers => {'Host' => host_inventory['hostname']}) do |faraday|
    faraday.adapter Faraday.default_adapter
  end

  context 'When WebScripts page is up the http status' do
   it  {expect(connection2.get('/alfresco/s/index').status).to eq 200}
  end

  context 'When we are on the Web Scripts main page, the body'  do
   it  {expect(connection2.get('/alfresco/s/index').body).to include('Browse all Web Scripts')}
  end

  context 'When webdav is up the http response status' do
   it  {expect(connection2.get('/alfresco/webdav').status).to eq 200}
  end

  context 'When we are on the webdav main page, the body' do
   it  {expect(connection2.get('/alfresco/webdav').body).to include('Data Dictionary')}
  end

  context 'When we are on the webdav main page, the body' do
   it  {expect(connection2.get('/alfresco/webdav').body).to include('Directory listing for /')}
  end

  context 'When admin console is up the http status' do
   it  {expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').status).to eq 200}
  end

  context 'When we are on the admin console main page the body' do
   it  {expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include('System Summary')}
  end

  context 'When we have solr4 enabled on the admin console page the body' do
   it  {expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled")}
  end

  context 'When solr is started correctly, the http status of solrstats' do
   it  {expect(connection2.get('/alfresco/s/api/solrstats').status).to eq 200}
  end

end

String globalPropertiesFile = file(ENV['checklist_target_alf_glob']).content
glProps = {}
globalPropertiesFile.each_line do |line|
  glProps[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = 'File Name alfresco-global.glProps \n'
glProps.each {|key,value| output += " #{key}= #{value} \n" }

describe 'FTP/FTPS settings' do
  it {expect(glProps).to include("ftp.enabled" => "true")}
  it {expect(glProps).not_to include("ftp.port" => "")}
  context "and the specified port: #{glProps["ftp.port"]}" do
    it {expect(port(glProps['ftp.port'])).to be_listening}
  end
end

describe 'JBPM settings' do
  it {expect(glProps).to include('system.workflow.engine.jbpm.enabled' => 'true')}
  it {expect(glProps).to include('system.workflow.engine.jbpm.definitions.visible' => 'true')}
end

logfile = file(ENV['checklist_target_catalina_log']).content

describe 'Cloud license' do
  it {expect(logfile).to include('[repo.sync.SyncAdminServiceImpl] [localhost-startStop-1] A key is provided for cloud sync')}
end
String cloudUrl = globalPropertiesFile.match( /http.*?(?=a\.alfresco.*)/)
String computedString =  "#{cloudUrl}my.alfresco.me/share/"
cloudConnection = Faraday.new(:url => computedString,
                              :headers => {'Host' => host_inventory['hostname']}) do |faraday|
  faraday.adapter Faraday.default_adapter
end

describe 'Cloud sync and Hybrid' do
  it {expect(glProps).to include('hybridworkflow.enabled'=>'true')}
  it {expect(glProps).not_to include('sync.cloud.url'=>'')}
  context "When accessing the specified cloud url: #{computedString}"  do
    it {expect(cloudConnection.get('').status).to eq 200}
    it {expect(cloudConnection.get('').body).to include('2005-2015 Alfresco Software')}
  end
  it {expect(glProps).to include('sync.mode'=>'ON_PREMISE')}
  it {expect(glProps).to include('system.serverMode'=>'PRODUCTION')}
end
