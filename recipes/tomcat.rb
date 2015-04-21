case node['platform_family']
when 'solaris','solaris2'

  template "/opt/opencsw.sh" do
    source 'opencsw.sh.erb'
    owner 'root'
    group 'root'
    mode 00755
  end

  file "/opt/opencsw.sh" do
  	owner 'root'
	  group 'root'
	  mode 00755
	  action :create
  end

  bash 'Install opencsw' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    expect opencsw.sh
    EOH
    not_if { File.exists?("/opt/csw/bin/pkgutil") }
  end

  package 'gcc-45' do
    action :install
  end

  remote_file "/opt/freetype-2.5.5.tar.gz" do
    source  node["url"]["freetype"]
    owner "root"
    group "root"
    mode 00775
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

remote_file "/opt/jpegsrc.v9.tar.gz" do
    source  node["url"]["jpegsrc"]
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
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

  remote_file "/opt/xpdf-3.04.tar.gz" do
    source  node["url"]["xpdf"]
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
  end

  remote_file "/opt/swftools-0.9.2.tar.gz" do
    source  node["url"]["swftools"]
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
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
    not_if { File.exists?("/usr/local/bin/png2swf") }
  end

  remote_file "/opt/ghostscript.tar.gz" do
    source  node["url"]["ghostscript"]
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
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


  bash 'Install ImageMagick' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    /opt/csw/bin/pkgutil -y -i imagemagick
    EOH
    not_if { File.exists?("/opt/csw/bin/convert") }
  end


  remote_file "/opt/openOffice.tar.gz" do
    source  node["url"]["openOffice"]
   owner "root"
    group "root"
    mode "775"
    action :create_if_missing
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

end

installation_root = node['tomcat']['installation_folder']
tomcat_root = node['tomcat']['tomcat_folder']

  directory "/resources" do
    owner "root"
    group "root"
    mode "0775"
    action :create
  end

  %w[ /opt/target
      /opt/target/alf-installation
      /opt/target/alf-installation/tomcat
     ].each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode 00775
      action :create
    end
  end

  remote_file "/opt/tomcat.tar.gz" do
    source node['tomcat']['download_url']
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
  end

  bash 'unzip tomcat' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf tomcat.tar.gz
    mv #{node['tomcat']['package_name']}/* #{tomcat_root}
    EOH
    not_if { ::File.directory?("#{tomcat_root}/bin") }
  end

  %w[ /opt/target/alf-installation/tomcat/shared
      /opt/target/alf-installation/tomcat/shared/classes
      /opt/target/alf-installation/tomcat/shared/lib
      /opt/target/alf-installation/tomcat/conf/Catalina
      /opt/target/alf-installation/tomcat/conf/Catalina/localhost
     ].each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode 00775
      action :create
    end
  end

  template "#{tomcat_root}/conf/catalina.properties" do
    source 'catalina.properties.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  template "#{tomcat_root}/conf/server.xml" do
    source 'server.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  template "#{tomcat_root}/conf/context.xml" do
    source 'context.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  template "#{tomcat_root}/conf/Catalina/localhost/solr4.xml" do
    source 'solr4.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  template "#{tomcat_root}/conf/tomcat-users.xml" do
    source 'tomcat-users.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

  remote_file node["alfresco"]["local"] do
    source node["alfresco"]["downloadpath"]
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
    sensitive true
  end

  bash 'place alfresco in tomcat folder' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    unzip alfresco.zip
    cp -rf #{node["alfresco"]["zipfolder"]}/* #{installation_root}/
    cp -rf  #{installation_root}/web-server/* #{tomcat_root}/
    rm -rf #{installation_root}/web-server
    EOH
    not_if { File.exists?("#{installation_root}/web-server/shared/classes/alfresco-global.properties.sample") }
  end

  template "#{tomcat_root}/shared/classes/alfresco-global.properties" do
    source 'alfresco-global.properties.erb'
    owner 'root'
    group 'root'
    mode 00755
    :top_level
  end

case node['platform_family']
when 'solaris','solaris2'

  service "application/tomcat" do
    supports :restart => true, :disable => true, :enable => true
    action :nothing
    notifies :run, 'execute[wait for tomcat]', :immediately
  end

  execute 'wait for tomcat' do
    command 'sleep 100'
    action :nothing
  end

  template "#{installation_root}/tomcat.xml" do
    source 'solaris-tomcat-service.xml.erb'
    owner 'root'
    group 'root'
    mode 00755
  end

  execute 'Import solaris tomcat service' do
    user 'root'
    command "svccfg import #{installation_root}/tomcat.xml"
    notifies :restart, 'service[application/tomcat]'
  end

end
