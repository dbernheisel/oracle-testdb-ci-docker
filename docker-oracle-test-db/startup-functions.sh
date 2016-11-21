#!/bin/bash

############# Start DB ################
function startDB {
  # Make sure audit file destination exists
  if [ ! -d $ORACLE_BASE/admin/$ORACLE_SID/adump ]; then
    mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
  fi;

  lsnrctl start
  sqlplus / as sysdba << EOF
    STARTUP;
EOF

}

########### Symbolic link DB files ############
# function symLinkFiles {

#   if [ ! -L $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora ]; then
#     ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/spfile$ORACLE_SID.ora $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora
#   fi;

#   if [ ! -L $ORACLE_HOME/dbs/orapw$ORACLE_SID ]; then
#     ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/orapw$ORACLE_SID $ORACLE_HOME/dbs/orapw$ORACLE_SID
#   fi;

#   if [ ! -L $ORACLE_HOME/network/admin/tnsnames.ora ]; then
#     ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora
#   fi;

#   # oracle user does not have permissions in /etc, hence cp and not ln
#   cp $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/oratab /etc/oratab

# }

########### Move DB files ############
function moveFiles {

  if [ ! -d $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID ]; then
    mkdir -p $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
  fi;

  mv $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
  mv $ORACLE_HOME/dbs/orapw$ORACLE_SID $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/
  mv $ORACLE_HOME/network/admin/tnsnames.ora $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/

  # oracle user does not have permissions in /etc, hence cp and not mv
  cp /etc/oratab $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/

  # symLinkFiles;
}

############# Create DB ################
function createDB {

  echo "ORACLE AUTO GENERATED PASSWORD FOR SYS, SYSTEM AND PDBAMIN: $ORACLE_PWD";

  cp $ORACLE_BASE/$CONFIG_RSP $ORACLE_BASE/dbca.rsp

  sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" $ORACLE_BASE/dbca.rsp
  sed -i -e "s|###ORACLE_PDB###|$ORACLE_PDB|g" $ORACLE_BASE/dbca.rsp
  sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" $ORACLE_BASE/dbca.rsp

  mkdir -p $ORACLE_HOME/network/admin
  echo "NAME.DIRECTORY_PATH= {TNSNAMES, EZCONNECT, HOSTNAME}" > $ORACLE_HOME/network/admin/sqlnet.ora

  # Listener.ora
  echo "LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    )
  )

" > $ORACLE_HOME/network/admin/listener.ora

  # Start LISTENER and run DBCA
  lsnrctl start &&
  dbca -silent -responseFile $ORACLE_BASE/dbca.rsp ||
    cat /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID/$ORACLE_SID.log

  echo "$ORACLE_SID=localhost:1521/$ORACLE_SID" >> $ORACLE_HOME/network/admin/tnsnames.ora
  echo "$ORACLE_PDB=
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = $ORACLE_PDB)
    )
  )" >> $ORACLE_HOME/network/admin/tnsnames.ora

  sqlplus / as sysdba << EOF
    ALTER SYSTEM SET control_files='$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl' scope=spfile;
    ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;
EOF

  rm $ORACLE_BASE/dbca.rsp

  # Move database operational files to oradata
  # moveFiles;

}

# Default for ORACLE SID
if [ "$ORACLE_SID" == "" ]; then
   export ORACLE_SID=ORCLCDB
fi;

# Default for ORACLE PDB
if [ "$ORACLE_PDB" == "" ]; then
   export ORACLE_PDB=ORCLPDB1
fi;
