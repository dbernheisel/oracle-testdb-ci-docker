FROM oracle/database:12.1.0.2-ee
MAINTAINER David Bernheisel <david.bernheisel@scimedsolutions.com>

ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/12.1.0.2/dbhome_1 \
    ORACLE_SID="ORCLCDB" \
    ORACLE_PDB="ORCLPDB1" \
    ORACLE_PWD="oracle"

# Use second ENV so that variable get substituted
ENV INSTALL_DIR=$ORACLE_BASE/install \
    PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH \
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib \
    CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

USER root
COPY startup-functions.sh createDB.sh startDB.sh $ORACLE_BASE/
RUN chmod ug+x $ORACLE_BASE/startDB.sh $ORACLE_BASE/createDB.sh $ORACLE_BASE/startup-functions.sh &&\
    chown oracle:dba $ORACLE_BASE/startDB.sh $ORACLE_BASE/createDB.sh $ORACLE_BASE/startup-functions.sh

USER oracle
WORKDIR /home/oracle
RUN bash $ORACLE_BASE/createDB.sh
COPY create_test_user.sql /home/oracle/
RUN bash $ORACLE_BASE/startDB.sh

COPY startDbAndWait.sh /home/oracle/
USER root
RUN chmod ug+x /home/oracle/startDbAndWait.sh &&\
    chown oracle:dba /home/oracle/startDbAndWait.sh
USER oracle
EXPOSE 1521 5500
ENTRYPOINT /home/oracle/startDbAndWait.sh

# docker build -t oracle12c-test .
# docker run --name oracle12c --rm -i -t oracle12c-test
