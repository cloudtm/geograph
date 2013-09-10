#!/bin/bash
mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production -e 'SELECT name FROM dynamic_profiles ORDER BY name'
