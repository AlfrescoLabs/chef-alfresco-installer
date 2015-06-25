require 'serverspec'
require 'net/ssh'
require 'net/smtp'
require 'net/imap'
require 'net/ftp'
require 'faraday'
require 'nokogiri'
require 'net/telnet'
require 'yarjuf'

set :backend, :ssh

currentDir=Dir.pwd

RSpec.configure do |c|
  c.output_stream = File.open("#{currentDir}/htmlReport/serverspec.xml", 'w')
  c.formatter = 'JUnit'
end

set :sudo_password, ENV['checklist_sudo_pass']
host = ENV['checklist_target_host']
options = Net::SSH::Config.for(host)
options[:user] ||= ENV['checklist_target_user']
options[:password] ||= ENV['checklist_target_password']

set :host, options[:host_name] || host
set :ssh_options, options
