#
# Copyright (C) 2005-2015 Alfresco Software Limited.
#
# This file is part of Alfresco
#
# Alfresco is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Alfresco is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Alfresco. If not, see <http://www.gnu.org/licenses/>.
#


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
      source 'loadBalancer/httpd-win.erb'
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

    template '/etc/httpd/conf/httpd.conf' do
      if node['platform_version'] == "7.1"
        source 'loadBalancer/httpd24.conf.erb'
      else
        source 'loadBalancer/httpd.conf.erb'
      end
      owner 'root'
      group 'root'
      mode '0755'
    end

    service 'httpd' do
      supports :status => true, :restart => true, :stop => true
      action [:start, :enable]
    end

end
