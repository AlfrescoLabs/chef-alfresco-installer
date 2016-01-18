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

  # Used for applying amps on alfresco and share
  class AlfApplyAmps < Chef::Resource
    resource_name :alfApplyAmps

    property :resource_title, String, name_property: true
    property :amps_folder, String, required: true
    property :amps_share_folder, String, required: true
    property :installation_folder, String, default: lazy { node['installer']['directory'] }
    property :share_amps, default: lazy { node['amps']['share'] }
    property :alfresco_amps, default: lazy { node['amps']['alfresco'] }
    property :bin_folder, String, required: true
    property :alfresco_webapps, String, required: true
    property :share_webapps, String, required: true
    property :tomcat_folder, String, required: true
    property :windowsUser, String
    property :windowsGroup, String
    property :unixUser, String
    property :unixGroup, String

    action :create do

        directory amps_folder do
          case node['platform_family']
          when 'windows'
            rights :read, 'Administrator'
            rights :write, 'Administrator'
            rights :full_control, 'Administrator'
            rights :full_control, 'Administrator', applies_to_children: true
            group 'Administrators'
          else
            owner 'root'
            group 'root'
            mode 00755
            recursive true
            :top_level
          end
        end

        directory amps_share_folder do
          case node['platform_family']
          when 'windows'
            rights :read, 'Administrator'
            rights :write, 'Administrator'
            rights :full_control, 'Administrator'
            rights :full_control, 'Administrator', applies_to_children: true
            group 'Administrators'
          else
            owner 'root'
            group 'root'
            mode 00755
            recursive true
            :top_level
          end
        end

      if alfresco_amps && alfresco_amps.length > 0
        alfresco_amps.each do |_ampName, url|
          alfRemoteFile "#{amps_folder}/#{::File.basename(url)}" do
            source_url url
            win_user windowsUser
            win_group windowsGroup
            unix_user unixUser
            unix_group unixGroup
          end
        end
      end

      if share_amps && share_amps.length > 0
        share_amps.each do |_ampName, url|
          alfRemoteFile "#{amps_share_folder}/#{::File.basename(url)}" do
            source_url url
            win_user windowsUser
            win_group windowsGroup
            unix_user unixUser
            unix_group unixGroup
          end
        end
      end

      # TODO: find a way to modify per shell winrm memory to more than 300MB, in the current session
      # powershell_script 'modify shell memory for winrm' do
      #   guard_interpreter :powershell_script
      #   code 'set-item wsman:localhost\Shell\MaxMemoryPerShellMB 2048'
      #   only_if { node['platform_family'] == 'windows' }
      # end

      execute "apply alfresco amps" do
        command "java -jar alfresco-mmt.jar install #{amps_folder} #{alfresco_webapps}/alfresco.war -nobackup -directory -force"
        cwd         bin_folder
        if node['platform_family'] != 'windows'
          user unixUser
        end
        only_if {alfresco_amps}
      end

      execute "apply share amps" do
        command "java -jar alfresco-mmt.jar install #{amps_share_folder} #{share_webapps}/share.war -nobackup -directory -force"
        cwd         bin_folder
        if node['platform_family'] != 'windows'
          user unixUser
        end
        only_if {share_amps}
      end

      execute "Cleanup share/alfresco webapps and temporary files" do
        command "rm -rf #{alfresco_webapps}/alfresco; rm -rf #{share_webapps}/share"
        cwd         bin_folder
        if node['platform_family'] != 'windows'
          user unixUser
        end
      end

      execute "Cleanup tomcat temporary files" do
        command "rm -rf #{tomcat_folder}/logs/*; rm -rf #{tomcat_folder}/temp/*; rm -rf #{tomcat_folder}/work/*"
        cwd         bin_folder
        if node['platform_family'] != 'windows'
          user unixUser
        end
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
