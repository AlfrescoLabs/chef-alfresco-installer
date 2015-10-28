Feature: I can install jdk-8u31 from local repository

Background:
Given i have provisioned the following insfrastructure

| Server Name | Operating System | Chef Version | Run List |
| alfresco_java | ubuntu/trusty64 | 12.03 | alfresco_java::java8 |
And I have run Chef

Scenario: User checks version for java
Given a ssh connection to the installed node
When a user issues the command 'java -version'
Then the user should see "java version 1.8.0_31"