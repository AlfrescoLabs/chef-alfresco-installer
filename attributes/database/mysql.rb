
case node['installer.database-type']

when "mysql"

	case node['installer.database-version']

	when "5.6.17"

	default['db.driver']="org.gjt.mm.mysql.Driver"
	default['db.username']="alfresco"
	default['db.password']="alfresco"
	default['db.name']="alfresco"
	default['db.url']="jdbc:mysql://localhost:3306/${db.name}?useUnicode=yes&characterEncoding=UTF-8"
	default['db.pool.max']="275"
	default['db.driver.url']="ftp://172.29.101.56/databases/mysql-connector-java-5.1.32.jar"
	default['db.driver.filename']="mysql-connector-java-5.1.32.jar"

	end

end