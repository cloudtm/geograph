#!/bin/bash
rm citycountries.txt
echo 'select citycountry  from (select *, `count(*)` as c from track_count_per_citycountry where citycountry != "" order by `count(*)` desc) q group by country order by c desc;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_track_provider | tail -n+2 >citycountries.txt
echo 'select citycountry from track_count_per_citycountry where country = "ru" order by `count(*)` limit 15;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_track_provider | tail -n+2 >>citycountries.txt

