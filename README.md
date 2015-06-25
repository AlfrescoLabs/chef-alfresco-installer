Servers spec tests to validate alfresco installations
======================

Setup your test target machine in the test.properties file
along with the other properties as required


USAGE
-----

Set the following env variables:
checklist_target_password
checklist_target_host
checklist_target_sudo_pass 
checklist_target_user 
checklist_target_alf_glob => example: /opt/alf-installation/tomcat/shared/classes/alfresco-global.properties
checklist_target_catalina_log => example: /opt/alf-installation/tomcat/logs/catalina.out
checklist_target_alfresco_mmt => example: /opt/alf-installation/bin/alfresco-mmt.jar
checklist_target_alfresco_wars => example: /opt/alf-installation/tomcat/webapps/

execute with rspec spec
or just default rake

Autogenerates a serverspec.xml junit report file.

License and Authors
-------------------
Authors: Sergiu Vidrascu (vsergiu@hotmail.com)