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
  context 'When we check the status of alfresco port it' do
    it { expect(port(8080)).to be_listening }
  end

  context 'When we check the status of Database port it' do
    it { expect(port(5432)).to be_listening }
  end

  context 'When we check the status of SOLR port it' do
    it { expect(port(8443)).to be_listening }
  end

  context 'When alfresco is set to start at boot then the service' do
    it { expect(service('alfresco')).to be_enabled }
  end

  context 'When we are on the root of the server, the body' do
    it { expect(serverConnection.get('').body).to include('Welcome to Alfresco!') }
  end

  context 'When share is up the http status' do
    it { expect(serverConnection.get('/share/page').status).to eq 200 }
  end

  context 'When alfresco is up the http status' do
    it { expect(serverConnection.get('/alfresco/').status).to eq 200 }
  end

  context 'When we are on the alfresco main page, the body' do
    it { expect(serverConnection.get('/alfresco/').body).to include('Alfresco WebScripts Home') }
  end

  context 'When WebScripts page is up the http status' do
    it { expect(authenticatedServerConnection.get('/alfresco/s/index').status).to eq 200 }
  end

  context 'When we are on the Web Scripts main page, the body' do
    it { expect(authenticatedServerConnection.get('/alfresco/s/index').body).to include('Browse all Web Scripts') }
  end

  context 'When webdav is up the http response status' do
    it { expect(authenticatedServerConnection.get('/alfresco/webdav').status).to eq 200 }
  end

  context 'When we are on the webdav main page, the body' do
    it { expect(authenticatedServerConnection.get('/alfresco/webdav').body).to include('Data Dictionary') }
  end

  context 'When we are on the webdav main page, the body' do
    it { expect(authenticatedServerConnection.get('/alfresco/webdav').body).to include('Directory listing for /') }
  end

  context 'When admin console is up the http status' do
    it { expect(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-systemsummary').status).to eq 200 }
  end

  context 'When we are on the admin console main page the body' do
    it { expect(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to include('System Summary') }
  end

  context 'When we have solr4 enabled on the admin console page the body' do
    it { expect(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-systemsummary').body).to match(">Solr\ 4.*\n.*\n.*Enabled") }
  end

  context 'When solr is started correctly, the http status of solrstats' do
    it { expect(authenticatedServerConnection.get('/alfresco/s/api/solrstats').status).to eq 200 }
  end

end

puts glProps.values_at('imap.server.imaps.enabled')
describe 'FTP/FTPS settings:' do

  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).to include('ftp.enabled' => 'true') }
    it { expect(glProps).not_to include('ftp.port' => '') }
  end
  context 'when verifying if the Alfresco ftp server responds correctly at the specified port' do
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
  end
  context "and the specified port: #{glProps['ftp.port']}" do
    it { expect(port(glProps['ftp.port'])).to be_listening }
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
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps['hybridworkflow.enabled']).to eq 'true' }
    it { expect(glProps).not_to include('sync.cloud.url' => '') }
    it { expect(glProps).to include('sync.mode' => 'ON_PREMISE') }
    it { expect(glProps).to include('system.serverMode' => 'PRODUCTION') }
  end
  context "When accessing the specified cloud url: #{computedString}" do
    it { expect(cloudConnection.get('').status).to eq 200 }
    it { expect(cloudConnection.get('').body).to include('2005-2015 Alfresco Software') }
  end
end

describe 'Invitation enabled: ' do
  it { expect(glProps['notification.email.siteinvite']).to eq 'true' }
end

describe 'Outbound SMTP:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).not_to include('mail.host' => '') }
    it { expect(glProps).not_to include('mail.port' => '') }
    it { expect(glProps).not_to include('mail.transport.protocol' => '') }
    it { expect(glProps).not_to include('mail.username' => '') }
    it { expect(glProps).not_to include('mail.password' => '') }
    it { expect(glProps).not_to include('mail.smtp.auth' => '') }
  end
  context 'when verifying if the mail server responds correctly at the specified port' do
    let(:outbound) { $outbound ||= Net::SMTP.start(glProps['mail.host'], glProps['mail.port'], glProps['mail.username'],
                                                   glProps['mail.username'], glProps['mail.password'], :login) }
    it { expect(outbound.started?).to be true }
    it 'smtp connection can be terminated ' do
      outbound.finish
      expect(outbound.started?).to be false
    end
  end
  context 'when verifying the alfresco log file' do
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'email\' subsystem, ID: [email, outbound] complete') }
  end
