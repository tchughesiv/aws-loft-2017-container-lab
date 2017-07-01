#!/bin/bash
set -eux

MYDIR=$(dirname $0)

# Perform configurations
$MYDIR/config_wordpress.sh

# Start apache in the foreground
/usr/sbin/httpd -D FOREGROUND
