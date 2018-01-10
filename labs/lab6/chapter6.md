## Introduction

In this lab, we are going to build upon the previous labs and leverage what we have learned to utilize the OpenShift service broker. As part of this process, we will be using the latest upstream code available for this project. To start out, you will provision a clean OpenShift environment that has the tech preview service broker interface.  By the time you are finished with the lab, you will have deployed an application, a database and binded the two together.  It should become evident how this self service process can improve the productivity of developers on your team.

Expected completion: 10-20 minutes

## Setup Environment
If you don't already have a docker hub account, you'll need one for this lab. Sign up here: 
[https://hub.docker.com/](https://hub.docker.com/)

We are going to reset the environment to proceed with this chapter. Cleanup the previous labs.

```bash
$ ~/cleanup-oc.sh
```

Install a newer version of Ansible.

```bash
$ sudo easy_install pip
$ sudo pip install ansible
```

Fix some package conflicts.

```bash
$ sudo yum erase python-docker-py 
$ sudo yum install python2-docker
```

Setup the Service Catalog & Broker by cloning the catasb git repo. 

```bash
$ cd
$ git clone https://github.com/fusor/catasb.git 
$ git checkout 57da46b60462694c6b193b6b47a18c2ed50d4832
```
The first step is to set up the environment variables.

```bash
$ cd catasb/config
```

The `linux_env_vars` file should look like the following.

```bash
metadata_endpoint="http://169.254.169.254/latest/meta-data"
export PUBLIC_IP="$( curl -m 20 -s "${metadata_endpoint}/public-ipv4" )"
export OPENSHIFT_HOSTNAME="$( curl -m 20 -s "${metadata_endpoint}/public-hostname" )"
export OPENSHIFT_ROUTING_SUFFIX="${PUBLIC_IP}.nip.io"
export EXTRA_VARS="{\"openshift_hostname\":\"${OPENSHIFT_HOSTNAME}\", \"openshift_routing_suffix\":\"${OPENSHIFT_ROUTING_SUFFIX}\" }"
```

Run the setup script. For this part to work, you `MUST` have an account on Docker hub: https://hub.docker.com/.  Also, when it prompts you for the Docker Org., use `ansibleplaybookbundle`.  More about that Docker Org can be found here: https://hub.docker.com/r/ansibleplaybookbundle/

_NOTE: When prompted, enter your personal docker hub user/pass._
```bash
$ cd ~/catasb/local/linux
$ ./run_setup_local.sh
```

The `./run_setup_local.sh` deploys a new OpenShift environment.  The difference between this enviornment and the OpenShift environment we provisioned in Chapter 0, is that this is using newer code from [OpenShift Origin](https://github.com/openshift/origin), which contains tech preview features for the service catalog. It also installs the ansible service broker. Welcome to the latest code.

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

**NOTE**: If you have any issues, you can rerun these steps to try again via the script in `~./rh-container-lab/labs/lab6/scripts/chapter6-setup`

## Login
As usual, you can interact with the OpenShift API via the `oc` CLI or the web based UI.

To interact w/ new cluster via command line -

```bash
$ export PATH=~/bin:$PATH
$ oc version
oc v3.6.x
```

**NOTE**: Please stop and flag an instructor if your versions are lower than the ones listed.

Now login with the developer user and check things out.

```bash
$ oc login -u developer
$ oc get all
$ oc projects
```

Now log in with the `admin` user. You can switch projects, browse around.

```bash
$ oc login -u system:admin
$ oc get all -n service-catalog
$ oc projects
```

Now get the URL for the web console for your AWS VM by checking the cluster status.  The web console URL is listed as part of the output.
```bash
$ oc cluster status
Web console URL: https://<YOUR AWS PUBLIC HOSTNAME>:8443
```

Login to the web console with the `developer` user and click through the `Take Home Page Tour` that is listed on the right navigation panel. That will quickly walk you through a few steps to show you what some of the capabilities of the Catalog UI are.

## Deploy Ansible Playbook Bundle Application
Now, we are going to deploy our first application using the new interface. 

- In the middle navigation panel, click on `all` and then click on the `Hello World (APB)` application.
- On the right hand side of the pop-up window, click the dropdown under `Add to Project` and select `Create Project`.
- Give the project a name `hello-world-apb`.  Leave the rest of the options as default and click `Create`.
- Now you will notice that the service is being provisioned.  Click on the `View Project` button. This will take you to the new project namespace that was created when we made the application.
- Give the project a minute or so to finish, and in the upper right hand side, you will see a new URL that points to your application.  Click on that and it will open a new tab.
- Go back to the project, explore the environment, view logs, look at events, scale the application up, deploy it again, etc...
- Now go back to your CLI and explore what was just created.

```bash
$ oc get projects | grep hello
hello-world-apb                         Active
```

Switch to that project and look at what was created.

```bash
$ oc project hello-world-apb
$ oc get all
$ oc status
```

## Create Database
Now that we have deployed an application, you'll notice that when you clicked on the application and opened it up in a new window, it doesn't have a data connection. Let's add one.
- In the upper left navigation pane in the web console, click `Home`.
- On right hand navigation pane, click the `hello-world-apb` project.

Now you are back to the screen that has the URL to the application in the top right.  Click that again. You'll notice that the database information all says `No database connected`.  Let's create a database and then bind from the hello-world-apb app.

- Return to the OpenShift web console.
- In the upper navigation pane in the hello-world-apb project page, click `Add to Project`, select `Browse Catalog`.
- Select the `PostgreSQL (APB)` database from the catalog.
- Select the `Development` Plan, click next.
- Select `hello-world-apb` project in the drop-down.
- Do not enter a password, one will be generated for you.
- Select PostgreSQL version of 9.5.
- Click `Next`
- Click `Create`.  Do not bind at this time.
- Click `View Project`.
- Once PostgreSQL is provisioned, you'll see both the `hello-world-apb` and the `postgresql` applications.  This may take a minute or so.

## Bind Application to Database
- On the `hello-world` application, on the far right hand side, click the three dots `...` and click `Create Binding`. 
- Select the `PostgreSQL` database.
- Click `Bind`.
- Click `Close`.
- Now that the bind is created, you need to redeploy your application so it can consume the secrets that were just created, and attach to the database.
- Once again, click on the three dots `...` and now click `Deploy`.  This will launch a new version of your application.
- Let's look at the newly created secret by clicking `Resources` on the left menu and then `Secrets`. The newest secret should be at the top of the list. Click on the newest secret and reveal the password that was automatically generated.
- Return to the Project Overview page by clicking `Overview` on the left menu.
- Once the new deployment is finished, go back to the hello-world application url and refresh.  Now you should see PostgreSQL information populated.

This concludes the lab. To summarize, we started out with Docker basics as a review, built a large monolithic application and then decomposed it.  Next we automated the deployment of that application using OpenShift templates.  Finally, we experimented with the new service broker technology and the new OpenShift console.  All of this while evaluating technologies like Red Hat Enterprise Linux, OpenShift, running on instnaces hosted on AWS.

Please feel free to share this lab and contribute to it.  We love contributions.
