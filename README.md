alfresco-installer Cookbook
======================
This is a cookbook for installing alfresco using multiple deployement schemas and platforms

Currently supported OS's and Alfresco versions:
| Alfresco Version | RHEL 6.1 | RHEL 6.4 | RHEL 6.5 | RHEL 7.1 | WinServer 2008 R2 | WinServer 2012 R2 | Solaris 11.2 | Ubuntu 12.04 | Suse 11.3 | Suse 12 |
|:----------------:|:--------:|:--------:|:--------:|:--------:|:-----------------:|:-----------------:|:------------:|:------------:|:---------:|:-------:|
|        5.1       |          |          |     X    |     X    |                   |                   |              |              |           |         |
|        5.0       |          |          |     X    |          |                   |                   |       X      |       X      |     X     |    X    |
|        4.2       |          |     X    |          |          |         X         |         X         |              |       X      |     X     |         |
|        4.1       |     X    |          |          |          |         X         |                   |              |              |           |         |

Requirements
------------
- java
- apt
- chef-client

Usage
-----
#### alfresco-installer::installer

Adding the alfresco-installer::installer recipe and setting the build location on the node attribute
`default['installer']['downloadpath']` will be sufficient to spin up the installation and configuration of alfresco

If you want to add additional amps to your installation then add additional attributes as follows:
```
# default['amps']['alfresco']['my-amp'] = "https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-rm/2.3.c/alfresco-rm-2.3.c.amp"
# default['amps']['share']['my-share-amp'] = "https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-rm-share/2.3.c/alfresco-rm-share-2.3.c.amp"

```

#### alfresco-installer::loadbalancer

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

#### alfresco-installer::replication_server and replication_client

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
