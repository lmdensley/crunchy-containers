
This set of instructions was tested on a local build of
Origin 1.0.4 on centos 7.

Log on as a test user:

oc login

create a test project such as 'pgproject'

oc new-project pgproject

You need to specify RunAsAny to let the crunchy container
run as the postgres user, you do this by editing the security
context restricted values as follows:

~~~~~~~~~~~
cd /home/jeffmc/go/src/github.com/openshift/origin/_output/local/go/bin
oc edit scc restricted --config=./openshift.local.config/master/admin.kubeconfig
~~~~~~~~~~~

Change the RunAsRange value to RunAsAny.

Create the standalone container:

~~~~~~~~~~~
oc process -f standalone.json | oc create -f -
~~~~~~~~~~~

You should have a running pod and service:

~~~~~~~~~~~
oc get pods
oc get services
~~~~~~~~~~~

Find out what password was generated for your 'testuser' postgres
user by running docker 'inspect' on the pg-standalone container.

Here is how I install postgres on the Origin or test host:

~~~~~~~~~~
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
sudo rpm -Uvh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm
sudo yum install -y procps-ng postgresql94 postgresql94-contrib postgresql94-server
~~~~~~~~~~

To test locally your postgres containers, you would install the
postgres client 'psql' and then execute as follows:

~~~~~~~~~~~
psql -h pg-standalone.pgproject.svc.cluster.local -U testuser userdb
~~~~~~~~~~~

Notice that openshift will create (if working properly) a DNS
name for the pg-standalone container.  The crunchy container
creates a postgres user called 'testuser', and a test database
called 'userdb'.  You will be prompted for the 'testuser' password.

