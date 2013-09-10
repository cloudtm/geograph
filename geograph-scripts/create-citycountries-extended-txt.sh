#!/bin/bash
cp citycountries.txt citycountries-extended.txt
echo 'SELECT citycountry FROM track_count_per_citycountry WHERE country IN ("ru", "us", "br", "in") AND citycountry NOT IN (
"tomsk (ru)",
"sputnik (ru)",
"cheliabinsk (ru)",
"lokno (ru)",
"dolinsk (ru)",
"ababurovo (ru)",
"abakan (ru)",
"abinskaya (ru)",
"abramtsevo (ru)",
"abryutinsliye vyselki (ru)",
"achinsk (ru)",
"adamovo (ru)",
"africanda (ru)",
"agan (ru)",
"akademicheskiy (ru)",
"akri (ru)",
"aksaitovo (ru)",
"alakit (ru)",
"aldan (ru)",
"alekseyevka pervaya (ru)",
"thrissur (in)",
"tomsk (ru)",
"aliatar (br)",
"richmond (us)"
) ORDER BY `count(*)` LIMIT 128;' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_track_provider | tail -n+2 >>citycountries-extended.txt

