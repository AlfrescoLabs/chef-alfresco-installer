module AlfrescoHelpers
  # Used for properly handling remote_file downloads on any os
  class AlfRemoteFile < Chef::Resource
    resource_name :alfRemoteFile

    property :path, String, name_property: true
    property :source_url, String
    property :win_user, String
    property :win_group, String
    property :unix_user, String
    property :unix_group, String

    action :create do
      remote_file path do
        source source_url
        case node['platform_family']
        when 'windows'
          rights :read, win_user
          rights :write, win_user
          rights :full_control, win_user
          rights :full_control, win_user, applies_to_children: true
          group win_group
        else
          owner unix_user
          group unix_group
          mode 00755
        end
        action :create_if_missing
      end
    end
  end

  # Used for properly handling template creation on any os
  class AlfTemplate < Chef::Resource
    resource_name :alfTemplate

    property :path, String, name_property: true
    property :source_url, String
    property :win_user, String
    property :win_group, String
    property :unix_user, String
    property :unix_group, String

    action :create do
      template path do
        source source_url
        case node['platform_family']
        when 'windows'
          rights :read, win_user
          rights :write, win_user
          rights :full_control, win_user
          rights :full_control, win_user, applies_to_children: true
          group win_group
          :top_level
        else
          owner unix_user
          group unix_group
          mode 00755
          :top_level
        end
      end
    end
  end

  # Used for removing unnecesarry war files from installation
  class RemoveWars < Chef::Resource
    resource_name :remove_wars

    action :remove do
      file 'remove share war' do
        path "#{node['installer']['directory']}/tomcat/webapps/share.war"
        action :delete
        only_if { node['install_share_war'] == false }
      end
      file 'remove alfresco war' do
        path "#{node['installer']['directory']}/tomcat/webapps/alfresco.war"
        action :delete
        only_if { node['install_alfresco_war'] == false }
      end
      file 'remove solr4 war' do
        path "#{node['installer']['directory']}/tomcat/webapps/solr4.war"
        action :delete
        only_if { node['install_solr4_war'] == false }
      end
    end
  end

  # Used for disabling ssl on solr
  class SolrSSLDisabler < Chef::Resource # rubocop:disable ClassLength
    resource_name :solr_ssl_disabler

    property :win_user, String
    property :win_group, String
    property :unix_user, String
    property :unix_group, String

    action :disable do
      if node['disable_solr_ssl']

        directory node['installer']['directory'] do
          case node['platform_family']
          when 'windows'
            rights :read, win_user
            rights :write, win_user
            rights :full_control, win_user
            rights :full_control, win_user, applies_to_children: true
            group win_group
          else
            owner unix_user
            group unix_group
            mode 00775
          end
        end

        if node['install_alfresco_war']

          bash 'unzip alfresco war' do
            case node['platform_family']
            when 'windows'
              user win_user
            else
              user unix_user
            end
            cwd '/opt'
            code <<-EOH
      mkdir /opt/tmp-alfrescowar
      cp #{node['installer']['directory']}/tomcat/webapps/alfresco.war /opt/tmp-alfrescowar/
      cd /opt/tmp-alfrescowar
      jar -xvf alfresco.war
      rm -rf alfresco.war
          EOH
            not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
          end

          template 'set web.xml for alfresco.war' do
            source 'globalProps/web.xml-alfresco.erb'
            path '/opt/tmp-alfrescowar/WEB-INF/web.xml'
            case node['platform_family']
            when 'windows'
              user win_user
              group win_group
            else
              user unix_user
              group unix_group
            end
            mode 00755
            not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
            only_if { ::File.exist?('/opt/tmp-alfrescowar/WEB-INF/web.xml') }
          end

          template 'set web.xml for alfresco' do
            source 'globalProps/web.xml-alfresco.erb'
            path "#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml"
            case node['platform_family']
            when 'windows'
              user win_user
              group win_group
            else
              user unix_user
              group unix_group
            end
            mode 00755
            only_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
          end

          bash 'archive and move alfresco war' do
            case node['platform_family']
            when 'windows'
              user win_user
            else
              user unix_user
            end
            cwd '/opt'
            code <<-EOH
      jar -cvf alfresco.war -C tmp-alfrescowar/ .
      cp -rf alfresco.war #{node['installer']['directory']}/tomcat/webapps/
      rm -rf alfresco.war
      rm -rf tmp-alfrescowar
          EOH
            not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/alfresco/WEB-INF/web.xml") }
          end
        end

        if node['install_solr4_war']

          bash 'unzip solr4 war' do
            case node['platform_family']
            when 'windows'
              user win_user
            else
              user unix_user
            end
            cwd '/opt'
            code <<-EOH
      mkdir /opt/tmp-solr4war
      cp #{node['installer']['directory']}/tomcat/webapps/solr4.war /opt/tmp-solr4war/
      cd /opt/tmp-solr4war
      jar -xvf solr4.war
      rm -rf solr4.war
          EOH
            not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
          end

          template 'set web.xml for solr4.war' do
            source 'solr/web.xml-solr4.erb'
            path '/opt/tmp-solr4war/WEB-INF/web.xml'
            case node['platform_family']
            when 'windows'
              user win_user
              group win_group
            else
              user unix_user
              group unix_group
            end
            mode 00755
            not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
            only_if { ::File.exist?('/opt/tmp-solr4war/WEB-INF/web.xml') }
          end

          template 'set web.xml for solr4' do
            source 'solr/web.xml-solr4.erb'
            path "#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml"
            case node['platform_family']
            when 'windows'
              user win_user
              group win_group
            else
              user unix_user
              group unix_group
            end
            mode 00755
            only_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
          end

          bash 'archive and move alfresco war' do
            case node['platform_family']
            when 'windows'
              user win_user
            else
              user unix_user
            end
            cwd '/opt'
            code <<-EOH
      jar -cvf solr4.war -C tmp-solr4war/ .
      cp -rf solr4.war #{node['installer']['directory']}/tomcat/webapps/
      rm -rf solr4.war
      rm -rf tmp-solr4war
          EOH
            not_if { ::File.exist?("#{node['installer']['directory']}/tomcat/webapps/solr4/WEB-INF/web.xml") }
          end
        end
      end
    end
  end
end
