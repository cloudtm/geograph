#!/bin/bash
if [ $# -ne 5 ]; then
    echo "Usage: $0 <dynamic-profile-name> <duration> <number-of-agents/locations> <agent-type> <think-time>"
    exit -1
fi

DYN_PROFILE_NAME=$1
DURATION=$2
NUMBER_OF_AGENTS=$3
AGENT_TYPE=$4
THINK_TIME=$5

#echo 'INSERT INTO dynamic_profiles (name, user_id, position, created_at, updated_at) VALUES ("'$DYN_PROFILE_NAME'", 1, 1, NOW(), NOW()); SET @dyn_id = LAST_INSERT_ID();     INSERT INTO static_profiles (duration, dynamic_profile_id, position, created_at, updated_at) VALUES (3, @dyn_id, 1, NOW(), NOW());                                           SET @st_id = LAST_INSERT_ID();                                                                                                                                               INSERT INTO agent_groups (simulator, sleep, threads, static_profile_id, created_at, updated_at, cache_id, track_filter_type, track_filter_value) SELECT "Blogger1kAgent", '$THINK_TIME', 1, @st_id, NOW(), NOW(), "", "citycountry", citycountry FROM (SELECT citycountry, MAX(citycountry_idx) c FROM geograph_track_provider.tracks GROUP BY citycountry HAVING c > 100 ORDER BY c DESC) q LIMIT '$NUMBER_OF_AGENTS';' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production

echo 'DELETE FROM dynamic_profiles WHERE name = "'$DYN_PROFILE_NAME'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production

./benchdefs/clean-orphan-profiles-and-groups.sh
./benchdefs/create-citycountries-table.sh $NUMBER_OF_AGENTS

echo 'INSERT INTO dynamic_profiles (name, user_id, position, created_at, updated_at) VALUES ("'$DYN_PROFILE_NAME'", 1, 1, NOW(), NOW());                                     SET @dyn_id = LAST_INSERT_ID();                                                                                                                                              INSERT INTO static_profiles (duration, dynamic_profile_id, position, created_at, updated_at) VALUES ('$DURATION', @dyn_id, 1, NOW(), NOW());                                           SET @st_id = LAST_INSERT_ID();                                                                                                                                               INSERT INTO agent_groups (simulator, sleep, threads, static_profile_id, created_at, updated_at, cache_id, track_filter_type, track_filter_value)                                    SELECT "'$AGENT_TYPE'", '$THINK_TIME', 1, @st_id, NOW(), NOW(), "", "citycountry", citycountry FROM (SELECT citycountry FROM selected_citycountries) q;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
