#!/bin/bash
NODES=$1
if [ "x$NODES" = "x" ]; then
    echo 'SELECT ip FROM active_nodes WHERE active = 1 AND ip NOT LIKE "temp%" ORDER BY ip' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2
elif [ "$NODES" = "ALL" ]; then
    echo 'SELECT ip FROM active_nodes WHERE ip NOT LIKE "temp%" ORDER BY ip' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2
else
    echo $NODES | sed -e 's/ /\n/g'
fi
