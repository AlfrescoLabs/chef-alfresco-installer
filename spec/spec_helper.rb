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

set :sudo_password, ENV['PASSWORD']

host = ENV['TARGET_HOST']

options = Net::SSH::Config.for(host)

options[:user] ||= ENV['USER']
options[:password] ||= ENV['PASSWORD']

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
