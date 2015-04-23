require 'busser/rubygems'
Busser::RubyGems.install_gem('yarjuf', '~> 2.0.0')
Busser::RubyGems.install_gem('faraday', '~> 0.9.1')

require 'serverspec'
require 'yarjuf'
require 'faraday'

set :backend, :exec

RSpec.configure do |c|
  c.output_stream = File.open('/opt/serverspec-postgres.xml', 'w')
  c.formatter = 'JUnit'
end