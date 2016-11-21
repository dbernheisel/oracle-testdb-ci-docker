#!/bin/bash
source $ORACLE_BASE/startup-functions.sh

# Remove database config files
rm -f $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora
rm -f $ORACLE_HOME/dbs/orapw$ORACLE_SID
rm -f $ORACLE_HOME/network/admin/tnsnames.ora

createDB;
