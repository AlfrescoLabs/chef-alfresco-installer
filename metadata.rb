name 'alfresco-installer'
maintainer 'Alfresco'
maintainer_email 'sergiu.vidrascu@ness.com'
license '2005-2015 Alfresco Software Limited'
description 'Installs/Configures alfresco-chef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.1.4'

depends 'chef-client', '~> 4.3.0'
depends 'apt', '~> 2.7.0'
depends 'line', '~> 0.6.2'
depends 'windows', '~> 1.39.1'
depends 'nfs', '~> 2.2.5'
