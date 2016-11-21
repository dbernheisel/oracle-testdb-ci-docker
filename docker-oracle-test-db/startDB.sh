#!/bin/bash
source $ORACLE_BASE/startup-functions.sh

# symLinkFiles;
startDB;
sqlplus sys/$ORACLE_PWD@//localhost:1521/$ORACLE_PDB as sysdba @create_test_user.sql
