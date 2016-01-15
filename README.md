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


### Openshift Examples

## PostgreSQL UID in Openshift
There are a couple of ways in OpenShift to allow the PostgreSQL database to run as the postgres UID.  We’ll cover both coarse-grained and finer-grained examples that users might deploy PostgreSQL with.

### Per-Pod Security Context Setting

A fine grained way to provide this same capability to the Crunchy PostgreSQL container is by specifying a security context in the pod template itself.  This is demonstrated in the ‘standalone-runasuser.json’ file.  Here is the portion of that template you will take note of:

~~
  "securityContext": {
                "runAsUser" : 26
        },
~~


This setting specifies to OpenShift that this pod should be run as the UID 26, which maps to the postgres user.

Within the Openshift security context file, you will specify the runAsUser.Type setting to MustRunAsNonRoot:

~~
runAsUser:
  type: MustRunAsNonRoot
~~

To execute the example, perform the following deployment commands in OpenShift:

~~
cd crunchy-postgresql-container-94/openshift
oc login
oc process -f standalone-runasuser.json | oc create -f -
~~

### Global Security Context Setting

A coarser-grained approach is to modify the security context constaint for the namespace to allow pods to run as any user.  You can modify these settings by the following command within your Openshift deployment:

~~~
oc edit scc restricted --config=./openshift.local.config/master/admin.kubeconfig
~~~

Within the Security Context Constraints, you will specify the runAsUser.Type setting to RunAsAny:

~~~
runAsUser:
  type: RunAsAny
~~~

This is a coarse-grained way of opening up OpenShift’s security to allow any pod/container to run as any user.  This security setting might be too permissive for many environments.

## Using Secrets for PostgreSQL Credentials

Another Openshift security feature that can be used for PostgreSQL containers is to obtain username and passwords from a secret.  A secret is a concept within Openshift that allows any sort of secret or private information to be consumed in a volume in a container.  Secrets allow credentials to be used independently of where they are defined, and to be used without leaking secret information into the places where processes that use them are defined.  For more information on “secrets” within OpenShift, please see here: https://docs.openshift.com/enterprise/3.0/dev_guide/secrets.html

Using the following commands, we can establish some usernames and passwords to be used within PostgreSQL:

~~~
oc secrets new-basicauth pgroot --username=postgres --password=postgrespsw
oc secrets new-basicauth pgmaster --username=master --password=masterpsw
oc secrets new-basicauth pguser --username=testuser --password=somepassword
~~~

These usernames and passwords (made “secrets” by OpenShift)  are then populated in a volume mounted into a PostgreSQL container the credentials can be read from the file system.  The secret data is stored in a tmpfs filesystem so that it does not come to rest on nodes where pods use the secret and isolated with SELinux so that other containers cannot use it.

You can view the secrets that have been created by running the following command:

~~~
oc get secrets
~~~


You can see examples of referencing a secret within a container by looking at the example templates here:

 * standalone-secret.json (an example that deploys a single PostgreSQL database)
 * master-slave-rc-secret.json (an example of deploying a master-slave PostgreSQL configuration that can be scaled up using replication controllers)

Secrets are consumed by pods via volumes within your container specification:

~~~
           "volumes": [{
                "name": "pgdata",
                "emptyDir": {}
            }, {
                "name": "pguser-volume",
                "secret": {
                    "secretName": "pguser"
                }
            },
.
.
.
            "volumeMounts": [{
                    "mountPath": "/pgdata",
                    "name": "pgdata",
                    "readOnly": false
                }, {
                    "mountPath": "/pguser",
                    "name": "pguser-volume"
                }
~~~


Scripts within the container can then reference the secrets by referring to the mounted volumes as specified in the template.

Secrets provide yet another way for a database container to fetch login credentials other than passing them via environment variables.

