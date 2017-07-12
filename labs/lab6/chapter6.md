
## Introduction

In this lab, we are going to build upon the previous labs and leverage what we have learned to utilize the OpenShift service broker. As part of this process, we will be using the latest code available for this project. To start out, you will provision a clean OpenShift environment that has the tech preview service broker interface.  By the time you are finished with the lab, you will have deployed an application, a database and binded the two together.  It should become evident how this self service process can improve the productivity of developers on your team.

Expected completion: 5-10 minutes

## Setup Environment
If you don't already have a docker hub account, you'll need one for this lab. Sign up here: 
[https://hub.docker.com/](https://hub.docker.com/)

We are going to reset the environment to proceed with this chapter. Cleanup the previous labs.

```bash
$ ~/cleanup-oc.sh
```

Setup `pip` for `python`

```bash
$ curl https://bootstrap.pypa.io/get-pip.py | sudo python -
```

Install virtualenv as this is tech preview and not available in the official repositories yet.  Once the code matures a bit, we'll use rpms to provision the software.

```bash
$ sudo pip install virtualenv
$ cd ~/ && virtualenv --clear --system-site-packages ansible
```

Install the latest version of Ansible.

```bash
$ source ~/ansible/bin/activate
$ pip install -U docker ansible
```

Setup the Catalogue Service Broker by cloning our git repo and checking out our aws-loft branch.

```bash
$ git clone https://github.com/tchughesiv/catasb
$ cd catasb/local/linux/
$ git checkout aws-loft
./run_setup_local.sh
```

NOTE: Enter personal docker hub user/pass and use `ansibleplaybookbundle` for org.

The `./run_setup_local.sh` deploys a new OpenShift environment.  The difference between this enviornment and the OpenShift environment we provisioned in Chapter 0, is that this is using newer code which contains tech preview support for the service broker.  Welcome to the latest code.

A successful deployment will end with output similar to:

```bash
TASK [debug] *********************************************************************************************************************
ok: [localhost] => {
    "msg": [
        "Hostname:                  <YOUR PUBLIC DNS HOSTNAME>
        "Next steps:",
        "Visit https://<YOUR PUBLIC DNS HOSTNAME>:8443 for the web console",
        "OR",
        "For CLI access:",
        "oc login --insecure-skip-tls-verify <YOUR PUBLIC DNS HOSTNAME>:8443 -u <USERNAME> -p <PASSWORD>",
        ""
    ]
}

PLAY RECAP ***********************************************************************************************************************
localhost                  : ok=61   changed=28   unreachable=0    failed=0
```

As usual, you can interact with the OpenShift API via the `oc` CLI or the web based UI.

To interact w/ new cluster via command line -

```bash
$ source ~/ansible/bin/activate
$ export PATH=~/bin:$PATH
$ oc version
oc v3.6.136
kubernetes v1.6.1+5115d708d7
features: Basic-Auth GSSAPI Kerberos SPNEGO
```

Now login with both the developer user and the admin user, switch around - check things out.

```bash
$ oc login -u developer -p developer
$ oc get all
$ oc project
$ oc logout
$ oc project
```

Now log in with the `admin` user. You can switch projects, browse around.

```bash
$ oc login -u admin -p admin
$ oc get all
$ oc project
```

Now get the URL for the web console for your AWS VM by checking the cluster status.  The web console URL is listed as part of the output.
```bash
$ oc cluster status
Web console URL: https://ec2-xx.xx.xxx.xx.us-west-1.compute.amazonaws.com:8443
```

Open the web console and take the `Take Home Page Tour` that is listed on the right navigation panel. That will quickly walk you through 5 steps to show you what some of the capabilities of the UI are.

Now, we are going to deploy our first application using the new inteface. 

In the middle navigation panel, click on `all` and then click on the `hello-world-apb` application.
On the right hand side of the pop-up window, click the dropdown under `Add to Project` and select `Create Project`.
Give the project a name `hello-world-apb`.  Leave the rest of the options as default and click `Create`.
Now you will notice that the service is being provisioned.  Click on the `View Project` button. This will take you to the new project namespace that was created when we made the application.
Give the project a minute or so to finish, and in the upper right hand side, you will see a new URL that points to your application.  Click on that and it will open a new tab.
Go back to the project, explore the environment, view logs, look at events, scale the application up, deploy it again, etc...
Now go back to your CLI and explore what was just created.

```bash
$ oc get projects | grep hello
hello-world-apb                         Active
```

Switch to that project and look at what was created.

```bash
$ oc project hello-world-apb
$ oc get all
```

Now that we have deployed an application, you'll notice that when you clicked on the application and opened it up in a new window, it doesn't have any data.  Go back and find it.
- In the upper left navigation pane in the web console, click `Home`.
- On right hand navigation pane, click the `hello-world-apb` project.
- Now you are back to the screen that has the URL to the application in the top right.  Click that again. You'll notice that the database server says `None`.  It is all empty.  Let's create a database server and bind to the hello-world-apb app.



TODO: have them do hello-world apb deploy... view site landing page... then have them run postgres apb w/ bind to hello-world app.  redeploy hello-world & show same landing page w/ postgres connection showing.




TODO: explore on their own ... maybe logout and back in as admin?
