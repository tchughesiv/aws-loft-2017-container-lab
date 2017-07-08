#!/bin/bash
# Service Catalog
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
