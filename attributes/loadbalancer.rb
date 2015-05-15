default['lb']['ips_and_nodenames'] = [{:ip=> '172.29.101.97', :nodename=> 'alf1'},{:ip=> '172.29.101.99', :nodename=> 'alf2'}]

default['loadbalancer']['url'] = 'ftp://172.29.101.56/tomcat/httpd2412win64.zip'
default['loadbalancer']['rootFolder'] = 'c:/httpd/httpd2412win64'
default['loadbalancer']['unzipFolder'] = 'c:/httpd'