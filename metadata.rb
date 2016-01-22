name 'alfresco-dbwrapper'
maintainer 'Alfresco'
maintainer_email 'sergiu.vidrascu@ness.com'
license '2005-2015 Alfresco Software Limited'
description 'Installs/Configures databases for alfresco'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.1'

depends 'line', '~> 0.6.2'
supports 'windows'
depends 'openssl'
depends 'windows', '>= 1.2.6'
depends 'yum'
