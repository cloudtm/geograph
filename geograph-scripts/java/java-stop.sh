#!/bin/bash
IPS=`./info/get-active-node-ips.sh ALL`
for ip in $IPS; do
    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$ip 'killall -9 java'
    echo "Stopped java on $ip"
done

