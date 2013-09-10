#!/bin/bash
echo -n 'Waiting for benchmark end...'
p=
while [ 1 ]; do
    PROG=`echo 'SELECT * FROM benchmark_schedules' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP geograph_production | tail -n+2 | head -n1 | awk '{ print $8 }'`
    sleep 2s
    if [ $PROG -eq 1 ]; then
        pp=`./info/benchmark-progress.sh`
        if [ "$p" != "$pp" ]; then echo -n "ETA: $pp min"; p=$pp; fi
        echo -n '.'
    else
        echo 'BENCHMARK FINISHED'
        break
    fi
done
