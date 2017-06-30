## Introduction

In this lab, we are going to leverage a process known as [`oc cluster up`](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md). This enables us to quickly stand up a local OpenShift Container Platform to start our evaluation. The key result of `oc cluster up` is a reliable, reproducible OpenShift environment to iterate on.

This lab should be performed on **YOUR ASSIGNED AWS VM** as `ec2-user` unless otherwise instructed.

Expected completion: 5-10 minutes

## Getting Set Up
For the sake of time, much of the required setup has already been taken care of on your lab VM. For future reference though, the easiest way to get started is to head over to the OpenShift Origin repo on github and follow the "[cluster up and down instructions](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md)" instructions. The instructions cover getting started on Windows, MacOS, and Linux. 

All that's left to do is run OpenShift by executing the `start-oc.sh` script in your home directory. First, let's take a look at what this script is doing:
```bash
$ cat ~/start-oc.sh
```
Now, let's start our local, containerized OpenShift environment:
```bash
$ ~/start-oc.sh
# resulting output should be something of this nature
   The server is accessible via web console at:
       https://<public-hostname>:8443

   You are logged in as:
       User:     developer
       Password: developer
```
You should get a lot of feedback about the launch of OpenShift. As long as you don't get any errors you are in good shape.

OK, so now that OpenShift is available, let's ask for a cluster status & take a look at our running containers:
```bash
$ oc cluster status
$ docker ps
```
We can also check out the OpenShift console. Open a browser and navigate to `https://<public-hostname>:8443`. Once it loads (and you bypass the certificate error), you can log in to the console using the default developer username/password.

## Lab Materials

We've already used git to clone the lab repo with the following commands.
```bash
$ cd ~/
$ git clone https://github.com/tchughesiv/aws-loft-2017-container-lab
```

## OpenShift Container Platform

What is OpenShift? OpenShift, which you may remember as a "PaaS" to build applications on, has evolved into a complete container platform based on Kubernetes. If you remember the "DIY Cartridges" from older versions of Openshift, essentially, OpenShift v3 has expanded the functionality to provide complete containers. With OpenShift, you can build from a platform, build from scratch, whatever you can do in a container, and still get the complete lifecycle automation you loved in the older versions.

You are now ready to move on to the [next lab](../lab1/chapter1.md).
