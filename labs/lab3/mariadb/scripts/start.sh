#!/bin/bash
set -eux

MYDIR=$(dirname $0)

# Perform configurations
$MYDIR/config_mariadb.sh

# Start apache in the foreground
/usr/bin/mysqld_safe
