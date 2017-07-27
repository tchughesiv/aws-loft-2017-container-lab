#!/bin/bash
# CLEANUP
oc cluster down
docker rm -vf $(docker ps -aq)
docker volume rm $(docker volume ls -q)
findmnt -lo target | grep "/var/lib/origin/openshift.local." | xargs sudo umount
sudo rm -rf /var/lib/origin/openshift.local.*
