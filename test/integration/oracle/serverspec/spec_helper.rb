require 'busser/rubygems'
require 'serverspec'
require 'yarjuf'
require 'faraday'

set :backend, :exec

RSpec.configure do |c|
  c.output_stream = File.open('/opt/serverspec-oracle.xml', 'w')
  c.formatter = 'JUnit'
end