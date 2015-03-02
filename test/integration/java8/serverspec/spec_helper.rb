require 'busser/rubygems'
Busser::RubyGems.install_gem('yarjuf', '~> 2.0.0')

require 'serverspec'
require 'yarjuf'

set :backend, :exec

RSpec.configure do |c|
  c.output_stream = File.open('/resources/serverspec-result.xml', 'w')
  c.formatter = 'JUnit'
end