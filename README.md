## Challenge

I had a challenge with getting an application to run in my CI environment (GitLab). Unfortunately, Oracle does not publish ready-made images to Docker that makes it easy like other databases. Oracle _tries_ to make it easier by publishing some scripts and examples to build your own images [here](https://github.com/oracle/docker-images/tree/master/OracleDatabase). I've followed those directions, but unfortunately it's not quite the same as other database and requires special care.

## What is this?

Two Docker setups:
1) `docker-oracle-test-base` is the original instructions at https://github.com/oracle/docker-images/tree/master/OracleDatabase but modified to not have a VOLUME instruction, so that the pluggable database is persisted to the image.
2) `docker-oracle-test-db` is another image that can be used for running tests within a CI environment. It always starts empty, but does not take 30min to initialize the database; instead it takes about 1min.

## Usage

1) **test-base**
1) Download Oracle Database 12c binaries and place them into the `docker-oracle-test-base` folder.
1) cd into the test-base directory, and run `docker build -t oracle/database:12.1.0.2-ee .`
1) [Optional] You may want to tag it and push it to your private repo at this point.
1) **test-db**
1) Adjust the test-db variables if you'd like:
  * Make sure the ORACLE_PDB1 variable is the same in `create_test_user.sql` and the Dockerfile.
1) cd into the test-db directory, and run `docker build -t oracle12c-test .`
1) That should be it. Now it just depends on what you want to do. See my sample
files for `gitlab-ci` or `docker-compose`. I was building a Rails application
that needed Oracle, so some of my samples lend itself to that environment.

## Disclaimer

I am not a Docker expert. I got this to work, but probably not the _right_ way, but I decided to help others with this example who are starting out. If you have suggestions, just let me know.

## Recommendations

For private repos, it's a bit unreasonable to commit the Oracle Database linux binaries, so what I've done myself is alter the base image's Dockerfile to add the oracle images from an intranet so my co-workers don't have to download them seperately and go through Oracle. This should be fine because the company you're working for agrees to Oracle's licenses to download the binaries.

If you do this, you'd adjust the test-base Dockerfile as such:

```dockerfile
COPY $INSTALL_FILE_1 $INSTALL_FILE_2 $INSTALL_RSP $PERL_INSTALL_FILE $INSTALL_DIR/
COPY $RUN_FILE $CONFIG_RSP $PWD_FILE $ORACLE_BASE/

# to

COPY $INSTALL_RSP $PERL_INSTALL_FILE $INSTALL_DIR/
COPY $RUN_FILE $CONFIG_RSP $PWD_FILE $ORACLE_BASE/
ADD https://your_intranet_here/$INSTALL_FILE_1 $INSTALL_DIR/
ADD https://your_intranet_here/$INSTALL_FILE_2 $INSTALL_DIR/
```
