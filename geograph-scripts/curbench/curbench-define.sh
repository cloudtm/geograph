#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <dynamic_profile_name> <dynamic_profile_name> ..."
    exit -1
fi

echo 'UPDATE dynamic_profiles SET benchmark_schedule_id = NULL' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production

position=1
while [ "x$1" != "x" ]; do
    echo 'UPDATE dynamic_profiles SET benchmark_schedule_id = 1, position = '$position' WHERE name = "'$1'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
    position=$((position + 1))
    shift
done
