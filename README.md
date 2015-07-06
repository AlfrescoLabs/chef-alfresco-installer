chef-alfresco-installer Cookbook
======================
This is a cookbook for installing alfresco using multiple deployement schemas and platforms

Currently supported OSes:
- Rhel 6.5
- Win 2012 r2 server
- Suse 12
- Solaris 11.2
- Ubuntu 12 Server

Supported Alfresco versions:
- 5.0.x

Requirements
------------
- java
- apt
- chef-client

Usage
-----
#### chef-alfresco-installer::installer

Adding the chef-alfresco-installer::installer recipe and setting the build location on the node attribute
`default['installer']['downloadpath']` will be sufficient to spin up the installation and configuration of alfresco

#### chef-alfresco-installer::loadbalancer

Installs an Apache Load balancer on:
- windows 2012 server
- redhat 6.5
 
Will balance the nodes given in the attribute
```
default['lb']['ips_and_nodenames'] = [
 {:ip=> '172.29.101.97', :nodename=> 'alf1'},
 {:ip=> '172.29.101.99', :nodename=> 'alf2'}
]
```

#### chef-alfresco-installer::replication_server and replication_client

This will setup nfs server and client components
- windows 2012 server
- redhat 6.5

just set these attributes on the client
```
default['replication_remote_ip']='ipaddress of the nfs server' 
default['replication.enabled']='true'
```

and these attributes on server
```
default['replication.enabled']='true'
```

License and Authors
-------------------
Authors: Sergiu Vidrascu (vsergiu@hotmail.com)
