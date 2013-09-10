#!/bin/bash
echo 'UPDATE active_nodes SET active = 1;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
