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
# /
require 'spec_helper'

ENV['ORACLE_UNQNAME'] = 'alfresco'
ENV['ORACLE_BASE'] = '/opt/oracle/app/oracle'
ENV['ORACLE_HOME'] = '/opt/oracle/app/oracle/product/12.1.0.2/db_1'
ENV['ORACLE_SID'] = 'alfresco'
ENV['PATH'] = "/opt/oracle/app/oracle/product/12.1.0.2/db_1/bin:#{ENV['PATH']}"

describe 'Validate oracle installation' do
  context 'When we check the status of postgres 1521 port it' do
    it { expect(port(1521)).to be_listening }
  end

  context 'When we verify if sqlplus executable is in the installation path' do
    it { expect(file('/opt/oracle/app/oracle/product/12.1.0.2/db_1/bin/sqlplus')).to be_file }
  end

  context 'When we run ps -ef | grep LISTENER to check if oracle listener is started its exit_status' do
    it { expect(command('ps -ef | grep LISTENER').exit_status).to eq 0 }
  end

  context 'When we login as oracle user then whoami' do
    it { expect(command("su - oracle -c 'whoami'").stdout).to match(/oracle/) }
  end

  context 'When we check if we can connect to oracle with default alfresco/alfresco user sqlplus stdout' do
    it do
      expect(command('sqlplus alfresco/alfresco << EOF
      quit
      EOF').stdout).to include('Connected to:')
    end
  end

  context 'When we check if we can create a table sqlplus stdout' do
    it do
      expect(command("sqlplus alfresco/alfresco << EOF
      CREATE TABLE \"ALFRESCO\".\"ALF_SERVER_TEST\" (
      \"ID\" NUMBER(19,0) NOT NULL ENABLE,
      \"VERSION\" NUMBER(19,0) NOT NULL ENABLE,
      \"IP_ADDRESS\" VARCHAR2(39 CHAR) NOT NULL ENABLE,
      PRIMARY KEY (\"ID\"));
      quit
    EOF").stdout).to include('Table created.')
    end
  end

  context 'When we check if we can drop a table sqlplus stdout' do
    it do
      expect(command("sqlplus alfresco/alfresco << EOF
      DROP TABLE \"ALFRESCO\".\"ALF_SERVER_TEST\";
      quit
      EOF").stdout).to include('Table dropped.')
    end
  end

  context 'When we check if we can create a sequence sqlplus stdout' do
    it do
      expect(command("sqlplus alfresco/alfresco << EOF
      CREATE SEQUENCE  \"ALFRESCO\".\"ALF_TEST_SEQ\"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 ORDER  NOCYCLE;
      quit
      EOF").stdout).to include('Sequence created.')
    end
  end

  context 'When we check if we can drop a sequence sqlplus stdout' do
    it do
      expect(command("sqlplus alfresco/alfresco << EOF
      DROP SEQUENCE \"ALFRESCO\".\"ALF_TEST_SEQ\";
      quit
      EOF").stdout).to include('Sequence dropped.')
    end
  end
end
