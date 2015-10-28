gem_package 'chef-provisioning-ssh' do
  action :remove
end

if node['singleNode']
  include_recipe "alfresco-provisioning::singleNode"
else
  case node['clusterSchema']
  when '2'
    include_recipe "alfresco-provisioning::schema2"
  when '1'
    include_recipe "alfresco-provisioning::schema1"
  end
end
