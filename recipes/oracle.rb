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

environment_setup = {'ORACLE_UNQNAME'=> 'alfresco',
			'ORACLE_BASE'=>node['oracle']['base'],
			'ORACLE_HOME'=>node['oracle']['home'],
			'ORACLE_SID'=> 'alfresco',
			'PATH'=>"#{node['oracle']['home']}/bin:#{ENV['PATH']}"}

remote_file '/opt/oracle1.zip' do
  owner 'root'
  group 'root'
  mode '0644'
  source node['url']['oracle1']
  :create_if_missing
end

remote_file '/opt/oracle2.zip' do
  owner 'root'
  group 'root'
  mode '0644'
  source node['url']['oracle2']
  :create_if_missing
end

bash 'Unzip Oracle' do
	user 'root'
	cwd '/opt'
	code <<-EOH
	unzip oracle1.zip
	unzip oracle2.zip
	EOH
	not_if { ::File.directory?(node['oracle']['downloaddir']) }
end

package 'pkg://solaris/x11/diagnostic/x11-info-clients' do
	action :install
end

file '/opt/setOraclePass.sh' do
	owner 'root'
	group 'root'
	mode '0644'
	content "
	set prompt1 oracle1
	set prompt2 oracle1
	spawn passwd -r files oracle
	expect \"New Password:\"
	send \"$prompt1\\r\"
	expect \"Re-enter new Password:\"
	send \"$prompt2\\r\"
	expect \"successfully\"
	"
	end

bash 'Setup Oracle Groups and Users' do
	user 'root'
	cwd '/opt'
	code <<-EOH
	 groupadd oinstall
	 groupadd dba
	 groupadd oper
	 groupadd backupdba
	 useradd -d /export/home/oracle -m -s /bin/bash -g dba -G dba,oper,backupdba,oinstall oracle
	 expect setOraclePass.sh
	EOH
	not_if 'id -a oracle'
end

bash 'set oracle pass' do
	user 'root'
	cwd '/opt'
	code <<-EOH
	expect setOraclePass.sh
	EOH
end

directory node['oracle']['home'] do
	owner 'oracle'
	group 'dba'
	mode '0775'
	action :create
	recursive true
end

directory node['oracle']['inventory'] do
	owner 'oracle'
	group 'dba'
	mode '0775'
	action :create
	recursive true
end

bash 'Set project, swap, folder and network settings' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	swap -d /dev/zvol/dsk/rpool/swap
	zfs set volsize=4G rpool/swap
	swap -a /dev/zvol/dsk/rpool/swap
	projadd -U oracle -K "project.max-shm-memory=(priv,4G,deny);project.max-sem-ids=(priv,256,deny)" user.oracle
	usermod -K project=user.oracle oracle
	chown -R oracle:dba #{node['oracle']['installdir']}
	chmod -R 775 #{node['oracle']['installdir']}
	chown -R oracle:dba #{node['oracle']['downloaddir']}
	chmod -R 775 #{node['oracle']['downloaddir']}
	ipadm set-prop -p smallest_anon_port=9000 tcp
	ipadm set-prop -p largest_anon_port=65500 tcp
	ipadm set-prop -p smallest_anon_port=9000 udp
	ipadm set-prop -p largest_anon_port=65500 udp
	EOH
	not_if 'cat /etc/project | grep default:3::::project.max-sem-ids | grep priv,256,deny | grep project.max-shm-memory'
end

file "#{node['oracle']['downloaddir']}/db_install.rsp" do
	owner 'oracle'
	group 'oinstall'
	mode '0775'
	content "oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.1.0
oracle.install.option=INSTALL_DB_AND_CONFIG
ORACLE_HOSTNAME=#{node['fqdn']}
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=#{node['oracle']['inventory']}
SELECTED_LANGUAGES=en
ORACLE_HOME=#{node['oracle']['home']}
ORACLE_BASE=#{node['oracle']['base']}
oracle.install.db.InstallEdition=EE
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
oracle.install.db.BACKUPDBA_GROUP=dba
oracle.install.db.DGDBA_GROUP=dba
oracle.install.db.KMDBA_GROUP=dba
oracle.install.db.isRACOneInstall=false
oracle.install.db.rac.serverpoolCardinality=0
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=#{node['oracle']['dbname']}
oracle.install.db.config.starterdb.SID=#{node['oracle']['SID']}
oracle.install.db.ConfigureAsContainerDB=false
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=4000
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.password.ALL=#{node['oracle']['password']}
oracle.install.db.config.starterdb.managementOption=DEFAULT
oracle.install.db.config.starterdb.omsPort=0
oracle.install.db.config.starterdb.enableRecovery=false
oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=#{node['oracle']['base']}/oradata
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true"
	only_if { node['oracle']['installoracle']}
	end

