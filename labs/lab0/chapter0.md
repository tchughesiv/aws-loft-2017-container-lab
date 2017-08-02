## Introduction

In this lab, we are going to leverage a process known as [`oc cluster up`](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md). This enables us to quickly stand up a local OpenShift Container Platform to start our evaluation. The key result of `oc cluster up` is a reliable, reproducible OpenShift environment to iterate on.

Expected completion: 5-10 minutes

## Find your AWS Instance
This lab is designed for AWS Loft and can accomodate 100 students. For ease of keeping track please edit the following spreadsheet to claim an instance:
http://bit.ly/NYCAWSLoft

**_NOTE_**: Please be considerate and only modify empty fields in the D (**_Claimed By_**) column. Use anything to uniquely identify you, but no personal information is required.

Download the [private key](http://server.aws-loft.sysdeseng.com/aws-key.pem)
```bash
$ curl -O http://server.aws-loft.sysdeseng.com/aws-key.pem
$ chmod  600 aws-key.pem
```

## Connecting to your AWS Instance
This lab should be performed on **YOUR ASSIGNED AWS INSTANCE** as `ec2-user` unless otherwise instructed.

Connect to **_YOUR_** AWS Instance as per the table mentioned above that corresponds to your student number.

**_NOTE_**: Please be respectful and only connect to your assigned instance. Every instance for this lab uses the same public key so you could accidentally (or with malicious intent) connect to the wrong system. If you have any issues please inform an instructor.
```bash
$ ssh -i aws-key.pem ec2-user@<YOUR AWS VM PUBLIC DNS NAME HERE>
```

**NOTE**: For Windows users you will have to use a terminal like [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) to SSH using the private key. You will need to download the key and convert it using PuTTYGen, for details see: [PuTTY Configuration](windows.md)

## Getting Set Up
For the sake of time, much of the required setup has already been taken care of on your lab VM. For future reference though, the easiest way to get started is to head over to the OpenShift Origin repo on github and follow the "[cluster up and down instructions](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md)" instructions. The instructions cover getting started on Windows, MacOS, and Linux.

Since some of these labs will have long running processes, it is recommended to use something like `tmux` or `screen` in case you lose your connection at some point so you can reconnect:
```bash
$ sudo yum -y install screen
$ screen
```

In case you get disconnected use `screen -x` to reattach once you reestablish ssh connectivity.

All that's left to do is run OpenShift by executing the `start-oc.sh` script in your home directory. First, let's take a look at what this script is doing:
```bash
$ cat ~/start-oc.sh
```
Now, let's start our local, containerized OpenShift environment:
```bash
$ ~/start-oc.sh
```

The resulting output should be something of this nature
```bash
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
$ docker images
```
We can also check out the OpenShift console. Open a browser and navigate to `https://<public-hostname>:8443`. Once it loads (and you bypass the certificate error), you can log in to the console using the default developer username/password.

## Lab Materials

Clone the lab repository from github:
```bash
$ cd ~/
$ git clone https://github.com/tchughesiv/aws-loft-2017-container-lab
```

## OpenShift Container Platform

What is OpenShift? OpenShift, which you may remember as a "PaaS" to build applications on, has evolved into a complete container platform based on Kubernetes. If you remember the "DIY Cartridges" from older versions of Openshift, essentially, OpenShift v3 has expanded the functionality to provide complete containers. With OpenShift, you can build from a platform, build from scratch, whatever you can do in a container, and still get the complete lifecycle automation you loved in the older versions.

You are now ready to move on to the [next lab](../lab1/chapter1.md).
