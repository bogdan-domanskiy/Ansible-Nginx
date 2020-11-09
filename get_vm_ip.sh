#!/bin/bash
/usr/local/bin/doctl auth init --access-token $DIGI_TOKEN > /dev/null 2>&1

/usr/local/bin/doctl compute droplet list | grep ansible | awk '{print $3}'
#  export DIGI_VM_IP=`/usr/local/bin/doctl compute droplet list | grep ansible | sed -e 's/   //g'| cut -d " " -f 3`
