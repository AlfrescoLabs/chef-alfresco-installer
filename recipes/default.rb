#
# Cookbook Name:: alfresco-metal
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
require 'chef_metal_vsphere'
with_driver 'vsphere'

with_machine_options({
  bootstrap_options: {
    template: '/01Base_Templates/QATMP-RHEL6.5X64',           # vCenter "VMs and Templates" path to a VM Template
    folder: '/QAA-NESS-VMS/Sergiu'  # vCenter "VMs and Templates" path to a Folder.  New VMs are created in this folder.
  },
  ssh_options: {
    user:                  'root',                # root or a user with ssh access and NOPASSWD sudo on a VM cloned from the template
    password:              'alfresco',      # consisder using chef-vault
    port:                  22,
    paranoid:              false                  # don't do this in production, either
  }
})

1.upto 2 do |n|
  machine "metal_#{n}" do
    action [:create]
  end

  machine "metal_#{n}" do
    # note: no need to :stop before :delete
    action [:delete]
  end

end