end

describe 'Imbound mail:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps['email.inbound.enabled']).to eq 'true' }
    it { expect(glProps).not_to include('email.server.allowed.senders' => '') }
    it { expect(glProps['email.server.enabled']).to eq 'true' }
    it { expect(glProps).not_to include('email.server.port' => '') }
    it { expect(glProps).not_to include('email.server.domain' => '') }
    it { expect(glProps).not_to include('email.inbound.unknownUser' => '') }
  end
  context 'when verifying if the Alfresco mail server responds correctly at the specified port' do
    let(:imbound) { $imbound ||= Net::SMTP.start(target_host, glProps['email.server.port']) }
    it { expect(imbound.started?).to be true }
    it 'smtp connection can be terminated ' do
      imbound.finish
      expect(imbound.started?).to be false
    end
  end
  context 'when verifying the alfresco log file' do
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'email\' subsystem, ID: [email, inbound] complete') }
  end
end

describe 'IMAP/IMAPS:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps['imap.server.enabled']).to eq 'true' }
    it { expect(glProps.key?('imap.server.host')).to eq true
    expect(glProps['imap.server.host']).not_to be_nil }
    it { expect(glProps).not_to include('imap.server.port' => '') }
    it { expect(glProps['imap.server.imaps.enabled']).to eq 'true' }
    it { expect(glProps).not_to include('imap.server.imaps.port' => '') }
    it { expect(glProps).not_to include('javax.net.ssl.keyStore' => '') }
    it { expect(glProps).not_to include('javax.net.ssl.keyStorePassword' => '') }
  end
  context 'when verifying if the Alfresco imap server responds correctly at the specified port' do
    let(:imap) { $imap ||= Net::IMAP.new(target_host, port_or_options=glProps['imap.server.port']) }

    it 'can login as admin/admin' do
      expect(imap.login('admin', 'admin')[3]).to include('LOGIN completed')
    end
    it 'connection can be terminated ' do
      imap.disconnect
      expect(imap.disconnected?).to be true
    end
  end

  context 'when verifying if the Alfresco imap secure server responds correctly at the specified port' do
    let(:imaps) { $imaps ||= Net::IMAP.new(target_host, options={'port' => glProps['imap.server.imaps.port'], 'ssl' => 'true'}) }

    it 'can login as admin/admin' do
      expect(imaps.login('admin', 'admin')[3]).to include('LOGIN completed')
    end
    it 'connection can be terminated ' do
      imaps.disconnect
      expect(imaps.disconnected?).to be true
    end
  end

  context 'when verifying the admin console' do

    let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
    let(:html) { $html ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-imap').body) }

    it 'imap should be enabled' do
      expect(html.xpath('.//span[text()="Enable IMAP:"]/..//input[@checked="checked"]')[0]).not_to be_nil
    end
  end

  context 'when verifying the alfresco log file' do
    it { expect(logfile).to include("[repo.imap.AlfrescoImapServer] [localhost-startStop-1] IMAP service started on host:port #{glProps['imap.server.host']}:#{glProps['imap.server.port']}") }
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'imap\' subsystem, ID: [imap, default] complete') }
  end
end

describe 'Replication settings:' do
  it { expect(glProps['replication.enabled']).to eq 'true' }
  it { expect(glProps['transferservice.receiver.enabled']).to eq 'true' }
end

