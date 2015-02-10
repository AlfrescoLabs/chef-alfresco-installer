name             'alfresco_java'
maintainer       'Sergiu Vidrascu'
maintainer_email 'sergiu.vidrascu@ness.com'
license          'All rights reserved'
description      'Installs/Configures alfresco_java'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "java"

echo "# alfresco_java" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/AlfrescoTestAutomation/alfresco_main.git
git push -u origin master