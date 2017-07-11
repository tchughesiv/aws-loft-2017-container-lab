
## Introduction

In this lab, we are going to leverage a process known as [`oc cluster up`](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md). This enables us to quickly stand up a local OpenShift Container Platform to start our evaluation. The key result of `oc cluster up` is a reliable, reproducible OpenShift environment to iterate on.

Expected completion: 5-10 minutes

## Setup Environment
If you don't already have a docker hub account, you'll need one for this lab. Sign up here: 
[https://hub.docker.com/](https://hub.docker.com/)

Cleanup the previous labs
```bash
$ ~/cleanup-oc.sh
```

Setup `pip` for `python`
```bash
$ curl https://bootstrap.pypa.io/get-pip.py | sudo python -
```

Install virtualenv as this is tech preview and not available in the official repositories yet
```bash
$ cd ~/ && virtualenv --clear --system-site-packages ansible
$ sudo pip install virtualenv
```

Install the latest version of Ansible
```bash
$ source ~/ansible/bin/activate
$ pip install -U docker ansible
```

Setup the Catalogue Service Broker
```bash
$ git clone https://github.com/tchughesiv/catasb
$ cd catasb/local/linux/
$ git checkout aws-loft
./run_setup_local.sh
```

Enter personal docker hub user/pass and use `ansibleplaybookbundle` for org.

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

To interact w/ new cluster via command line -
```bash
$ source ~/ansible/bin/activate
$ export PATH=~/bin:$PATH
$ oc version
oc v3.6.136
kubernetes v1.6.1+5115d708d7
features: Basic-Auth GSSAPI Kerberos SPNEGO

#$ oc login -u developer -p developer
#$ oc login -u admin -p admin
$ oc cluster status
Web console URL: https://ec2-xx.xx.xxx.xx.us-west-1.compute.amazonaws.com:8443
```

TODO: ask student to login as developer & go through guided tour on right menu first...

TODO: have them do hello-world apb deploy... view site landing page... then have them run postgres apb w/ bind to hello-world app.  redeploy hello-world & show same landing page w/ postgres connection showing.

TODO: explore on their own ... maybe logout and back in as admin?
