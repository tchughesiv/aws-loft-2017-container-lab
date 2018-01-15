# LAB 4: Orchestrated deployment of a decomposed application

In this lab we introduce how to orchestrate a multi-container application in OpenShift.

This lab should be performed on **YOUR ASSIGNED AWS VM** as `ec2-user` unless otherwise instructed.

Expected completion: 40-60 minutes

Let's start with a little experimentation. I am sure you are all excited about your new blog site! And, now that it is getting super popular with 1,000s of views per day, you are starting to worry about uptime.

So, let's see what will happen. Launch the site:

```bash
$ docker run -d -p 3306:3306 -e DBUSER=user -e DBPASS=mypassword -e DBNAME=mydb --name mariadb mariadb
$ docker run -d -p 8080:8080 --link mariadb:db --name wordpress wordpress
```

Take a look at the site in your web browser on your machine using 
`http://<YOUR AWS VM PUBLIC DNS NAME HERE>:8080`. As you learned before, you can confirm the port that your server is running on by executing:
```bash
$ docker ps
$ docker port wordpress
8080/tcp -> 0.0.0.0:8080
```

Now, let's see what happens when we kick over the database. However, for a later experiment, let's grab the container-id right before you do it. 
```bash
$ OLD_CONTAINER_ID=$(docker inspect --format '{{ .Id }}' mariadb)
$ docker stop mariadb
```

Take a look at the site in your web browser or using curl now. And, imagine explosions! (*making sound effects will be much appreciated by your lab mates.*)
  
* web browser -> `http://<YOUR AWS VM PUBLIC DNS NAME HERE>:8080`
OR
```bash
$ curl -L http://localhost:8080
```

Now, what is neat about a container system, assuming your web application can handle it, is we can bring it right back up, with no loss of data.
```bash
$ docker start mariadb
```

OK, now, let's compare the old container id and the new one.
```bash
$ NEW_CONTAINER_ID=$(docker inspect --format '{{ .Id }}' mariadb)
$ echo -e "$OLD_CONTAINER_ID\n$NEW_CONTAINER_ID"
```

Hmmm. Well, that is cool, they are exactly the same. OK, so all in all, about what you would expect for a web server and a database running on VMs, but a whole lot faster. Let's take a look at the site now.

* web browser -> `http://<YOUR AWS VM PUBLIC DNS NAME HERE>:8080`
OR
```bash
$ curl -L http://localhost:8080
```

And.. Your site is back! Fortunately wordpress seems to be designed such that it does not need a restart if its database goes away temporarily.

Finally, let's kill off these containers to prepare for the next section.
```bash
$ docker rm -f wordpress mariadb
```

Starting and stopping is definitely easy, and fast. However, it is still pretty manual. What if we could automate the recovery? Or, in buzzword terms, "ensure the service remains available"? Enter Kubernetes/OpenShift.

## Using OpenShift

Now login to our local OpenShift & create a new project:
```bash
$ oc login -u developer
Using project "myproject".

$ oc new-project devel
Now using project "devel" on server "https://10.xx.xx.xxx:8443".
```

You are now logged in to OpenShift and are using the ```devel``` project. You can also view the OpenShift web console by using the same credentials to log in to ```https://<YOUR AWS VM PUBLIC DNS NAME HERE>:8443``` in a browser.

## Pod Creation

Let's get started by talking about a pod. A pod is a set of containers that provide one "service." How do you know what to put in a particular pod? Well, a pod's containers need to be co-located on a host and need to be spawned and re-spawned together. So, if the containers always need to be running on the same container host, well, then they should be a pod.

**Note:** We will be putting this file together in steps to make it easier to explain what the different parts do. We will be identifying the part of the file to modify by looking for an "empty element" that we inserted earlier and then replacing that with a populated element.

Let's make a pod for mariadb. Open a file called mariadb-pod.yaml.
```bash
$ mkdir -p ~/workspace/mariadb/openshift
$ vi ~/workspace/mariadb/openshift/mariadb-pod.yaml
```

In that file, let's put in the pod identification information:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mariadb
  labels:
    name: mariadb
spec:
  containers:
```

We specified the version of the Kubernetes API, the name of this pod (aka ```name```), the ```kind``` of Kubernetes thing this is, and a ```label``` which lets other Kubernetes things find this one.

Generally speaking, this is the content you can copy and paste between pods, aside from the names and labels.

Now, let's add the custom information regarding this particular container. To start, we will add the most basic information. Please replace the ```containers:``` line with:
```yaml
  containers:
  - name: mariadb
    image: localhost:5000/mariadb
    ports:
    - containerPort: 3306
    env:
```

Here we set the ```name``` of the container; remember we can have more than
one in a pod. We also set the ```image``` to pull, in other words, the container 
image that should be used and the registry to get it from.

Lastly, we need to configure the environment variables that need to be fed from 
the host environment to the container. Replace ```env:``` with:
```yaml
    env:
    - name: DBUSER
      value: user
    - name: DBPASS
      value: mypassword
    - name: DBNAME
      value: mydb
```

OK, now we are all done, and should have a file that looks like:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mariadb
  labels:
    name: mariadb
spec:
  containers:
  - name: mariadb
    image: localhost:5000/mariadb
    ports:
    - containerPort: 3306
    env:
    - name: DBUSER
      value: user
    - name: DBPASS
      value: mypassword
    - name: DBNAME
      value: mydb
```

