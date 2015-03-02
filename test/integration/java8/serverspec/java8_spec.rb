require 'spec_helper'

describe command('java -version') do
  its(:stdout) { expect contain "1.8.0_31" }
end

describe file('/opt/jdk-8u31-linux-x64.tar.gz') do
  it { expect be_file }
end
