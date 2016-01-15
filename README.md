# openshift-dedicated-container
for Openshift Dedicated


Building the Containers
------------

Builds are done by issuing the make command:
~~~~~~~~~~~~~~~~~~~~
make
~~~~~~~~~~~~~~~~~~~~

This will build the following Docker containers:

 * crunchy-container


Running Standalone
------------

A simple test of the crunchy-container is to run it outside of Openshift, you
can do this by running the run_pg.sh script.  This script assumes and requires you have
postgresql installed on the local host in order to provide a postgres uid/gid.

Test out the running container as follows:
~~~
psql -h localhost -p 12000 -U testuser -W testdb
~~~

Tuning and Configuration
---------------

You can adjust the following Postgres configuration parameters
by setting environment variables:
~~~
MAX_CONNECTIONS - defaults to 100
SHARED_BUFFERS - defaults to 128MB
TEMP_BUFFERS - defaults to 8MB
WORK_MEM - defaults to 4MB
MAX_WAL_SENDERS - defaults to 6
~~~

