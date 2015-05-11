name             'alfresco-metal'
maintainer       'Sergiu Vidrascu'
maintainer_email 'sergiu.vidrascu@ness.com'
license          'All rights reserved'
description      'Installs/Configures alfresco in cluster using chef-provisioning'
version          '0.1.0'

depends "chef-client"
depends "apt"
suggests "windows"
depends "java-wrapper"
depends "alfresco-chef"
depends "alfresco-dbwrapper"