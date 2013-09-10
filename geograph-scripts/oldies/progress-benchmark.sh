#!/bin/bash
while [ 1 ]; do
    echo 'SELECT * FROM benchmark_schedules' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2 | head -n1
    sleep 2s
done
