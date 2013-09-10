#!/bin/bash
. ~/.openrc.sh
for i in `seq 1 $1`; do
    echo Deleting geo-cluster-$i
    echo 'DELETE FROM active_nodes WHERE hostname = "geo-cluster'$i'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
    nova delete geo-cluster-$i
    sleep 20s
done
