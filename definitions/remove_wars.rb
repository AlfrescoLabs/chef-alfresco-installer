define :remove_wars do

      file 'remove share war' do
        path "#{node['installer']['directory']}/tomcat/webapps/share.war"
        action :delete
        only_if { node['install_share_war'] == false }
      end

      file 'remove alfresco war' do
        path "#{node['installer']['directory']}/tomcat/webapps/alfresco.war"
        action :delete
        only_if { node['install_alfresco_war'] == false }
      end

      file 'remove solr4 war' do
        path "#{node['installer']['directory']}/tomcat/webapps/solr4.war"
        action :delete
        only_if { node['install_solr4_war'] == false }
      end

end
