require 'spec_helper'

require_relative '../../spec/helpers'

include Helpers

currentDir=Dir.pwd

# propertiesFile = parsePropertiesFile "#{currentDir}/test.properties"

# puts "\n Running tests on: \n" + command('ifconfig | grep "inet .*"').stdout

puts 'Checking if logfile, properties file, alfresco MMT and alfresco wars exist'
%w(checklist_target_alf_glob
   checklist_target_catalina_log
   checklist_target_alfresco_mmt
checklist_target_alfresco_wars).each do |property|
  if !file(ENV[property]).exists?
    puts "Please check your env variable > #{property}, the file or path does not exist!!!"
    exit!
  end
end

target_host = ENV['checklist_target_host']
logfile = file(ENV['checklist_target_catalina_log']).content
String globalPropertiesFile = file(ENV['checklist_target_alf_glob']).content
glProps = parsePropertiesFile globalPropertiesFile
alfrescoMMT = ENV['checklist_target_alfresco_mmt']
alfrescoWars = ENV['checklist_target_alfresco_wars']

describe 'Alfresco Global Checks:' do
  let(:serverConnection) { $serverConnection ||= getFaradayConnection "http://#{target_host}:8080" }
  let(:authenticatedServerConnection) { authenticatedServerConnection ||= getFaradayConnection "http://admin:admin@#{target_host}:8080" }

  it 'When we check the status of alfresco port it' do
    expect(port(8080)).to be_listening
  end

  it 'When we check the status of Database port it' do
    expect(port(5432)).to be_listening
  end

  it 'When we check the status of SOLR port it' do
    expect(port(8443)).to be_listening
  end

  it 'When alfresco is set to start at boot then the service' do
    expect(service('alfresco')).to be_enabled
  end

  it 'When we are on the root of the server, the body' do
    expect(serverConnection.get('').body).to include('Welcome to Alfresco!')
  end

  it 'When share is up the http status' do
    expect(serverConnection.get('/share/page').status).to eq 200
  end

  it 'When alfresco is up the http status' do
    expect(serverConnection.get('/alfresco/').status).to eq 200
  end

  it 'When we are on the alfresco main page, the body' do
    expect(serverConnection.get('/alfresco/').body).to include('Alfresco WebScripts Home')
  end

  it 'When WebScripts page is up the http status' do
    expect(authenticatedServerConnection.get('/alfresco/s/index').status).to eq 200
  end

  it 'When we are on the Web Scripts main page, the body' do
    expect(authenticatedServerConnection.get('/alfresco/s/index').body).to include('Browse all Web Scripts')
  end

  it 'When webdav is up the http response status' do
    expect(authenticatedServerConnection.get('/alfresco/webdav').status).to eq 200
  end

  it 'When we are on the webdav main page, the body' do
    expect(authenticatedServerConnection.get('/alfresco/webdav').body).to include('Data Dictionary')
  end

  it 'When we are on the webdav main page, the body' do
    expect(authenticatedServerConnection.get('/alfresco/webdav').body).to include('Directory listing for /')
  end

  it 'When admin console is up the http status' do
    expect(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-systemsummary').status).to eq 200
  end

  it 'When we are on the admin console main page the body' do
    expect(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include('System Summary')
  end

  it 'When we have solr4 enabled on the admin console page the body' do
    expect(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled")
  end

  it 'When solr is started correctly, the http status of solrstats' do
    expect(authenticatedServerConnection.get('/alfresco/s/api/solrstats').status).to eq 200
  end

end

puts glProps.values_at('imap.server.imaps.enabled')
describe 'FTP/FTPS settings:' do

  it 'when verifying the alfresco global properties file' do
    expect(glProps).to include('ftp.enabled' => 'true')
    expect(glProps).not_to include('ftp.port' => '')
  end

  let(:ftp) { Net::FTP.new(host = target_host, user='admin', password='admin', acct=nil) }

  it 'can establish a connection at the specified port' do
    expect(ftp.closed?).to be false
  end

  it 'can find budget.xls file on ftp server' do
    ftp.chdir('Alfresco/Sites/swsdp/documentLibrary/Budget Files')
    expect(ftp.list[1]).to include('budget.xls')
  end

  it 'ftp connection can be terminated ' do
    ftp.close
    expect(ftp.closed?).to be true
  end

  it "and the specified port: #{glProps['ftp.port']}" do
    expect(port(glProps['ftp.port'])).to be_listening
  end
end

describe 'JBPM settings:' do
  it { expect(glProps['system.workflow.engine.jbpm.enabled']).to eq 'true' }
  it { expect(glProps['system.workflow.engine.jbpm.definitions.visible']).to eq 'true' }
end

describe 'Cloud license:' do
  it { expect(logfile).to include('[repo.sync.SyncAdminServiceImpl] [localhost-startStop-1] A key is provided for cloud sync') }
end

describe 'Cloud sync and Hybrid:' do
  String cloudUrl = globalPropertiesFile.match(/http.*?(?=a\.alfresco.*)/)
  String computedString = "#{cloudUrl}my.alfresco.me/share/"
  let(:cloudConnection) { $cloudConnection ||= getFaradayConnection computedString }

  it { expect(glProps['hybridworkflow.enabled']).to eq 'true' }
  it { expect(glProps).not_to include('sync.cloud.url' => '') }
  it { expect(glProps).to include('sync.mode' => 'ON_PREMISE') }
  it { expect(glProps).to include('system.serverMode' => 'PRODUCTION') }

  it "When accessing the specified cloud url: #{computedString}" do
    expect(cloudConnection.get('').status).to eq 200
    expect(cloudConnection.get('').body).to include('2005-2015 Alfresco Software')
  end

end

describe 'Invitation enabled: ' do
  it { expect(glProps['notification.email.siteinvite']).to eq 'true' }
end

describe 'Outbound SMTP:' do


  outbound_email = %w(mail.host
                      mail.port
                      mail.transport.protocol
                      mail.username
                      mail.password
                      mail.smtp.auth)
  outbound_email.each do |property|
    it "when verifying the alfresco global properties file #{property}" do
      expect(glProps.key?(property)).to eq true
      expect(glProps[property]).not_to be_nil
    end
  end

  let(:outbound) { $outbound ||= Net::SMTP.start(glProps['mail.host'], glProps['mail.port'], glProps['mail.username'],
                                                 glProps['mail.username'], glProps['mail.password'], :login) }

  it 'when verifying if the mail server responds correctly at the specified port' do

    expect(outbound.started?).to be true

  end
  it 'smtp connection can be terminated ' do
    outbound.finish
    expect(outbound.started?).to be false
  end

  it 'when verifying the alfresco log file' do
    expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'email\' subsystem, ID: [email, outbound] complete')
  end
end

describe 'Imbound mail:' do


  it 'when verifying the alfresco global properties file' do

    expect(glProps['email.inbound.enabled']).to eq 'true'
    expect(glProps['email.server.enabled']).to eq 'true'

  end
  imbound_email = %w(email.server.port
                     email.server.domain
                     email.inbound.unknownUser
                     email.server.allowed.senders)
  imbound_email.each do |property|
    it property do
      expect(glProps.key?(property)).to eq true
      expect(glProps[property]).not_to be_nil
    end
  end

  let(:imbound) { $imbound ||= Net::SMTP.start(target_host, glProps['email.server.port']) }

  it 'when verifying if the Alfresco mail server responds correctly at the specified port' do
    expect(imbound.started?).to be true
  end

  it 'smtp connection can be terminated ' do
    imbound.finish
    expect(imbound.started?).to be false
  end

  it 'when verifying the alfresco log file' do
    expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'email\' subsystem, ID: [email, inbound] complete')
  end

end

describe 'IMAP/IMAPS:' do

  it { expect(glProps['imap.server.enabled']).to eq 'true' }
  it { expect(glProps.key?('imap.server.host')).to eq true
       expect(glProps['imap.server.host']).not_to be_nil }
  it { expect(glProps).not_to include('imap.server.port' => '') }
  it { expect(glProps['imap.server.imaps.enabled']).to eq 'true' }
  it { expect(glProps).not_to include('imap.server.imaps.port' => '') }
  it { expect(glProps).not_to include('javax.net.ssl.keyStore' => '') }
  it { expect(glProps).not_to include('javax.net.ssl.keyStorePassword' => '') }


  let(:imap) { $imap ||= Net::IMAP.new(target_host, port_or_options=glProps['imap.server.port']) }


  it 'can login to imap at the specified port as admin/admin' do
    expect(imap.login('admin', 'admin')[3]).to include('LOGIN completed')
  end

  it 'connection can be terminated ' do
    imap.disconnect
    expect(imap.disconnected?).to be true
  end


  let(:imaps) { $imaps ||= Net::IMAP.new(target_host, options={'port' => glProps['imap.server.imaps.port'], 'ssl' => 'true'}) }

  it 'can login to imaps at the specified port as admin/admin' do
    expect(imaps.login('admin', 'admin')[3]).to include('LOGIN completed')
  end
  it 'connection can be terminated ' do
    imaps.disconnect
    expect(imaps.disconnected?).to be true
  end

  it 'when verifying the admin console, IMAP should be enabled' do

    let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
    let(:html) { $html ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-imap').body) }

    expect(html.xpath('.//span[text()="Enable IMAP:"]/..//input[@checked="checked"]')[0]).not_to be_nil
  end

  it { expect(logfile).to include("[repo.imap.AlfrescoImapServer] [localhost-startStop-1] IMAP service started on host:port #{glProps['imap.server.host']}:#{glProps['imap.server.port']}") }
  it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'imap\' subsystem, ID: [imap, default] complete') }

