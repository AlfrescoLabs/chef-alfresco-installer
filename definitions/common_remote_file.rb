define :common_remote_file, :path => nil, :source => nil do
  params[:path] ||= params[:name]
    remote_file params[:path] do
      source params[:source]
      case node['platform_family']
        when 'windows'
          rights :read, 'Administrator'
          rights :write, 'Administrator'
          rights :full_control, 'Administrator'
          rights :full_control, 'Administrator', :applies_to_children => true
          group 'Administrators'
        else
          owner 'root'
          group 'root'
          mode 00755
        end
        action :create_if_missing
    end
end
