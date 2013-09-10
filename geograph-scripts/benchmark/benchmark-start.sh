#!/bin/bash
echo 'UPDATE benchmark_schedules SET active = 1 WHERE id = 1' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
