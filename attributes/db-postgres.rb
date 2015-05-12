
case node['installer.database-type']

when 'postgres'

	case node['installer.database-version']

	when '9.3.5'
		case node['platform_family']
		when 'solaris2'
		#db prop

		default['db.username']='alfresco'
		default['db.password']='admin'
		default['db.name']='alf_solaris'
		default['db.url']='jdbc:postgresql://172.29.100.200:5432/${db.name}'

		else

		default['db.username']='alfresco'
		default['db.password']='admin'
		default['db.name']='alfresco'
		default['db.url']='jdbc:postgresql://localhost:5432/${db.name}'

		end

		default['db.driver']='org.postgresql.Driver'
		default['db.pool.max']='275'
		default['db.pool.validate.query']='SELECT 1'
		default['db.driver.url']='ftp://172.29.101.56/databases/postgresql-9.4-1201-jdbc41.jar'
		default['db.driver.filename']='postgresql-9.4-1201-jdbc41.jar'

	end

end