## Introduction

In this lab, we are going to build upon the previous labs and leverage what we have learned to utilize the OpenShift Ansible Service Broker. As part of this process, we will be using the latest upstream release available for this project. By the time you are finished with the lab, you will have deployed an application, a database and binded the two together. It should become evident how this self service process can improve the productivity of developers on your team.

Expected completion: 10-20 minutes

## Setup Environment
First, free up some resources:
```bash
$ oc delete project devel production
```

The `./run_latest_build.sh` deploys the Ansible Broker to your existing OpenShift environment.
```bash
$ cd ~/rh-container-lab/labs/lab6/scripts/
$ ./run_latest_build.sh
```

A successful deployment will end with output similar to:
```bash
Signature ok
subject=/CN=client
Getting CA Private Key
service "asb" created
service "asb-etcd" created
serviceaccount "asb" created
clusterrolebinding "asb" created
clusterrole "asb-auth" created
clusterrolebinding "asb-auth-bind" created
clusterrole "access-asb-role" created
persistentvolumeclaim "etcd" created
deploymentconfig "asb" created
deploymentconfig "asb-etcd" created
secret "asb-auth-secret" created
secret "registry-auth-secret" created
secret "etcd-auth-secret" created
secret "broker-etcd-auth-secret" created
configmap "broker-config" created
serviceaccount "ansibleservicebroker-client" created
clusterrolebinding "ansibleservicebroker-client" created
```

Verify the rollout is successful before proceeding.
```bash
$ oc rollout status -w dc/asb
$ oc get all
$ oc logs dc/asb
```

You are now logged in with the `admin` user. You can switch projects, browse around.
```bash
$ oc get all -n kube-service-catalog
$ oc get projects
```

Now log back in with the developer user.
```bash
$ oc login -u developer
$ oc get all
$ oc get projects
```


Now get the URL for the web console for your AWS VM by checking the cluster status. The web console URL is listed as part of the output. Be sure to refresh your browser.
```bash
$ oc cluster status
Web console URL: https://<YOUR AWS PUBLIC HOSTNAME>:8443
```

## Deploy an Ansible Playbook Bundle Application
Now, we are going to deploy our first application using the ansible broker. 

- In the middle navigation panel, click on `All` and then click on the `Hello World (APB)` application.
- Click `Next`.
- Click the dropdown under `Add to Project` and select `Create Project`.
- Give the project a name `apb`.  Leave the rest of the options as default and click `Create`.
- Now you will notice that the service is being provisioned. Click on the `Continue to the project overview` button. This will take you to the new project namespace that was created when we made the application.
- Give the deployment a minute or so to finish, and in the upper right hand side, you will see a new URL that points to your application.  Click on that and it will open a new tab.
- Go back to the project, explore the environment, view logs, look at events, scale the application up, deploy it again, etc...
- Now go back to your CLI and explore what was just created.

```bash
$ oc get projects
NAME        DISPLAY NAME   STATUS
apb                        Active
```

Switch to that project and look at what was created.

```bash
$ oc project apb
$ oc get all
$ oc status
```

## Create Database
Now that we have deployed an application, you'll notice that its database information says `No database connected`.  Let's create a database and then bind from the hello-world app.

- Return to the OpenShift web console.
- In the upper right part of the page, click `Add to Project` and then `Browse Catalog`.
- Select the `PostgreSQL (APB)` database from the catalog.
- Click `Next`.
- Select the `Development` Plan and click `Next`.
- Select `apb` project in the drop-down.
- Enter a password.
- Select a PostgreSQL version.
- Click `Next`
- Click `Create`. Do not bind at this time.
- Click on the `Continue to the project overview`.
- Once PostgreSQL is provisioned, you'll see both the `hello-world` and the `postgresql` applications.  This may take a minute or so.

## Bind Application to Database
- At the bottom of the project overview page, you should see a set of our newly provisioned services.
- On the `PostgreSQL (APB)` service, click `Create Binding`. 
- Select the `PostgreSQL` database.
- Click `Bind`.
- Click `Close`.
- Let's look at the newly created secret by clicking `Resources` on the left menu and then `Secrets`. The newest secret should be at the top of the list. Click on the newest secret and reveal its contents.
- Now let's bind the application to our database by clicking `Add to Application` in the upper right corner.
- Select the `hello-world` app from the drop-down and click `Save`.
- Return to the Project Overview page by clicking `Overview` on the left menu.
- Once the new deployment is finished, go back to the hello-world application url and refresh. Our application is now connected to the DB as evidenced by the populated PostgreSQL information.

This concludes the lab. To summarize, we started out with Docker basics as a review, built a large monolithic application and then decomposed it.  Next we automated the deployment of that application using OpenShift templates. Finally, we experimented with the new service broker technology.

Please feel free to share this lab and contribute to it.  We love contributions.
