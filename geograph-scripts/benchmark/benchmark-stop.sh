#!/bin/bash
echo 'UPDATE benchmark_schedules SET active = 0 WHERE id = 1' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
