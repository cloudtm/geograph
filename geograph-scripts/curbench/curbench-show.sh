#!/bin/bash
mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production -e 'SELECT * FROM dynamic_profiles WHERE benchmark_schedule_id = 1 ORDER BY position'