describe 'Transformation Services:' do
  let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
  let(:transformation) { transformation ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-transformations').body) }

  context 'when verifying the log file' do
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [http-bio-8443-exec-7] Startup of \'Transformers\' subsystem, ID: [Transformers, default] complete') }
  end

  describe 'Image Magic:' do
    context 'when verifying the alfresco global properties file' do
      it { expect(glProps).not_to include('img.root' => '') }
      it { expect(glProps).not_to include('img.dyn' => '') }
      it { expect(glProps).not_to include('img.exe' => '') }
    end
    context 'when verifying the admin console' do
      it 'imagemagick should be enabled' do
        expect(transformation.xpath('.//span[text()="ImageMagick Available:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
      end
      it 'imagemagick version is displayed' do
        expect(transformation.xpath('.//div[@class="control field"]//span[contains(text(),"ImageMagick")]')[0]).not_to be_nil
      end
    end
  end

  describe 'office transformation tools:' do

    it 'jod converter and office should not be enabled or disabled at the same time' do
      expect(glProps['jodconverter.enabled']).not_to equal(glProps['ooo.enabled'])
    end

    if glProps['jodconverter.enabled'] == 'true'

      describe 'JodConvertor:' do

        context 'when verifying the alfresco global properties file' do
          it { expect(glProps).not_to include('jodconverter.officeHome' => '') }
          it { expect(glProps['jodconverter.enabled']).to eq 'true' }
          it { expect(glProps).not_to include('jodconverter.portNumbers' => '') }
        end

        it "port specified: #{glProps['jodconverter.portNumbers']}" do
          expect(port(glProps['jodconverter.portNumbers'])).to be_listening
        end

        context 'when verifying the admin console' do
          it 'JodConverter should be enabled' do
            expect(transformation.xpath('.//span[text()="JODConverter Enabled:"]/..//input[@checked="checked"]')[0]).not_to be_nil
          end
        end
      end

    else

      describe 'OpenOffice:' do

        context 'when verifying the alfresco global properties file' do
          it { expect(glProps).not_to include('ooo.exe' => '') }
          it { expect(glProps['ooo.enabled']).to eq 'true' }
          it { expect(glProps).not_to include('ooo.port' => '') }
        end

        it "port specified: #{glProps['ooo.port']}" do
          expect(port(glProps['ooo.port'])).to be_listening
        end

        context 'when verifying the log file' do
          it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'OOoDirect\' subsystem, ID: [OOoDirect, default] complete') }
          it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'OOoJodconverter\' subsystem, ID: [OOoJodconverter, default] complete') }
        end
      end

    end

  end

  describe 'swftools:' do
    context 'when verifying the alfresco global properties file' do
      it { expect(glProps).not_to include('swf.exe' => '') }
      it { expect(glProps).not_to include('swf.languagedir' => '') }
    end
    context 'when verifying the admin console' do
      it 'swftools should be enabled' do
        expect(transformation.xpath('.//span[text()="PDF2SWF Available:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
      end
      it 'swftools version is displayed' do
        expect(transformation.xpath('.//div[@class="control field"]//span[contains(text(),"pdf2swf")]')[0]).not_to be_nil
      end
    end
  end

end


describe 'JMX settings:' do
  context 'when verifying the alfresco global properties file' do
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
end

describe 'Alfresco License:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).not_to include('dir.license.external' => '') }
    it 'license exists at the location specified in properties' do
      expect(command("ls #{glProps['dir.license.external']} | grep .lic.installed").exit_status).to equal(0)
    end
  end
  context 'when verifying the log file' do
    it { expect(logfile).to include('[enterprise.license.AlfrescoLicenseManager] [localhost-startStop-1] Successfully installed license from file') }
    it { expect(logfile).to include('[service.descriptor.DescriptorService] [localhost-startStop-1] Alfresco license: Mode ENTERPRISE') }
  end
  context 'when verifying the admin console' do
    let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
    let(:license) { license ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-license').body) }

    it 'Max Users should be unlimited' do
      expect(license.xpath('.//span[text()="Max Users:"]/..')[0].content).to include('Unlimited')
    end
    it 'Max Content Objects should be unlimited' do
      expect(license.xpath('.//span[text()="Max Content Objects:"]/..//span[text()="Unlimited"]')[0]).not_to be_nil
    end
    it 'Heartbeat should be enabled' do
      expect(license.xpath('.//span[text()="Heart Beat:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
    end
    it 'CloudSync should be enabled' do
      expect(license.xpath('.//span[text()="Cloud Sync:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
    end
    it 'Repository Server Clustering should be enabled' do
      expect(license.xpath('.//span[text()="Clustering Permitted:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
    end
    it 'Encrypted Content Store should be enabled' do
      expect(license.xpath('.//span[text()="Encrypting Permitted:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
    end
  end
end

describe 'Google docs:' do

  context 'when verifying the log file' do
    it { expect(logfile).to include('[repo.module.ModuleServiceImpl] [localhost-startStop-1] Installing module \'org.alfresco.integrations.google.docs\' version') }
    it { expect(logfile).to include('[localhost-startStop-1] Startup of \'googledocs\' subsystem, ID: [googledocs, drive] complete') }
  end

  context 'when verifying the admin console' do
    let(:authenticatedServerConnection) { getFaradayConnection "http://admin:admin@#{target_host}:8080" }
    let(:google) { google ||= Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-googledocs').body) }

    it 'Google Docs should be enabled' do
      expect(google.xpath('.//span[text()="Google Docs™ Enabled:"]/..//input[@checked="checked"]')[0]).not_to be_nil
    end
  end

  context command("java -jar #{alfrescoMMT} list #{alfrescoWars}alfresco.war") do
    its(:stdout) { is_expected.to include('Module \'org.alfresco.integrations.google.docs\' installed') }
  end

  context command("java -jar #{alfrescoMMT} list #{alfrescoWars}share.war") do
    its(:stdout) { is_expected.to include('Module \'org.alfresco.integrations.share.google.docs\' installed') }
  end

end

describe 'CIFS: ' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps['cifs.enabled']).to eq 'true' }
    it { expect(glProps['cifs.hostannounce']).to eq 'true' }
    it { expect(glProps.key?('cifs.domain')).to eq true}

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
    it "port specified for cifs.netBIOSSMB.datagramPort : #{glProps['cifs.netBIOSSMB.datagramPort']}" do
      expect(port(glProps['cifs.netBIOSSMB.datagramPort'])).to be_listening
    end
    it "port specified for cifs.netBIOSSMB.sessionPort: #{glProps['cifs.netBIOSSMB.sessionPort']}" do
      expect(port(glProps['cifs.netBIOSSMB.sessionPort'])).to be_listening
    end
    it { expect(port(445)).to be_listening }
    it { expect(port(139)).to be_listening }
    it { expect(port(137)).to be_listening }
    it { expect(port(138)).to be_listening }
  end

  context 'when verifying the log file' do
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'fileServers\' subsystem, ID: [fileServers, default] complete') }
  end

end


describe 'WCMQS :' do
  context 'when verifying the log file' do
    it { expect(logfile).to include('[repo.module.ModuleServiceImpl] [localhost-startStop-1] Installing module \'org_alfresco_module_wcmquickstart\'') }
  end
  context command("java -jar #{alfrescoMMT} list #{alfrescoWars}alfresco.war") do
    its(:stdout) { is_expected.to include('Module \'org_alfresco_module_wcmquickstart\' installed') }
  end

  context command("java -jar #{alfrescoMMT} list #{alfrescoWars}share.war") do
    its(:stdout) { is_expected.to include('Module \'org_alfresco_module_wcmquickstartshare\' installed') }
  end

end


describe 'NFS :' do
  context 'when verifying the alfresco global properties file :' do
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
end