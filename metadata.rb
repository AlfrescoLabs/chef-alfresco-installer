name             'alfresco-chef'
maintainer       'Alfresco'
maintainer_email 'sergiu.vidrascu@ness.com'
license          'All rights reserved'
description      'Installs/Configures alfresco-chef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends "chef-client"
depends "apt"
