#!/bin/bash
echo 'DELETE FROM active_nodes' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
