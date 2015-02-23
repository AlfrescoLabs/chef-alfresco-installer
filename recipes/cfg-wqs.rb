include_recipe 'alfresco-chef::installer'

template '/opt/target/alf-installation/tomcat/shared/classes/wqsapi-custom.properties' do
	source 'wqsapi-custom.properties.erb'
	owner 'root'
	group 'root'
	mode '0644'
	notifies :restart, 'service[alfresco]', :immediately
end