~/asb-oc.sh
```bash
#!/bin/bash
~/cleanup-oc.sh
sudo yum -y install gcc python-devel openssl-devel
curl https://bootstrap.pypa.io/get-pip.py | sudo python -
sudo pip install virtualenv
cd ~/ && virtualenv --clear ansible
source ~/ansible/bin/activate
pip install -U docker ansible
git clone https://github.com/tchughesiv/catasb
cd catasb/local/linux/
git checkout aws-loft
./run_setup_local.sh
```
at prompt...

enter personal docker hub user/pass and use `ansibleplaybookbundle` for org.

To interact w/ new cluster via command line -
```bash
$ source ~/ansible/bin/activate
$ export PATH=~/bin:$PATH
$ oc version
oc v3.6.136
kubernetes v1.6.1+5115d708d7
features: Basic-Auth GSSAPI Kerberos SPNEGO

$ oc login -u developer -p developer
$ oc cluster status
Web console URL: https://ec2-xx.xx.xxx.xx.us-west-1.compute.amazonaws.com:8443
```
