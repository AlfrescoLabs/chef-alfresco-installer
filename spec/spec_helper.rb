require 'serverspec'
require 'net/ssh'
require 'yarjuf'
require 'faraday'

set :backend, :ssh

currentDir=Dir.pwd

RSpec.configure do |c|
  c.output_stream = File.open("#{currentDir}/serverspec.html", 'w')
  c.formatter = 'html'
end


testProperties="#{currentDir}/test.properties"
propertiesFile = {}
IO.foreach(testProperties) do |line|
  propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = "File Name #{testProperties} \n"
propertiesFile.each {|key,value| output += " #{key}= #{value} \n" }

if ENV['checklist_sudo_pass']
  set :sudo_password, ENV['checklist_sudo_pass']
else
  set :sudo_password, propertiesFile['sudo_password']
end

if ENV['checklist_target_host']
  host = ENV['checklist_target_host']
else
  host = propertiesFile['host']
end

options = Net::SSH::Config.for(host)

if ENV['checklist.target_user']
  options[:user] ||= ENV['checklist_target_user']
else
  options[:user] ||= propertiesFile['user']
end

if ENV['checklist_target_password']
  options[:password] ||= ENV['checklist_target_password']
else
  options[:password] ||= propertiesFile['PASSWORD']
end

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
