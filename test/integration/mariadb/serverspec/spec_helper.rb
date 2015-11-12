require 'busser/rubygems'

Busser::RubyGems.install_gem('faraday', '~> 0.9')
Busser::RubyGems.install_gem('coderay', '~> 1.1.0')

require 'serverspec'
require 'faraday'
require 'rbconfig'
require 'coderay'

set :backend, :cmd

case RbConfig::CONFIG['host_os']
when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
  set :os, family: 'windows'
end

RSpec.configure do |c|
  c.output_stream = File.open('C:\\Users\\Administrator\\serverspec.html', 'w')
  c.formatter = 'html'
end