execute 'Run oracle installer' do
	user 'root'
	cwd node['oracle']['downloaddir']
	command "su oracle -c 'ulimit -n 65536 && ulimit -s 32768 && ./runInstaller -showProgress -silent -waitforcompletion -ignoreSysPrereqs -responseFile #{node['oracle']['downloaddir']}/db_install.rsp'"
	returns 6
	only_if { node['oracle']['installoracle'] }
	not_if { File.exists?("#{node['oracle']['home']}/bin/sqlplus") }
end

bash 'postinstall scripts' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	#{node['oracle']['inventory']}/orainstRoot.sh
	#{node['oracle']['home']}/root.sh
	su oracle -c '#{node['oracle']['home']}/cfgtoollogs/configToolAllCommands'
	echo "export ORACLE_HOSTNAME=solaris112
export ORACLE_UNQNAME=#{node['oracle']['dbname']}
export ORACLE_BASE=#{node['oracle']['base']}
export ORACLE_HOME=#{node['oracle']['home']}
export ORACLE_SID=#{node['oracle']['SID']}
export PATH=#{node['oracle']['home']}/bin:$PATH" >> /root/.profile
	echo "export ORACLE_HOSTNAME=solaris112
export ORACLE_UNQNAME=#{node['oracle']['dbname']}
export ORACLE_BASE=#{node['oracle']['base']}
export ORACLE_HOME=#{node['oracle']['home']}
export ORACLE_SID=#{node['oracle']['SID']}
export PATH=#{node['oracle']['home']}/bin:$PATH" >> /export/home/oracle/.profile
	EOH
	not_if 'cat /root/.profile | grep ORACLE_HOME'
	not_if 'cat /export/home/oracle/.profile | grep ORACLE_HOME'
	only_if { node['oracle']['installoracle']}
end

bash 'Create default alfresco database' do
	user 'root'
	cwd "#{node['oracle']['home']}/bin"
	code <<-EOH
	su oracle -c './dbca \
	-silent \
	-createDatabase \
	-templateName General_Purpose.dbc \
	-gdbName #{node['oracle']['dbname']} \
	-adminManaged \
	-sysPassword #{node['oracle']['password']} \
	-systemPassword #{node['oracle']['password']} \
	-emConfiguration NONE \
	-datafileDestination #{node['oracle']['base']}/oradata \
	-characterSet AL32UTF8 \
	-totalMemory 1024'
	EOH
	environment (environment_setup)
	notifies :run, 'execute[Restart the database]', :immediately
	only_if { node['oracle']['installoracle'] }
	not_if { ::File.directory?("#{node['oracle']['base']}/oradata/alfresco") }
end

execute 'Stop the database' do
	user 'oracle'
	cwd "#{node['oracle']['home']}/bin"
	command 'lsnrctl stop'
	not_if 'lsnrctl status'
	action :nothing
	environment (environment_setup)
end


execute 'Start the database' do
	user 'oracle'
	cwd "#{node['oracle']['home']}/bin"
	command 'ulimit -n 65536 && ulimit -s 32768 && lsnrctl start && sleep 50'
	action :nothing
	environment (environment_setup)
end

execute 'Restart the database' do
	user 'oracle'
	cwd "#{node['oracle']['home']}/bin"
	command 'ulimit -n 65536 && ulimit -s 32768 && lsnrctl stop && sleep 2 && lsnrctl start && sleep 50'
	action :nothing
	environment (environment_setup)
end

bash 'Create new schema' do
	user 'oracle'
	cwd '/tmp'
	code <<-EOH
	sqlplus system/admin <<!
	create user #{node['oracle']['schema']['user']} identified by #{node['oracle']['schema']['password']};
	GRANT create session TO #{node['oracle']['schema']['user']};
	GRANT create table TO #{node['oracle']['schema']['user']};
	GRANT create view TO #{node['oracle']['schema']['user']};
	GRANT create any trigger TO #{node['oracle']['schema']['user']};
	GRANT create any procedure TO #{node['oracle']['schema']['user']};
	GRANT create sequence TO #{node['oracle']['schema']['user']};
	GRANT create synonym TO #{node['oracle']['schema']['user']};
	grant connect to #{node['oracle']['schema']['user']};
	grant resource to #{node['oracle']['schema']['user']};
	alter user #{node['oracle']['schema']['user']} quota unlimited on USERS;
	exit
	!
	EOH
	environment (environment_setup)
	only_if { node['oracle']['createschema'] }
end

bash 'Drop existent schema' do
	user 'oracle'
	cwd '/tmp'
	code <<-EOH
	sqlplus /nolog << EOF
	connect /as sysdba
	drop user #{node['oracle']['schema']['user']} cascade;
	quit
	EOF
	EOH
	environment (environment_setup)
	only_if { node['oracle']['dropschema'] }
end