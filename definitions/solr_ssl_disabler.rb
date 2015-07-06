define :solr_ssl_disabler do

  if node['disable_solr_ssl']

    if node['install_alfresco_war']

      bash 'unzip alfresco war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    mkdir /opt/tmp-alfrescowar
    cp #{node['installer']['directory']}/tomcat/webapps/alfresco.war /opt/tmp-alfrescowar/
    cd /opt/tmp-alfrescowar
    jar -xvf alfresco.war
    rm -rf alfresco.war
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
      end

      template 'set web.xml for alfresco.war' do
        source 'web.xml-alfresco.erb'
        path '/opt/tmp-alfrescowar/WEB-INF/web.xml'
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
        only_if { ::File.exist?('/opt/tmp-alfrescowar/WEB-INF/web.xml') }
      end

      template 'set web.xml for alfresco' do
        source 'web.xml-alfresco.erb'
        path "#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml"
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        only_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
      end

      bash 'archive and move alfresco war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    jar -cvf alfresco.war -C tmp-alfrescowar/ .
    cp -rf alfresco.war #{node['installer']['directory']}/tomcat/webapps/
    rm -rf alfresco.war
    rm -rf tmp-alfrescowar
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
      end

    end

    if node['install_solr4_war']

      bash 'unzip solr4 war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    mkdir /opt/tmp-solr4war
    cp #{node['installer']['directory']}/tomcat/webapps/solr4.war /opt/tmp-solr4war/
    cd /opt/tmp-solr4war
    jar -xvf solr4.war
    rm -rf solr4.war
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
      end

      template 'set web.xml for solr4.war' do
        source 'web.xml-solr4.erb'
        path '/opt/tmp-solr4war/WEB-INF/web.xml'
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
        only_if { ::File.exist?('/opt/tmp-solr4war/WEB-INF/web.xml') }
      end

      template 'set web.xml for solr4' do
        source 'web.xml-solr4.erb'
        path "#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml"
        owner 'root'
        group 'root'
        mode 00755
        :top_level
        only_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
      end

      bash 'archive and move alfresco war' do
        user 'root'
        cwd '/opt'
        code <<-EOH
    jar -cvf solr4.war -C tmp-solr4war/ .
    cp -rf solr4.war #{node['installer']['directory']}/tomcat/webapps/
    rm -rf solr4.war
    rm -rf tmp-solr4war
        EOH
        not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
      end

    end
  end
end
