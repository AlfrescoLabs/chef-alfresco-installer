define :common_template, :path => nil, :source => nil do
  params[:path] ||= params[:name]
    template params[:path] do
      source params[:source]
      case node['platform_family']
        when 'windows'
          rights :read, 'Administrator'
          rights :write, 'Administrator'
          rights :full_control, 'Administrator'
          rights :full_control, 'Administrator', :applies_to_children => true
          group 'Administrators'
          :top_level
        else
          owner 'root'
          group 'root'
          mode 00755
          :top_level
        end
    end
end
