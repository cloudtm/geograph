#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <ip> <node-name>"
fi
echo 'INSERT INTO active_nodes (ip, hostname) VALUES ("'$1'", "'$2'") ON DUPLICATE KEY UPDATE ip = "'$1'", hostname = "'$2'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
