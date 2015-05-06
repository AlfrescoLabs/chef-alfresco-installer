name             'alfresco-metal'
maintainer       'YOUR_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures alfresco-metal'
long_description 'Installs/Configures alfresco-metal'
version          '0.1.0'

depends "chef-client"
depends "apt"
suggests "windows"
depends "java-wrapper"
depends "alfresco-chef"
depends "alfresco-dbwrapper"