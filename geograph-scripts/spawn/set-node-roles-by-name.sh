#!/bin/bash
echo 'UPDATE active_nodes SET geograph = 0, farm = 0; UPDATE active_nodes SET geograph = 1 WHERE hostname LIKE "geo%"; UPDATE active_nodes SET farm = 1 WHERE hostname LIKE "farm%";' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
