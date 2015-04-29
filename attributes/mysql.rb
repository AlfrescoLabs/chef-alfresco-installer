default['mysql']['yum']['version']="5.6.17-4.el6"
default['mysql']['yum']['repository']="http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm"

default['mysql']['install']=true
default['mysql']['createuser']=true
default['mysql']['createdb']=true
default['mysql']['dropdb']=false

default['mysql']['user']="alfresco"
default['mysql']['password']="alfresco"
default['mysql']['dbname']="alfresco"