require 'spec_helper'
require_relative '../../spec/helpers'

include Helpers

currentDir=Dir.pwd

propertiesFile = parsePropertiesFile "#{currentDir}/test.properties"


puts "\n Running tests on: \n" + command('ifconfig | grep "inet .*"').stdout

target_host = ENV['checklist_target_host']

serverConnection = getFaradayConnection "http://#{target_host}:8080"
authenticatedServerConnection = getFaradayConnection "http://admin:admin@#{target_host}:8080"

describe 'Alfresco Global Checks:' do

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


String globalPropertiesFile = file(ENV['checklist_target_alf_glob']).content
glProps = parsePropertiesFile globalPropertiesFile

describe 'FTP/FTPS settings:' do

  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).to include("ftp.enabled" => "true") }
    it { expect(glProps).not_to include("ftp.port" => "") }
  end
  context 'when verifying if the Alfresco ftp server responds correctly at the specified port' do
    let(:ftp) { $ftp = Net::FTP.new(host = target_host, user='admin', password='admin', acct=nil) }
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
  context "and the specified port: #{glProps["ftp.port"]}" do
    it { expect(port(glProps['ftp.port'])).to be_listening }
  end
end
# ftp : // admin @ 172.29 .101 .52/Alfresco/Sites/swsdp/documentLibrary/Budget%20 Files/budget.xls

describe 'JBPM settings:' do
  it { expect(glProps).to include('system.workflow.engine.jbpm.enabled' => 'true') }
  it { expect(glProps).to include('system.workflow.engine.jbpm.definitions.visible' => 'true') }
end

logfile = file(ENV['checklist_target_catalina_log']).content

describe 'Cloud license:' do
  it { expect(logfile).to include('[repo.sync.SyncAdminServiceImpl] [localhost-startStop-1] A key is provided for cloud sync') }
end


String cloudUrl = globalPropertiesFile.match(/http.*?(?=a\.alfresco.*)/)
String computedString = "#{cloudUrl}my.alfresco.me/share/"
cloudConnection = getFaradayConnection computedString

describe 'Cloud sync and Hybrid:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).to include('hybridworkflow.enabled' => 'true') }
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
  it { expect(glProps).to include('notification.email.siteinvite' => 'true') }
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
    let(:smtp) { $smtp = Net::SMTP.start(glProps["mail.host"], glProps["mail.port"], glProps["mail.username"],
                                         glProps["mail.username"], glProps["mail.password"], :login) }
    it { expect(smtp.started?).to be true }
    it 'smtp connection can be terminated ' do
      smtp.finish
      expect(smtp.started?).to be false
    end
  end
  context 'when verifying the alfresco log file' do
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'email\' subsystem, ID: [email, outbound] complete') }
  end
end

describe 'Imbound mail:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).to include('email.inbound.enabled' => 'true') }
    it { expect(glProps).not_to include('email.server.allowed.senders' => '') }
    it { expect(glProps).to include('email.server.enabled' => 'true') }
    it { expect(glProps).not_to include('email.server.port' => '') }
    it { expect(glProps).not_to include('email.server.domain' => '') }
    it { expect(glProps).not_to include('email.inbound.unknownUser' => '') }
  end
  context 'when verifying if the Alfresco mail server responds correctly at the specified port' do
    let(:smtp) { $smtp = Net::SMTP.start(target_host, glProps["email.server.port"]) }
    it { expect(smtp.started?).to be true }
    it 'smtp connection can be terminated ' do
      smtp.finish
      expect(smtp.started?).to be false
    end
  end
  context 'when verifying the alfresco log file' do
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'email\' subsystem, ID: [email, inbound] complete') }
  end
end

describe 'IMAP:' do
  context 'when verifying the alfresco global properties file' do
    it { expect(glProps).to include('imap.server.enabled' => 'true') }
    it { expect(glProps).not_to include('imap.server.host' => '') }
    it { expect(glProps).not_to include('imap.server.port' => '') }
  end
  context 'when verifying if the Alfresco mail server responds correctly at the specified port' do
    it 'can connect to imap server' do
      expect(imap = Net::IMAP.new(target_host))
    end
    it 'can login as admin/admin' do
      expect(imap.login('admin', 'admin')[3]).to include('LOGIN completed.')
    end
    it 'can list the folders for the imap server' do
      expect(imap.list('', 'Alfresco IMAP/Sites')[0]).to include('Alfresco IMAP/Sites')
    end
    it 'connection can be terminated ' do
      imap.disconnect
      expect(imap.disconnected?).to be true
    end
  end
  context 'when verifying the alfresco log file' do
    it { expect(logfile).to include("[repo.imap.AlfrescoImapServer] [localhost-startStop-1] IMAP service started on host:port #{glProps["imap.server.host"]}:#{glProps["imap.server.port"]}") }
    it { expect(logfile).to include('[management.subsystems.ChildApplicationContextFactory] [localhost-startStop-1] Startup of \'imap\' subsystem, ID: [imap, default] complete') }
  end
end

describe 'Replication settings:' do
  it { expect(glProps).to include('replication.enabled' => 'true') }
  it { expect(glProps).to include('transferservice.receiver.enabled' => 'true') }
end

describe 'Transformation Services:' do

  html = Nokogiri::HTML(authenticatedServerConnection.get('/alfresco/s/enterprise/admin/admin-transformations').body)

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
        expect(html.xpath('.//span[text()="ImageMagick Available:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
      end
      it 'imagemagick version is displayed' do
        expect(html.xpath('.//div[@class="control field"]//span[contains(text(),"ImageMagick")]')[0]).not_to be_nil
      end
    end
  end

  describe 'office transformation tools:' do

    it 'jod converter and office should not be enabled or disabled at the same time' do
      expect(glProps["jodconverter.enabled"]).not_to equal(glProps["ooo.enabled"])
    end

    if glProps["jodconverter.enabled"] == 'true'

      describe 'JodConvertor:' do

        context 'when verifying the alfresco global properties file' do
          it { expect(glProps).not_to include('jodconverter.officeHome' => '') }
          it { expect(glProps).to include('jodconverter.enabled' => 'true') }
          it { expect(glProps).not_to include('jodconverter.portNumbers' => '') }
        end

        it "port specified: #{glProps["jodconverter.portNumbers"]}" do
          expect(port(glProps["jodconverter.portNumbers"])).to be_listening
        end

        context 'when verifying the admin console' do
          it 'JodConverter should be enabled' do
            expect(html.xpath('.//span[text()="JODConverter Enabled:"]/..//input[@checked="checked"]')[0]).not_to be_nil
          end
        end
      end

    else

      describe 'OpenOffice:' do

        context 'when verifying the alfresco global properties file' do
          it { expect(glProps).not_to include('jodconverter.officeHome' => '') }
          it { expect(glProps).to include('jodconverter.enabled' => 'true') }
          it { expect(glProps).not_to include('jodconverter.portNumbers' => '') }
        end

        it "port specified: #{glProps["jodconverter.portNumbers"]}" do
          expect(port(glProps["jodconverter.portNumbers"])).to be_listening
        end

        # context 'when verifying the admin console' do
        #   it 'imagemagick should be enabled' do
        #     expect(html.xpath('.//span[text()="ImageMagick Available:"]/..//span[text()="Enabled"]')[0]).not_to be_nil
        #   end
        #   it 'imagemagick version is displayed' do
        #     expect(html.xpath('.//div[@class="control field"]//span[contains(text(),"ImageMagick")]')[0]).not_to be_nil
        #   end
        # end
      end
    end

  end

end