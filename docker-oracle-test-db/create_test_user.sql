-- https://github.com/rsim/oracle-enhanced/blob/master/RUNNING_TESTS.md
alter session set container=ORCLPDB1;
GRANT unlimited tablespace, create session, create table, create sequence, create procedure, create trigger, create view, create materialized view, create database link, create synonym, create type, ctxapp TO test IDENTIFIED BY test;
quit;
