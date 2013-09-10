#!/bin/bash
. ~/.openrc.sh
if [ $# -ne 1 ]; then
    echo "Usage: $0 <hostname>"
    exit -1
fi

echo Deleting $1
echo 'DELETE FROM active_nodes WHERE hostname = "'$1'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
nova delete $1
echo -n "Waiting for 20 seconds..."
for i in `seq 1 10`; do
    sleep 20s
    echo -n "."
done
echo "OK"
