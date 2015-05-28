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


set :sudo_password, propertiesFile['password']

host = propertiesFile['host']

options = Net::SSH::Config.for(host)

options[:user] ||= propertiesFile['user']
options[:password] ||= propertiesFile['password']

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
