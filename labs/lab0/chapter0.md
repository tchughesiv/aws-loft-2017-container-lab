## Introduction

In order to make this lab simple to work with, we are going to leverage a process known as `oc cluster up`. `oc cluster up` [oc cluster up](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md) enables us to quickly stand up an OpenShift Container Platform to start our evaluation. Please refer to the link provided for more information about how to get started with `oc cluster up`. 

The key feature of `oc cluster up` is a reliable, reproducible environment to iterate on. If you are unfamiliar with `oc cluster up` that is OK, as we will cover the basics here. 

## Getting Set Up

In order to get started, the easiest way is to head over to github.com and follow the "[cluster up and down instructions](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md)" instructions. The instructions cover getting started on Windows, MacOS, and Linux. 

## Lab Materials

We used git to clone the repo with the following commands.

```bash
$ cd ~/
$ git clone https://github.com/tchughesiv/aws-loft-2017-container-lab
```

## `oc cluster up` Walkthrough

Your major units of operation with minishift are `minishift start`, `minishift ssh`, 
`minishift docker-env`, and `minishift stop`. We will walk through these. 
Minishift has a number of other functions, some of which we will use later in the lab. However, these are the basics which warrant some examples to make sure you have enough context for the rest of the labs. We also need to get you access to the docker daemon running inside the minishift VM for the "Docker Refresh" in Lab 1.  

Before we begin, you need to configure the CDK for proper operation using `minishift setup-cdk`. You have a number of options here like choosing your hypervisor, config file location, etc. Covering these in detail is beyond the scope of this lab and is well documented with `minishift setup-cdk --help` or in the documentation linked above. For 
the in-person lab we have already performed this step for you.

Now to really start, `minishift start`: this command asks your hypervisor to launch the virtual machine minishift has prepared. The operation may be a "create and launch VM" or a "re-launch an existing VM" and it is largely transparent to the user. 
 
OK, so, let's move in to our project directory and then launch minishift:

```bash
$ cd ~/summit-2017-container-lab
$ minishift start --skip-registration
```

**NOTE** If you following this lab at home, you should run just `minishift start`
        and register with Red Hat. Otherwise, you may not have access to all the 
        content used later in the lab(s). We can bypass it in the physical lab because 
        we have the content replicated in the lab room.

You should get a lot of feedback about the launch of the VM but, if you are 
using the lab VM or have run this before, you will get a lot less. As long 
as you don't get any errors you are in good shape.

OK, so now minishift is running which means docker and OpenShift are available. We can now ask for the status (it's succinct!):

```bash
$ minishift status
Running
```

Now we can actually step inside the machine with:

```bash
$ minishift ssh
Last login: Mon Feb 30 17:49:01 2017 from 192.168.??.??
[docker@minishift ~]$ 
```

You should very rarely need to jump inside the VM as most of the functions of docker and OpenShift can be done remotely. However, it can be really nice to know that you don't need to figure out the IP address or the username and password in case you have to get in there when something goes wrong. That said, most of the time the right answer is to just destroy the instance and recreate it.

Now exit out of the minishift VM by disconnecting from the SSH session:

```bash
$ exit
```

We have two more commands worth mentioning. First off, let's mention `minishift stop`. Stop does exactly what it sounds like and shuts down minishift. However, it does not destroy anything inside just "turns the machine off." If you do want to remove the VM, you can use `minishift delete`. You can spin it right back up again, fresh, with `minishift start`. Finally, we will use `minishift docker-env` in a few minutes to connect the host to the docker daemon in the VM.

## Container Development Kit (CDK) Walkthrough

When we started minishift, we launched the software tooling component of the CDK. As we said before, the CDK provides a lot of support for containerizing your applications. However, the major software tool is minishift.

However, what is minishift? Essentially, it is a simple to use and launch instance of the 
same OpenShift you would use at work. OpenShift, which you may remember as a PAAS providing "platforms" to build applications on, has evolved to be a complete container management solution. If you remember the "DIY Cartridges" from older versions of Openshift, essentially, OpenShift v3 has expanded the functionality to provide complete containers. Now, with OpenShift, you can build from a platform, build from scratch, whatever you can do in a container, and still get the complete lifecycle automation you loved in the older versions.

If you would like to explore the OpenShift Console, you can see it running 
in your OpenShift instance, if you open a browser. However, before we do that, we need the IP address of the VM minishift created. Easy enough, just run

```bash
$ minishift ip
192.168.???.??? 
```
Ok, now we can check out the OpenShift console. Open Firefox from the Applications menu and navigate to `https://<ip>:8443/console/`(replace "<ip>" with the address from the last command). Once it loads (and you bypass the bad certificate error), you can log in to the console using the default `developer/developer` username/password.

## Setting Up For the Remaining Labs

Let's wrap up the walkthroughs by and set up for the next lab sections we'll go ahead and bring up another VM. In this case, we are launching an instance of Red Hat Enterprise Linux Atomic Host that will set up and run OpenShift during launch.
This box will be known as **atomic-host.example.com** for the purposes of
this lab and will have the IP address `192.168.124.100` but you should always be able to reference it by DNS name.

```bash
$ virsh start atomic-host
```

After you bring up this new machine you are then ready to move on to the
[next lab](../lab1/chapter1.md).