end

describe 'Replication settings:' do
  it { expect(glProps['replication.enabled']).to eq 'true' }
  it { expect(glProps['transferservice.receiver.enabled']).to eq 'true' }
end



describe 'Transformation Services:' do
  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:transformation) { transformation ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-transformations').body) }

  it 'when verifying the log file' do
    expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [http-bio-8443-exec-7] Startup of \'Transformers\' subsystem, ID: [Transformers, default] complete')
  end
end



describe 'Image Magic:' do
  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:transformation) { transformation ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-transformations').body) }

  it { expect(glProps).not_to include('img.root' => '') }
  it { expect(glProps).not_to include('img.dyn' => '') }
  it { expect(glProps).not_to include('img.exe' => '') }

  it 'when verifying the admin console imagemagick should be enabled and version should be displayed' do
    expect(transformation.xpath('.//span[text()="ImageMagick Available:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
    expect(transformation.xpath('.//div[@class="control field"]//span[contains(text(),"ImageMagick")]')[0]).not_to be_nil
  end
end

describe 'office transformation tools:' do
  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:transformation) { transformation ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-transformations').body) }

  it 'jod converter and office should not be enabled or disabled at the same time' do
    expect(glProps['jodconverter.enabled']).not_to equal(glProps['ooo.enabled'])
  end

  if glProps['jodconverter.enabled'] == 'true'

    it 'when verifying the alfresco global properties file' do
      expect(glProps).not_to include('jodconverter.officeHome' => '')
      expect(glProps).not_to include('jodconverter.portNumbers' => '')
    end

    it "port specified: #{glProps['jodconverter.portNumbers']}" do
      expect(port(glProps['jodconverter.portNumbers'])).to be_listening
    end

    it 'JodConverter should be enabled in admin console' do
      expect(transformation.xpath('.//span[text()="JODConverter Enabled:"]/..//input[@checked="checked"]')[0]).not_to be_nil
    end

  else

    it 'when verifying the alfresco global properties file' do
      expect(glProps).not_to include('ooo.exe' => '')
      expect(glProps['ooo.enabled']).to eq 'true'
      expect(glProps).not_to include('ooo.port' => '')
    end

    it "port specified: #{glProps['ooo.port']}" do
      expect(port(glProps['ooo.port'])).to be_listening
    end

    it 'when verifying the log file' do
      expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'OOoDirect\' subsystem, ID: [OOoDirect, default] complete')
      expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'OOoJodconverter\' subsystem, ID: [OOoJodconverter, default] complete')
    end


  end

end

describe 'swftools:' do
  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:transformation) { transformation ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-transformations').body) }

  it 'when verifying the alfresco global properties file' do
    expect(glProps).not_to include('swf.exe' => '')
    expect(glProps).not_to include('swf.languagedir' => '')
  end

  it 'when verifying the admin console swftools should be enabled and version displayed' do
    expect(transformation.xpath('.//span[text()="PDF2SWF Available:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
    expect(transformation.xpath('.//div[@class="control field"]//span[contains(text(),"pdf2swf")]')[0]).not_to be_nil
  end

end

describe 'JMX settings:' do

  jmx = %w(alfresco.rmi.services.port
           alfresco.rmi.services.host
           monitor.rmi.service.port
           avm.rmi.service.port
           avmsync.rmi.service.port
           attribute.rmi.service.port
           authentication.rmi.service.port
           repo.rmi.service.port
           action.rmi.service.port
           deployment.rmi.service.port)
  jmx.each do |property|
    it property do
      expect(glProps.key?(property)).to eq true
      expect(glProps[property]).not_to be_nil
    end
  end
  it 'we can connect to the specified host and port' do
    expect(Net::Telnet::new('Host' => glProps['alfresco.rmi.services.host'], 'Port' => glProps['alfresco.rmi.services.port'])).not_to be_nil
  end
end

describe 'Alfresco License:' do
  it 'when verifying the alfresco global properties file' do
    expect(glProps).not_to include('dir.license.external' => '')
    expect(command("ls #{glProps['dir.license.external']} | grep .lic.installed").exit_status).to equal(0)
  end

  it 'when verifying the log file' do
    expect(logfile).to include('[enterprise.license.AlfrescoLicenseManager] [localhost-startStop-1] Successfully installed license from file')
    expect(logfile).to include('[service.descriptor.DescriptorService] [localhost-startStop-1] Alfresco license: Mode ENTERPRISE')
  end

  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:license) { license ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-license').body) }

  it 'Max Users should be unlimited on admin console' do
    expect(license.xpath('.//span[text()="Max Users:"]/..')[0].content).to include('Unlimited')
  end
  it 'Max Content Objects should be unlimited on admin console' do
    expect(license.xpath('.//span[text()="Max Content Objects:"]/..//span[text()="Unlimited"]')[0]).not_to be_nil
  end
  it 'Heartbeat should be enabled on admin console' do
    expect(license.xpath('.//span[text()="Heart Beat:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
  end
  it 'CloudSync should be enabled on admin console' do
    expect(license.xpath('.//span[text()="Cloud Sync:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
  end
  it 'Repository Server Clustering should be enabled on admin console' do
    expect(license.xpath('.//span[text()="Clustering Permitted:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
  end
  it 'Encrypted Content Store should be enabled on admin console' do
    expect(license.xpath('.//span[text()="Encrypting Permitted:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
  end

end

describe 'Google docs:' do

  it 'when verifying the log file' do
    expect(logfile).to include('[repo.module.ModuleServiceImpl] [localhost-startStop-1] Installing module \'org.alfresco.integrations.google.docs\' version')
    expect(logfile).to include('[localhost-startStop-1] Startup of \'googledocs\' subsystem, ID: [googledocs, drive] complete')
  end

  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:google) { google ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-googledocs').body) }

  it 'Google Docs should be enabled on admin console' do
    expect(google.xpath('.//span[text()="Google Docs™ Enabled:"]/..//input[@checked="checked"]')[0]).not_to be_nil
  end

  it 'should be installed in alfresco war' do
    expect(command("java -jar #{alfrescoMMT} list #{alfrescoWars}alfresco.war").stdout).to include('Module \'org.alfresco.integrations.google.docs\' installed')
  end

  it 'should be installed in share war' do
    expect(command("java -jar #{alfrescoMMT} list #{alfrescoWars}share.war").stdout).to include('Module \'org.alfresco.integrations.share.google.docs\' installed')
  end

end

describe 'CIFS: ' do

  it {  expect(glProps['cifs.enabled']).to eq 'true' }
  it {  expect(glProps['cifs.hostannounce']).to eq 'true' }
  it {  expect(glProps.key?('cifs.domain')).to eq true }

  cifs = %w(cifs.serverName
            cifs.tcpipSMB.port
            cifs.netBIOSSMB.datagramPort
            cifs.netBIOSSMB.sessionPort)
  cifs.each do |property|
    it property do
      expect(glProps.key?(property)).to eq true
      expect(glProps[property]).not_to be_nil
    end
  end

  it "port specified for cifs.tcpipSMB.port: #{glProps['cifs.tcpipSMB.port']}" do
    expect(port(glProps['cifs.tcpipSMB.port'])).to be_listening
  end
  it "port specified for cifs.netBIOSSMB.namePort : #{glProps['cifs.netBIOSSMB.namePort']}" do
    expect(port(glProps['cifs.netBIOSSMB.namePort'])).to be_listening
  end
  it "port specified for cifs.netBIOSSMB.sessionPort: #{glProps['cifs.netBIOSSMB.sessionPort']}" do
    expect(port(glProps['cifs.netBIOSSMB.sessionPort'])).to be_listening
  end
  it { expect(port(445)).to be_listening }
  it { expect(port(139)).to be_listening }
  it { expect(port(138)).to be_listening }

  it 'when verifying the log file' do
    expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'fileServers\' subsystem, ID: [fileServers, default] complete')
  end

end

describe 'WCMQS :' do
  it 'when verifying the log file' do
    expect(logfile).to include('[repo.module.ModuleServiceImpl] [localhost-startStop-1] Installing module \'org_alfresco_module_wcmquickstart\'')
  end

  it 'should be installed in alfresco war' do
    expect(command("java -jar #{alfrescoMMT} list #{alfrescoWars}alfresco.war").stdout).to include('Module \'org_alfresco_module_wcmquickstart\' installed')
  end

  it 'should be installed in share war' do
    expect(command("java -jar #{alfrescoMMT} list #{alfrescoWars}share.war").stdout).to include('Module \'org_alfresco_module_wcmquickstartshare\' installed')
  end

end

describe 'NFS :' do
  nfs = %w(nfs.mountServerPort
           nfs.nfsServerPort
           nfs.rpcRegisterPort
           nfs.portMapperPort
           nfs.user.mappings.value.admin.uid
           nfs.user.mappings.value.admin.gid
           nfs.user.mappings.value.corinaz.uid
           nfs.user.mappings.value.corinaz.gid)
  nfs.each do |property|
    it property do
      expect(glProps.key?(property)).to eq true
      expect(glProps[property]).not_to be_nil
    end
  end

  nfsbooleans = %w(nfs.enabled
                   nfs.portMapperEnabled
                   nfs.mountServerDebug)
  nfsbooleans.each do |property|
    it property do
      expect(glProps[property]).to eq 'true'
    end
  end

  it { expect(glProps['nfs.sessionDebug']).to eq 'ERROR' }
  it { expect(glProps['nfs.user.mappings']).to eq 'admin' }

  nfsports = %w(nfs.mountServerPort
                nfs.nfsServerPort
                nfs.rpcRegisterPort
                nfs.portMapperPort)
  nfsports.each do |property|
    it "port specified for #{property}: #{glProps[property]}" do
      expect(port(glProps[property])).to be_listening
    end
  end

end
