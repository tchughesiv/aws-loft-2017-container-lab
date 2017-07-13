Date: 7/13/2017
Authors: vvaldez, tohughes, scollier

This lab requires an AWS instance per student to be set up.

In the scripts directory, there are a couple of files to be aware of:

../scripts/aws-cli/
aws-loft-list.json  # this is output of the loft-list script
loft-launch  # deploys AWS instances per input that it takes from the vars file.
loft-list # queries the AWS API to get a list of instances and it's output is the aws-loft-list.json file which gets copied to the loft-server that is already running. 
vars # provides input information for loft-launch, you can change the number of VMs that you want to launch, and you can change how they are tagged so it is custom to the person launching for testing purposes.

