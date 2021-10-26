-- Log into psql using postgres user then enter password on command line
psql -U postgres -W

-- Enter password

-- List datbases
\l

-- Drop template1. Templates can’t be dropped, so we first modify it so it’s an ordinary database
UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';

-- Now we can drop it:
DROP DATABASE template1;

-- Now it’s time to create database from template0, with a new default encoding:
CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';

-- Now modify template1 so it’s actually a template:
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';

-- Now switch to template1 and VACUUM FREEZE the template:
\c template1
VACUUM FREEZE;

-- Repeat for template2
-- Create template2 database from template0, with UTF-8 encoding
CREATE DATABASE template2 WITH TEMPLATE = template0 ENCODING = 'UNICODE';

-- Now modify template1 so it’s actually a template:
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template2';

-- Now switch to template1 and VACUUM FREEZE the template:
\c template2
VACUUM FREEZE;

-- Repeat for template3
-- Create template3 database from template0, with UTF-8 encoding
CREATE DATABASE template3 WITH TEMPLATE = template0 ENCODING = 'UNICODE';

-- Now modify template1 so it’s actually a template:
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template3';

-- Now switch to template1 and VACUUM FREEZE the template:
\c template3
VACUUM FREEZE;

-- Create the BAW database
-- create the user
CREATE ROLE wfauser PASSWORD 'Bpmr0cks' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;

-- create the database:
CREATE DATABASE wfadb OWNER wfauser template template0;
GRANT ALL ON DATABASE wfadb to wfauser;

-- Connect to your database and create schema
\c wfadb;
SET ROLE wfauser;
CREATE SCHEMA IF NOT EXISTS wfauser AUTHORIZATION wfauser;


-- Create the App Engine database
-- create a new user
create user aeuser with password 'Bpmr0cks';

-- create database APP_ENGINE_DB_NAME
-- create database aedb owner aeuser;
create database aedb owner aeuser template template1;

-- The following grant is used for databases
grant all privileges on database aedb to aeuser;

-- Connect to your database and create schema
\c aedb;
SET ROLE aeuser;
CREATE SCHEMA IF NOT EXISTS aeuser AUTHORIZATION aeuser;

-- Create the BAS database
-- create the user
CREATE ROLE basuser PASSWORD 'Bpmr0cks' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;

-- create the database:
CREATE DATABASE basdb WITH OWNER basuser template template2;
GRANT ALL ON DATABASE basdb to basuser;

-- Connect to your database and create schema
\c basdb;
SET ROLE basuser;
CREATE SCHEMA IF NOT EXISTS basuser AUTHORIZATION basuser;
