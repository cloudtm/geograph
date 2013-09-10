#!/bin/bash
echo 'SELECT ip FROM active_nodes WHERE hostname = "'$1'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2
