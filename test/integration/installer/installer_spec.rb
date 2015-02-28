require 'spec_helper'

describe port(8080) do
  it { should be_listening }
end

describe port(5432) do
  it { should be_listening }
end

describe port(50500) do
  it { should be_listening}
end

describe port(8100) do
  it { should be_listening }
end

describe port(8443) do
  it { should be_listening }
end

describe process("postgres") do
  it { should be_running }
end

describe process("tomcat") do
  it { should be_running }
end

describe service('alfresco') do
  it { should be_enabled }
end