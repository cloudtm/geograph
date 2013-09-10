#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <number-of-citycountries>"
    exit -1
fi

if [ $1 -le 32 ]; then
    file=citycountries-manual.txt
elif [ $1 -le 128 ]; then
    file=citycountries.txt
else
    file=citycountries-extended.txt
fi

echo 'DROP TABLE IF EXISTS selected_citycountries' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
echo 'CREATE TABLE selected_citycountries (citycountry VARCHAR(255))' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production

i=1
while read cc; do
    echo 'INSERT INTO selected_citycountries VALUES ("'$cc'")' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production
    i=$((i+1))
    if [ $i -gt $1 ]; then break; fi
done < $file
    
echo 'SELECT * FROM selected_citycountries' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production

