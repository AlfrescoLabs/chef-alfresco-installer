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
remote_file '/opt/oracle1.zip' do
  owner 'root'
  group 'root'
  mode '0644'
  source node['url']['oracle1']
  not_if { File.exists?("/opt/oracle1.zip") }
end

remote_file '/opt/oracle2.zip' do
  owner 'root'
  group 'root'
  mode '0644'
  source node['url']['oracle2']
  not_if { File.exists?("/opt/oracle2.zip") }
end

bash 'Unzip Oracle' do
	user 'root'
	cwd '/opt'
	code <<-EOH
	unzip oracle1.zip
	unzip oracle2.zip
	EOH
	not_if { ::File.directory?("/opt/database") }
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
	 /usr/sbin/groupadd oinstall
	 /usr/sbin/groupadd dba
	 /usr/sbin/groupadd oper
	 /usr/sbin/groupadd backupdba
	 /usr/sbin/useradd -d /export/home/oracle -m -s /bin/bash -g oinstall -G dba,oper,backupdba,oinstall oracle
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

directory '/opt/oracle/app/oracle/product/12.1.0.2/db_1' do
	owner 'oracle'
	group 'oinstall'
	mode '0775'
	action :create
	recursive true
end

directory '/opt/oracle/app/oraInventory' do
	owner 'oracle'
	group 'oinstall'
	mode '0775'
	action :create
	recursive true
end

bash 'set project settings' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	prctl -n project.max-shm-memory -v 3gb -r -i project default
	prctl -n project.max-sem-ids -v 256 -r -i project default
	projmod -sK "project.max-shm-memory=(privileged,3G,deny)" default
	projmod -sK "project.max-sem-ids=(privileged,256,deny)" default
	EOH
	not_if 'cat /etc/project | grep default:3::::project.max-sem-ids | grep privileged,256,deny | grep project.max-shm-memory | grep privileged,3221225472,deny'
end

bash 'set tcp udp settings' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	chown -R oracle:oinstall /opt/oracle
	chmod -R 775 /opt/oracle
	chown -R oracle:oinstall /opt/database
	chmod -R 775 /opt/database
	ipadm set-prop -p smallest_anon_port=9000 tcp
	ipadm set-prop -p largest_anon_port=65500 tcp
	ipadm set-prop -p smallest_anon_port=9000 udp
	ipadm set-prop -p largest_anon_port=65500 udp
	EOH
end

file '/opt/database/db_install.rsp' do
	owner 'oracle'
	group 'oinstall'
	mode '0775'
	content "oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.1.0
oracle.install.option=INSTALL_DB_AND_CONFIG
ORACLE_HOSTNAME=#{node['fqdn']}
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/opt/oracle/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/opt/oracle/app/oracle/product/12.1.0.2/db_1
ORACLE_BASE=/opt/oracle/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
oracle.install.db.BACKUPDBA_GROUP=dba
oracle.install.db.DGDBA_GROUP=dba
oracle.install.db.KMDBA_GROUP=dba
oracle.install.db.isRACOneInstall=false
oracle.install.db.rac.serverpoolCardinality=0
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=alfresco
oracle.install.db.config.starterdb.SID=alfresco
oracle.install.db.ConfigureAsContainerDB=false
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=4000
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.password.ALL=alfresco
oracle.install.db.config.starterdb.managementOption=DEFAULT
oracle.install.db.config.starterdb.omsPort=0
oracle.install.db.config.starterdb.enableRecovery=false
oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/opt/oracle/app/oracle/oradata
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true"
	end

execute 'Run oracle installer' do
	user 'root'
	cwd '/opt/database'
	command "su oracle -c 'ulimit -n 65536 && ulimit -s 32768 && ./runInstaller -showProgress -silent -waitforcompletion -ignoreSysPrereqs -responseFile /opt/database/db_install.rsp'"
	returns 6
end

bash 'postinstall scripts' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	/opt/oracle/app/oraInventory/orainstRoot.sh
	/opt/oracle/app/oracle/product/12.1.0.2/db_1/root.sh
	export ORACLE_HOSTNAME=#{node['fqdn']}
	export ORACLE_UNQNAME=alfresco
	export ORACLE_BASE=/opt/oracle/app/oracle
	export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1
	export ORACLE_SID=alfresco
	export PATH=$ORACLE_HOME/bin:$PATH
	lsnrctl start
	EOH
end

bash 'Create default alfresco database' do
	user 'oracle'
	cwd '/opt/oracle/app/oracle/product/12.1.0.2/db_1/bin'
	code <<-EOH 
	prctl -n project.max-shm-memory -v 3gb -r -i project default
	prctl -n project.max-sem-ids -v 256 -r -i project default
	export ORACLE_HOSTNAME=solaris112
	export ORACLE_UNQNAME=alfresco
	export ORACLE_BASE=/opt/oracle/app/oracle
	export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1
	export ORACLE_SID=alfresco
	export PATH=$ORACLE_HOME/bin:$PATH
	su oracle -c './dbca \
	-silent \
	-createDatabase \
	-templateName General_Purpose.dbc \
	-gdbName alfresco \
	-adminManaged \
	-sysPassword alfresco \
	-systemPassword alfresco \
	-emConfiguration NONE \
	-datafileDestination /opt/oracle/app/oracle/oradata \
	-characterSet AL32UTF8 \
	-totalMemory 1024'
	EOH
end


