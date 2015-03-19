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
    not_if { ::File.directory?(node['tomcat']['tomcat_folder']) }
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

  package 'gcc-45' do
    action :install
  end

  remote_file "/opt/freetype-2.5.5.tar.gz" do
    source  node["url"]["freetype"]
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  bash 'Install freetype' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf freetype-2.5.5.tar.gz
    cd freetype-2.5.5 && ./configure && gmake && gmake install
    EOH
    not_if { File.exists?("/usr/local/bin/freetype-config") }
  end


  remote_file "giflib" do
    source  node["url"]["giflib"]
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

    bash 'Install giflib' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf giflib
    cd giflib-5.1.1 && ./configure && gmake && gmake install
    EOH
    not_if { File.exists?("/usr/local/bin/giftool") }
  end
  

remote_file "jpegsrc.v9.tar.gz" do
    source  node["url"]["jpegsrc"]
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

bash 'Install jpegsrc' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf jpegsrc.v9.tar.gz
    cd jpeg-9 && ./configure && gmake && gmake install
    EOH
    not_if { File.exists?("/usr/local/bin/jpeg2swf") }
  end

  remote_file "xpdf-3.04.tar.gz" do
    source  node["url"]["xpdf"]
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  remote_file "swftools-0.9.2.tar.gz" do
    source  node["url"]["xpdf"]
    owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  bash 'Install swftools' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf swftools-0.9.2.tar.gz
    cp xpdf-3.04.tar.gz swftools-0.9.2/lib/pdf
    crle -u -l /usr/local/lib
    cd swftools-0.9.2 && ./configure && gmake && gmake install
    EOH
    returns [0,2]
    not_if { File.exists?("/usr/local/bin/png2swf") }
  end

  remote_file "/opt/ghostscript.tar.gz" do
    source  node["url"]["ghostscript"]
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
    not_if { File.exists?("/usr/local/bin/gs") }
  end

  remote_file "/opt/ImageMagick.tar.gz" do
    source  node["url"]["imagemagick"]
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
    not_if { ::File.directory?("/opt/ImageMagick-6.9.0-10") }
  end

  remote_file "/opt/openOffice.tar.gz" do
    source  node["url"]["openOffice"]
   owner "root"
    group "root"
    mode "775"
    action :create_if_missing
    sensitive true
  end

  bash 'Install openOffice' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf openOffice.tar.gz
    mv Apache_OpenOffice_incubating_3.4.0_Solaris_x86_install-arc_en-US openOffice
    chmod -R 700 openOffice
    EOH
    not_if { File.exists?("/opt/openOffice/openoffice.org3/program/soffice") }
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
  unzip alfresco.zip
  cp -rf #{node["alfresco"]["zipfolder"]}/* #{node['tomcat']['installation_folder']}/
  cp -rf  #{node['tomcat']['installation_folder']}/web-server/* #{node['tomcat']['tomcat_folder']}/
  rm -rf #{node['tomcat']['installation_folder']}/web-server
  EOH
  not_if { File.exists?("#{node['tomcat']['installation_folder']}/web-server/shared/classes/alfresco-global.properties.sample") }
end

  template node["alfresco-global"]["directory"] do
    source 'alfresco-global.properties.erb'
    owner 'root'
    group 'root'
    mode '0755'
    :top_level
  end

end
