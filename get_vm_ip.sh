#!/bin/bash
/var/lib/snapd/snap/bin/doctl auth init --access-token $DIGI_TOKEN > /dev/null 2>&1

/var/lib/snapd/snap/bin/doctl compute droplet list | grep ansible | awk '{print $3}'
