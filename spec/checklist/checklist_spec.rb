require 'spec_helper'

currentDir=Dir.pwd
propertiesFile = {}
IO.foreach("#{currentDir}/test.glProps") do |line|
  propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = "File Name #{"#{currentDir}/test.glProps"} \n"
propertiesFile.each {|key,value| output += " #{key}= #{value} \n" }


puts "\n Running tests on: \n" + command('ifconfig | grep "inet .*"').stdout


if ENV['checklist_target_host']
  target_host = ENV['checklist_target_host']
else
  target_host = propertiesFile['host']
end

describe 'Alfresco Global Checks' do

  it {expect(port(8080)).to be_listening}
  it {expect(port(5432)).to be_listening}
  it {expect(port(8443)).to be_listening}
  it {expect(service('alfresco')).to be_enabled}

  connection = Faraday.new(:url => "http://#{target_host}:8080",
                           :headers => {'Host' => host_inventory['hostname']}) do |faraday|
    faraday.adapter Faraday.default_adapter
  end

  it {expect(connection.get('').body).to include('Welcome to Alfresco!')}
  it {expect(connection.get('/share/page').status).to eq 200}
  it {expect(connection.get('/alfresco/').status).to eq 200}
  it {expect(connection.get('/alfresco/').body).to include('Alfresco WebScripts Home')}

  connection2 = Faraday.new(:url => "http://admin:admin@#{target_host}:8080",
                            :headers => {'Host' => host_inventory['hostname']}) do |faraday|
    faraday.adapter Faraday.default_adapter
  end

  it {expect(connection2.get('/alfresco/s/index').status).to eq 200}
  it {expect(connection2.get('/alfresco/s/index').body).to include('Browse all Web Scripts')}
  it {expect(connection2.get('/alfresco/webdav').status).to eq 200}
  it {expect(connection2.get('/alfresco/webdav').body).to include('Data Dictionary')}
  it {expect(connection2.get('/alfresco/webdav').body).to include('Directory listing for /')}
  it {expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').status).to eq 200}
  it {expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include('System Summary')}
  it {expect(connection2.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled")}
  it {expect(connection2.get('/alfresco/s/api/solrstats').status).to eq 200}

end
if ENV['checklist_target_alf_glob']
  alfrescoGlobalFileLocation = ENV['checklist_target_alf_glob']
else
  alfrescoGlobalFileLocation = propertiesFile['alfrescoGlobalFileLocation']
end

String globalPropertiesFile = file(alfrescoGlobalFileLocation).content
glProps = {}
globalPropertiesFile.each_line do |line|
  glProps[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = 'File Name alfresco-global.glProps \n'
glProps.each {|key,value| output += " #{key}= #{value} \n" }

describe 'FTP/FTPS settings' do
  it {expect(glProps).to include('ftp.enabled' => 'true')}
  it {expect(glProps).not_to include('ftp.port' => '')}
  context "and the port set : #{glProps['ftp.port']}" do
    it {expect(port(glProps['ftp.port'])).to be_listening}
  end
end

describe 'JBPM settings' do
  it {expect(glProps).to include('system.workflow.engine.jbpm.enabled' => 'true')}
  it {expect(glProps).to include('system.workflow.engine.jbpm.definitions.visible' => 'true')}
end