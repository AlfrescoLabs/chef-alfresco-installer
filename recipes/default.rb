chef_gem 'chef-provisioning-ssh' do
  action :install
  compile_time true
end

if node['single_node']
  include_recipe 'alfresco-provisioning::single_node'
else
  case node['cluster_schema']
  when '2'
    include_recipe 'alfresco-provisioning::schema2'
  when '1'
    include_recipe 'alfresco-provisioning::schema1'
  end
end
