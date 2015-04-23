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
#/
bash 'install package repos' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	rpm -Uvh http://repo.webtatic.com/yum/el6/latest.rpm
	rpm -Uvh http://dl.atrpms.net/all/atrpms-repo-6-7.el6.x86_64.rpm
	rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rm -rf /etc/yum.repos.d/dvd.repo
	EOH
end

%w{gcc readline-devel zlib zlib-devel}.each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "/opt/#{node['url']['package']}.tar.gz" do
    source  node['url']['postgresql']
    owner "root"
    group "root"
    mode 00775
    action :create_if_missing
end

bash 'Install postgres' do
    user 'root'
    cwd '/opt'
    code <<-EOH
    tar xvf #{node['url']['package']}.tar.gz
    cd #{node['url']['package']} && ./configure && make && make install
    PATH=/usr/local/pgsql/bin:$PATH
	export PATH
	adduser postgres
	mkdir /usr/local/pgsql/data
	chown postgres /usr/local/pgsql/data
    EOH
    only_if { node['postgres']['installpostgres'] == true }
end

bash 'Startup postgres' do
	user 'postgres'
	cwd '/tmp'
	code <<-EOH
	/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
	echo "host all all 0.0.0.0/0 trust" >> /usr/local/pgsql/data/pg_hba.conf
	echo "listen_addresses = '*'" >> /usr/local/pgsql/data/postgresql.conf
	/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start 
	sleep 5
	/usr/local/pgsql/bin/createuser #{node['postgres']['user']}
	EOH
	only_if { node['postgres']['installpostgres'] == true }
end

bash 'drop database' do
	user 'postgres'
	cwd '/usr/local/pgsql/bin'
	code <<-EOH
		./psql << EOF
		SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '#{node['postgres']['dbname']}';
		drop database #{node['postgres']['dbname']};
		\\q
		EOF
	EOH
	only_if { node['postgres']['dropdb'] == true }
end

bash 'create database' do
	user 'postgres'
	cwd '/usr/local/pgsql/bin'
	code <<-EOH
		./psql << EOF
		create database #{node['postgres']['dbname']} with encoding='utf-8' owner=#{node['postgres']['user']} connection limit=-1;
		GRANT ALL PRIVILEGES ON DATABASE #{node['postgres']['dbname']} TO #{node['postgres']['user']};
		\\q
		EOF
	EOH
	only_if { node['postgres']['createdb'] == true }
end
