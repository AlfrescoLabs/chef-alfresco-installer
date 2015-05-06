package 'httpd' do
  action :install
end

template '/etc/httpd/conf/httpd.conf' do
  source 'httpd.conf.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'httpd' do
  supports :status => true, :restart => true, :stop => true
  action [:start, :enable]
end
