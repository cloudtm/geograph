#!/bin/bash
SPAWNING=1
while [ $SPAWNING -ne 0 ]; do
    SPAWNING=`echo 'SELECT COUNT(*) FROM active_nodes WHERE ip LIKE "temp%"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
    if [ $SPAWNING -ne 0 ]; then
        echo The following nodes are still spawning:
        SPAWNING_NODES=`echo 'SELECT hostname FROM active_nodes WHERE ip LIKE "temp%"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
        echo $SPAWNING_NODES
        echo --
        sleep 5s
    fi
done
