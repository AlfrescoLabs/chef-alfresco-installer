#
# Copyright (C) 2005-2015 Alfresco Software Limited.
#
# This file is part of Alfresco
#
# Alfresco is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Alfresco is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Alfresco. If not, see <http://www.gnu.org/licenses/>.
#/

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
