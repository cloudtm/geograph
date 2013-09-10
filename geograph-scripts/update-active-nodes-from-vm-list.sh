#!/bin/bash
if [ $# -ne 1 ]; then
	echo "Usage: $0 <vm-list>"
	exit -1
fi

echo 'DELETE FROM active_nodes' | mysql -u$DATABASE_USERNAME -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
while read l; do
	hostname=`echo "$l" | awk '{ print $1 }'`
	ip=`echo "$l" | awk '{ print $2 }'`
	echo "IP=$ip, hostname=$hostname."
	echo 'INSERT INTO active_nodes (ip, hostname, active) VALUES ("'$ip'", "'$hostname'", 1)' | mysql -u$DATABASE_USERNAME -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
done < $1

./spawn/set-node-roles-by-name.sh
