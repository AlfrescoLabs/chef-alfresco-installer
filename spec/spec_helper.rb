require 'serverspec'
require 'net/ssh'
require 'net/smtp'
require 'net/imap'
require 'net/ftp'
require 'faraday'
require 'nokogiri'

set :backend, :ssh

currentDir=Dir.pwd

RSpec.configure do |c|
  c.output_stream = File.open("#{currentDir}/htmlReport/serverspec.html", 'w')
  c.formatter = 'html'
end

testProperties="#{currentDir}/test.properties"
propertiesFile = {}
IO.foreach(testProperties) do |line|
  propertiesFile[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~/([^=]*)=(.*)/
end
output = "File Name #{testProperties} \n"
propertiesFile.each { |key, value| output += " #{key}= #{value} \n" }

set :sudo_password, ENV['checklist_sudo_pass']
host = ENV['checklist_target_host']
options = Net::SSH::Config.for(host)
options[:user] ||= ENV['checklist_target_user']
options[:password] ||= ENV['checklist_target_password']


set :host, options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
