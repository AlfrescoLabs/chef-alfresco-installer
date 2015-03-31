#
# Cookbook Name:: alfresco-metal
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
require 'chef/provisioning/vagrant_driver'

vagrant_box 'dummy' do
url './dummy.box'
end

with_machine_options :vagrant_options: { 'vm.box' => 'redhat'}