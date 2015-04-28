require 'busser/rubygems'
require 'serverspec'
require 'yarjuf'

set :backend, :exec

RSpec.configure do |c|
  c.output_stream = File.open('/opt/serverspec.html', 'w')
  c.formatter = 'html'
end