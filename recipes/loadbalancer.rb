case node['platform_family']
  when 'windows'

    windows_zipfile node['loadbalancer']['unzipFolder'] do
      source node['loadbalancer']['url']
      action :unzip
      not_if { ::File.directory?(node['loadbalancer']['unzipFolder']) }
    end

    directory node['loadbalancer']['unzipFolder'] do
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
    end

    template "#{node['loadbalancer']['rootFolder']}/conf/httpd.conf" do
      source 'httpd-win.erb'
      rights :read, 'Administrator'
      rights :write, 'Administrator'
      rights :full_control, 'Administrator'
      rights :full_control, 'Administrator', :applies_to_children => true
      group 'Administrators'
      :top_level
    end

    batch 'Install httpd service' do
      code <<-EOH
#{node['loadbalancer']['rootFolder']}/bin/httpd.exe -k uninstall
#{node['loadbalancer']['rootFolder']}/bin/httpd.exe -k install
      EOH
      action :run
    end

    service 'Apache2.4' do
      supports :status => true, :restart => true, :stop => true
      action [:start, :enable]
    end

  else


    package 'httpd' do
      action :install
    end

    directory '/resources' do
      owner 'root'
      group 'root'
      mode '0775'
      action :create
    end

    remote_file '/resources/server.crt' do
      source 'ftp://172.29.101.56/tomcat/cert/server.crt'
      owner 'root'
      group 'root'
      mode 00775
      action :create_if_missing
    end

    remote_file '/resources/server.key' do
      source 'ftp://172.29.101.56/tomcat/cert/server.key'
      owner 'root'
      group 'root'
      mode 00775
      action :create_if_missing
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

end