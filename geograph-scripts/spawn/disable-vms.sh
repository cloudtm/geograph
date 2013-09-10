#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Usage: $0 <prefix> <from> <to>"
    echo "Example: $0 geo- 1 10"
    exit -1
fi

for i in `seq $2 $3`; do
    echo 'UPDATE active_nodes SET active = 0 WHERE hostname = "'$1$i'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
done
