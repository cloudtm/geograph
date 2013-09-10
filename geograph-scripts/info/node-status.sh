#!/bin/bash
if [ "$1" = "enabled" ]; then
    mysql -e 'SELECT * FROM active_nodes WHERE active = 1 ORDER BY hostname' -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
else
    mysql -e 'SELECT * FROM active_nodes ORDER BY hostname' -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
fi
