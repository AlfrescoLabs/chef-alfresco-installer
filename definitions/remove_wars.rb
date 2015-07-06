define :remove_wars do

    if !node['install_share_war']
      file 'remove share war' do
        path "#{node['installer']['directory']}/tomcat/webapps/share.war"
        action :delete
      end
    end

    if !node['install_alfresco_war']
      file 'remove alfresco war' do
        path "#{node['installer']['directory']}/tomcat/webapps/alfresco.war"
        action :delete
      end
    end

    if !node['install_solr4_war']
      file 'remove solr4 war' do
        path "#{node['installer']['directory']}/tomcat/webapps/solr4.war"
        action :delete
      end
    end

end
