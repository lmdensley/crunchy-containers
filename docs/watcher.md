
### Watcher Design

We create a container, crunchy-watch, that lives inside a pod
with a master container.

The watch container has access to a service account that is used
inside the container to issue commands to openshift.

You set up the SA using this:

oc create -f sa.json

You then set up permissions for the SA to edit stuff in the openshift project,
this example allows all service accounts to edit resources in the 'openshift'
project:

~~~~~~~~~~~
oc policy add-role-to-group edit system:serviceaccounts -n openshift
~~~~~~~~~~~

You then reference the SA within the POD spec:

watch-logic.sh is an example of what can run inside the watch container

I copy the oc command into the container from the host when the container
image is built.  I could not find a way to install this using the redhat 
rpms, so I manually add it to the container.

Logic

The watch container will watch the master, if the master dies, then 
the watcher will:

 * create the trigger file on the slave that will become the new master
 * change the labels on the slave to be those of the master
 * will start watching the new master in case that falls over next

Questions

does this run in a pod outside of the master and slave pods?  probably not
in the master pod since the whole pod would die, probably best done
in the slave pod?


