case node['platform_family']
when 'solaris','solaris2'

  creds = Chef::EncryptedDataBagItem.load("bamboo", "pass")
  creds["pass"] # will be decrypted

  %w[ /opt/target
      /opt/target/alf-installation
      /opt/target/alf-installation/tomcat
      /opt/target/alf-installation/tomcat/shared
      /opt/target/alf-installation/tomcat/shared/classes
      /opt/target/alf-installation/tomcat/shared/lib 
     ].each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode '0775'
      action :create
    end
  end

  remote_file "/opt/tomcat.tar.gz" do
    source node['tomcat']['download_url']
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
  end

  bash 'unzip tomcat' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf tomcat.tar.gz
    mv #{node['tomcat']['package_name']}/* #{node['tomcat']['tomcat_folder']}
    EOH
    creates "#{node['tomcat']['tomcat_folder']}/conf/catalina.properties"
  end

  template "#{node['tomcat']['tomcat_folder']}/conf/catalina.properties" do
    source 'catalina.properties.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  template "#{node['tomcat']['tomcat_folder']}/conf/server.xml" do
    source 'server.xml.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  template "#{node['tomcat']['tomcat_folder']}/conf/context.xml" do
    source 'context.xml.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  package 'gcc' do
    action :install
  end

  remote_file "/opt/ghostscript.tar.gz" do
    source  "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node["url"]["ghostscript"]}"
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  bash 'Install ghostscript' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf ghostscript.tar.gz
    cd ghostscript-9.15
    ./configure --without-gnu-make && make && make install
    EOH
    creates "/opt/ghostscript-9.15"
  end

  remote_file "/opt/ImageMagick.tar.gz" do
    source  "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node["url"]["imagemagick"]}"
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  bash 'Install ImageMagick' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf ImageMagick.tar.gz
    cd ImageMagick-6.9.0-10
    ./configure && make && make install
    EOH
    creates "/opt/ImageMagick-6.9.0-10"
  end

  remote_file "/opt/openOffice.tar.gz" do
    source  "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node["url"]["openOffice"]}"
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  directory "/opt/openOffice" do
    owner "root"
    group "root"
    mode "0775"
    action :create
  end

  bash 'Install openOffice' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf openOffice.tar.gz
    mv Apache_OpenOffice_incubating_3.4.0_Solaris_x86_install-arc_en-US openOffice
    EOH
    creates "/opt/openOffice/openoffice.org3"
  end

  remote_file node["alfresco"]["local"] do
    source "ftp://#{creds['bamboo_username']}:#{creds['bamboo_password']}@ftp.alfresco.com/#{node["alfresco"]["downloadpath"]}"
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

bash 'place alfresco in tomcat folder' do
  user 'root'
  cwd '/opt'
  code <<-EOH
  tar xvf alfresco.zip
  mv #{node["alfresco"]["zipfolder"]}/* #{node['tomcat']['installation_folder']}/
  mv #{node['tomcat']['installation_folder']}/web-server/* #{node['tomcat']['tomcat_folder']}/
  rm -rf #{node['tomcat']['installation_folder']}/web-server
  EOH
end

  package 'postgresql' do
    action :install
  end


end
