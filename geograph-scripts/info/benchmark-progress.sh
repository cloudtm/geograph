#!/bin/bash
static_profile_id=`echo 'SELECT static_profile_id FROM benchmark_schedules where id = 1' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2`
static_profile_progress=`echo 'SELECT IF(static_profile_progress > 100, 100, static_profile_progress) FROM benchmark_schedules where id = 1' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2`
TOTAL_TIME=`echo 'select sum(duration) from dynamic_profiles d inner join static_profiles s on s.dynamic_profile_id = d.id where benchmark_schedule_id = 1 order by d.position;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2`
#echo "Total time: $TOTAL_TIME min"
#echo "Static profile id: $static_profile_id"
#echo "Static profile progress: $static_profile_progress %"

#echo 'select name, d.position d_pos, s.position s_pos, duration from dynamic_profiles d inner join static_profiles s on s.dynamic_profile_id = d.id where benchmark_schedule_id = 1 order by d.position;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
#echo
cur_duration=`echo 'select duration from dynamic_profiles d inner join static_profiles s on s.dynamic_profile_id = d.id where benchmark_schedule_id = 1 and s.id = '$static_profile_id | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2`
cur_duration=$((static_profile_progress * cur_duration / 100 + 0))
#echo "Current static profile duration: $cur_duration"
#echo "Current minutes: $((static_profile_progress * cur_duration / 100))"

dur_before=`echo 'select sum(duration) from (select name, s.id s_id, d.position ad_pos, s.position as_pos from dynamic_profiles d inner join static_profiles s on s.dynamic_profile_id = d.id where benchmark_schedule_id = 1 order by d.position) a inner join (select s.id ss_id, duration, d.position bd_pos, s.position bs_pos from dynamic_profiles d inner join static_profiles s on s.dynamic_profile_id = d.id where benchmark_schedule_id = 1 and s.id = '$static_profile_id') b where (ad_pos < bd_pos) or (ad_pos = bd_pos and as_pos < bs_pos)' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2`
dur_before=$(( dur_before + 0 ))
#echo "Duration before current: $dur_before min"

#echo "$(( TOTAL_TIME - (dur_before + cur_duration))) (tot: $TOTAL_TIME, bef: $dur_before, cur: $cur_duration)"
echo "$(( TOTAL_TIME - (dur_before + cur_duration)))"
