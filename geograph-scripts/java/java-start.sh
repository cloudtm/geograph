#!/bin/bash
if [ $# -gt 0 ]; then
    IPS=$*
else
    IPS=`./info/get-active-node-ips.sh`
fi

for ip in $IPS; do
    BOTH=`echo 'SELECT geograph AND farm FROM active_nodes WHERE IP = "'$ip'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
    GEOGRAPH=`echo 'SELECT geograph FROM active_nodes WHERE IP = "'$ip'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
    FARM=`echo 'SELECT farm FROM active_nodes WHERE IP = "'$ip'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
    if [ $BOTH -eq 1 ]; then
        ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$ip "sh -c 'cd /opt/geograph && ./script/prod_launch.sh >ssh.out 2>&1 &'" &
        echo "(Re)starting $ip (geograph, wpm and farm)"
    elif [ $GEOGRAPH -eq 1 ]; then
        ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$ip "sh -c 'cd /opt/geograph && ./script/prod_launch.sh geograph wpm  >ssh.out 2>&1 &'" &
        echo "(Re)starting $ip (geograph and wpm)"
    elif [ $FARM -eq 1 ]; then
        ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$ip "sh -c 'cd /opt/geograph && ./script/prod_launch.sh farm vmstat  >ssh.out 2>&1 &'" &
        echo "(Re)starting $ip (only farm)"
    fi
    sleep 2s
done

