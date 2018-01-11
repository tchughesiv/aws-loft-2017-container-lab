# LAB 1: docker Refresh

In this lab we will explore the docker environment. If you are familiar with docker this may function as a brief refresher. If you are new to docker this will serve as an introduction to docker basics. Don't worry, we will progress rapidly. To get through this lab, we are going to focus on the environment itself as well as walk through some exercises with a couple of docker images/containers to tell a complete story and point out some things that you might have to consider when containerizing your application.

This lab should be performed on **YOUR ASSIGNED AWS VM** as `ec2-user` unless otherwise instructed.

Expected completion: 15-20 minutes

Agenda:

* Review docker and systemd
* Review docker help
* Explore a Dockerfile
* Build an image
* Launch a container
* Inspect a container
* Build docker registry

Perform the following commands as `ec2-user` unless instructed otherwise.

## docker and systemd

Check out the systemd unit file that starts docker and notice that it includes 4 EnvironmentFiles. These files tell docker how the docker daemon, storage and networking should be set up and configured. Take a look at those files too. Specifically, in the /run/containers/registries.conf file check out the registry settings. You may find it interesting that you can `--add-registry` and `--block-registry` by modifying /etc/containers/registries.conf. Think about the different use cases for that.
```bash
$ cat /usr/lib/systemd/system/docker.service
$ cat /run/containers/registries.conf
$ cat /etc/sysconfig/docker
$ cat /etc/sysconfig/docker-storage
$ cat /etc/sysconfig/docker-network
```

Now check on the status of docker.
```bash
$ systemctl status docker
```

## docker Help

Now that we see how the docker startup process works, we should make sure we know how to get help when we need it.  Run the following commands to get familiar with what is included in the docker package as well as what is provided in the man pages. Spend some time exploring here. 

Check out the executables provided:
```bash
$ rpm -ql docker | grep bin
```

Check out the configuration files that are provided:
```bash
$ rpm -qc docker
```

Check out the documentation that is provided:
```bash
$ rpm -qd docker
```

Run `docker {help,info}` to check out the storage configuration and how to find more information. 
```bash
$ docker --help
$ docker run --help
$ docker info
```

Take a look at the docker images on the system. You should see some Openshift images that are cached.
```bash
$ docker images
```

## Let's explore a Dockerfile

Here we are just going to explore a simple Dockerfile. The purpose for this is to have a look at some of the basic commands that are used to construct a docker image. For this lab, we will explore a basic Apache Dockerfile and then confirm functionality.

Change to `~/rh-container-lab/labs/lab1` and `cat` out the Dockerfile
```bash
$ cd ~/rh-container-lab/labs/lab1
$ cat Dockerfile
```
```dockerfile
FROM registry.access.redhat.com/rhel7
MAINTAINER Student <student@example.com>

RUN yum -y install httpd --disablerepo "*" --enablerepo rhel-7-server-rpms
RUN echo "Apache" >> /var/www/html/index.html
RUN echo 'PS1="[apache]#  "' > /etc/profile.d/ps1.sh

EXPOSE 80

# Simple startup script to avoid some issues observed with container restart 
ADD run-apache.sh /run-apache.sh
RUN chmod -v +x /run-apache.sh

CMD [ "/run-apache.sh" ]
```

Here you can see in the `FROM` command that we are pulling a RHEL 7 base image that we are going to build on. Containers that are being built inherit the subscriptions of the host they are running on, so you only need to register the host system.

After gaining access to a repository we update the container and install `httpd`. Finally, we modify the index.html file, `EXPOSE` port 80,which allows traffic into the container, and then set the container to start with a `CMD` of `run-apache.sh`.  

## Build an Image

Now that we have taken a look at the Dockerfile, let's build this image.
```bash
$ docker build -t redhat/apache .
```

## Run the Container

Next, let's run the image and make sure it started.
```bash
$ docker run -dt -p 8080:80 --name apache redhat/apache
$ docker ps
```

Here we are using a few switches to configure the running container the way we want it. We are running a `-dt` to run in detached mode with a psuedo TTY. Next we are mapping a port from the host to the container. We are being explicit here. We are telling docker to map port 8080 on the host to port 80 in the container. Now, we could have let docker handle the host side port mapping dynamically by 
passing a `-p 80`, in which case docker would have randomly assigned a port to the container. Finally, we passed in the name of the image that we built earlier.

Okay, let's make sure we can access the web server.
```bash
$ curl http://localhost:8080
Apache
```

Now that we have built an image, launched a container and confirmed that it is running, lets do some further inspection of the container. We should take a look at the container IP address.  Let's use `docker inspect` to do that.

## Time to Inspect

```bash
$ docker inspect apache
```

We can see that this gives us quite a bit of information in json format. We can scroll around and find the IP address, it will be towards the bottom.

Let's be more explicit with our `docker inspect`
```bash
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache
```

You can see the IP address that was assinged to the container.

We can apply the same filter to any value in the json output. Try a few different ones.

Now lets look inside the container and see what that environment looks like. Execute commands in the namespace with `docker exec <container-name OR container-id> <cmd>`
```bash
$ docker exec -it apache bash
```

Now run some commands and explore the environment. Remember, we are in a slimmed down container at this point - this is by design. You may find yourself restricted.
```bash
[apache]# ps aux
[apache]# ls /bin
[apache]# cat /etc/hosts
[apache]# ip addr
bash: ip: command not found
```

The last command failed, what can we do?  You can install software into this container.
```bash
[apache]# yum -y install iproute --disablerepo "*" --enablerepo rhel-7-server-rpms
[apache]# ip addr
```

Exit the container namespace with `CTRL+d` or `exit`.

Whew, so we do have some options. Now, remember that this lab is all about containerizing your existing apps. You will need some of the tools listed above to go through the process of containerizing your apps. Troubleshooting problems when you are in a container is going to be something that you get very familiar with.

Before we move on to the next section let's clean up the apache container so we don't have it hanging around.
```bash
$ docker rm -f apache
```

## Deploy a Container Registry

To prepare for a later lab, let's deploy a simple registry to store our images.

Inspect the Dockerfile that has been prepared.
```bash
$ cat registry/Dockerfile
```

Build & run the registry
```bash
$ docker build -t registry registry/
$ docker run --restart="always" --name registry -p 5000:5000 -d registry
```

Confirm the registry is running.
```bash
$ docker ps
```

In the [next lab](../lab2/chapter2.md) we will be analyzing a monolithic application.
