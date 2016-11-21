#!/bin/bash

cat <<EOT > check-db-up.sql
select 'alive' from dual;
quit;
EOT

CONNECTION="$ORACLE_USER/$ORACLE_USER_PWD@//$ORACLE_HOST:1521/$ORACLE_PDB"

# Below requires the Oracle Instant Client to be installed.
function check_db() {
  RETVAL=`sqlplus $CONNECTION @check-db-up.sql`
  echo $RETVAL | grep "alive"
  DB_OK=$?
}

echo "Wait until DB is up"
check_db
while [ $DB_OK = 1 ]; do
  echo "DB not up yet. Sleeping for 15 seconds. Connection: $CONNECTION"
  echo "Last return: $RETVAL"
  sleep 15
  check_db
done

echo "Database is ready"
