# openshift-dedicated-container
for Openshift Dedicated

This project provides a set of Docker containers that
provide Postgresql services within the Openshift Dedicated platform.

## Building the Containers

Builds are done by issuing the make command:
~~~~~~~~~~~~~~~~~~~~
make
~~~~~~~~~~~~~~~~~~~~

This will build the following Docker containers:

 * crunchy-container


## Running Standalone

A simple test of the crunchy-container is to run it outside of Openshift, you
can do this by running the run_pg.sh script.  This script assumes and requires you have
postgresql installed on the local host in order to provide a postgres uid/gid.

Test out the running container as follows:
~~~
psql -h localhost -p 12000 -U testuser -W testdb
~~~

## Container Maintenance

To examine the inner workings of the container, use this command to get
inside the container instance:

~~~
sudo docker exec -it crunchy-pg bash
~~~

To stop and start the container you can enter:

~~~
sudo docker stop crunchy-pg
sudo docker start crunchy-pg
~~~

## Tuning and Configuration

You can adjust the following Postgres configuration parameters
by setting environment variables:
~~~
MAX_CONNECTIONS - defaults to 100
SHARED_BUFFERS - defaults to 128MB
TEMP_BUFFERS - defaults to 8MB
WORK_MEM - defaults to 4MB
MAX_WAL_SENDERS - defaults to 6
~~~

You have the ability to override the pg_hba.conf and postgresql.conf
files used by the container.  To enable this, you create a
directory to hold your own copy of these configuration files.

Then you mount that directory into the container using the /pgconf
volume mount as follows:

~~~~~~
-v $YOURDIRECTORY:/pgconf
~~~~~~

Inside YOURDIRECTORY would be your pg_hba.conf and postgresql.conf
files.  These files are not manipulated or changed by the container
start scripts.


