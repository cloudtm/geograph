#!/bin/bash
echo 'SELECT hostname FROM active_nodes WHERE ip = "'$1'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2