Our wordpress container is much less complex, so let's do that pod next.
```bash
$ mkdir -p ~/workspace/wordpress/openshift
$ vi ~/workspace/wordpress/openshift/wordpress-pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wordpress
  labels:
    name: wordpress
spec:
  containers:
  - name: wordpress
    image: localhost:5000/wordpress
    ports:
    - containerPort: 8080
    env:
    - name: DB_ENV_DBUSER
      value: user
    - name: DB_ENV_DBPASS
      value: mypassword
    - name: DB_ENV_DBNAME
      value: mydb
```

A couple things to notice about this file. Obviously, we change all the appropriate names to reflect "wordpress" but, largely, it is the same as the mariadb pod file. We also use the environment variables that are specified by the wordpress container, although they need to get the same values as the ones in the mariadb pod.

Ok, so, let's launch our pods and make sure they come up correctly. In order to do this, we need to introduce the ```oc``` command which is what drives OpenShift. Generally, speaking, the format of ```oc``` commands is ```oc <operation> <kind>```. Where ```<operation>``` is something like ```create```, ```get```, ```remove```, etc. and ```kind``` is the ```kind``` from the pod files.
```bash
$ oc create -f ~/workspace/mariadb/openshift/mariadb-pod.yaml
$ oc create -f ~/workspace/wordpress/openshift/wordpress-pod.yaml
```

Now, I know i just said, ```kind``` is a parameter, but, as this is a create statement, it looks in the ```-f``` file for the ```kind```.

Ok, let's see if they came up:
```bash
$ oc get pods
```

Which should output two pods, one called ```mariadb``` and one called ```wordpress``` . You can also check the OpenShift web console if you already have it pulled up and verify the pods show up there as well.

If you have any issues with the pods transistioning from a "Pending" state, you can check out the logs from the OpenShift containers in multiple ways. Here are a couple of options:
```bash
$ oc logs mariadb
$ oc describe pod mariadb

$ oc logs wordpress
$ oc describe pod wordpress
```

Ok, now let's kill them off so we can introduce the services that will let them more dynamically find each other.
```bash
$ oc delete po/mariadb po/wordpress
```

Verify they are terminating or are gone:
```bash
$ oc get pods
```

**Note** you used the "singular" form here on the ```kind```, which, for delete, is required and requires a "name". However, you can, usually, use them interchangeably depending on the kind of information you want.

## Service Creation
Now we want to create Kubernetes Services for our pods so that OpenShift can introduce a layer of indirection between the pods.

Let's start with mariadb. Open up a service file:
```bash
$ vi ~/workspace/mariadb/openshift/mariadb-service.yaml
```

and insert the following content:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mariadb
  labels:
    name: mariadb
spec:
  ports:
  - port: 3306
  selector:
    name: mariadb
```

As you can probably tell, there isn't really anything new here. However, you need to make sure the ```kind``` is of type ```Service``` and that the ```selector``` matches at least one of the ```labels``` from the pod file. The ```selector``` is how the service finds the pod that provides its functionality.

OK, now let's move on to the wordpress service. Open up a new service file:
```bash
$ vi ~/workspace/wordpress/openshift/wordpress-service.yaml
```

and insert:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    name: wordpress
spec:
  ports:
  - port: 8080
  selector:
    name: wordpress
```

Here you may notice there is no reference to the wordpress pod at all. Any pod that provides "wordpress capabilities" can be targeted by this service. Pods can claim to provide "wordpress capabilities" through their labels. This service is programmed to target pods with a label of ```name: wordpress```.

Another example of this might have been if we had made the mariadb-service just a "db" service and then, the pod could be mariadb, mysql, sqlite, anything really, that can support SQL the way wordpress expects it to. In order to do that, we would just have to add a ```label``` to the ```mariadb-pod.yaml``` called "db" and a ```selector``` in the ```mariadb-service.yaml``` (although, an even better name might be ```db-service.yaml```) called ```db```. Feel free to experiment 
with that at the end of this lab if you have time.

Now let's get things going. Start mariadb:
```bash
$ oc create -f ~/workspace/mariadb/openshift/mariadb-pod.yaml
$ oc create -f ~/workspace/mariadb/openshift/mariadb-service.yaml
```

Now let's start wordpress.
```bash
$ oc create -f ~/workspace/wordpress/openshift/wordpress-pod.yaml
$ oc create -f ~/workspace/wordpress/openshift/wordpress-service.yaml
```

OK, now let's make sure everything came up correctly:
```bash
$ oc get pods
$ oc get services
```

**Note** these may take a while to get to a ```RUNNING``` state as it pulls the image from the registry, spins up the containers, etc. 

Eventually, you should see:
```bash
$ oc get pods
NAME        READY     STATUS    RESTARTS   AGE
mariadb     1/1       Running   0          45s
wordpress   1/1       Running   0          42s
```

```bash
$ oc get services
NAME        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
mariadb     172.30.229.10   <none>        3306/TCP   1m
wordpress   172.30.237.62   <none>        8080/TCP     1m
```

Now let's expose the wordpress service by creating a route
```bash
$ oc expose svc/wordpress
```

And you should be able to see the service's accessible URL by viewing the routes:
```bash
$ oc get routes
NAME        HOST/PORT                                        PATH      SERVICES    PORT  
wordpress   wordpress-devel.<YOUR AWS VM PUBLIC IP>.nip.io             wordpress   8080  
```

Check and make sure you can access the wordpress service through the route:
```bash
$ curl -L wordpress-devel.<YOUR AWS VM PUBLIC IP>.nip.io
```

* OR open the URL in a browser to view the UI

Seemed awfully manual and ordered up there, didn't it? In our [next lab](../lab5/chapter5.md) we'll demonstrate how simple deployments can be with OpenShift templates.
