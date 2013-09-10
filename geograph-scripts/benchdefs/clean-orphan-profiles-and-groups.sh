#!/bin/bash
echo 'delete from static_profiles where dynamic_profile_id not in (select id from dynamic_profiles); delete from agent_groups where static_profile_id not in (select id from static_profiles);' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
