require 'leibniz'

Given(/^i have provisioned the following insfrastructure$/) do |specification|
  @infrastructure = Leibniz.build(specification)
end

Given(/^I have run Chef$/) do
  @infrastructure.destroy
  @infrastructure.converge
end

Given(/^a ssh connection to the installed machine$/) do
  @connect_command="vagrant ssh"
end

When(/^a user issues the command java \-version$/) do
  @execute_command=""
end

Then(/^the user should see "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
