#!/bin/bash

D=`ls sessions-to-do | sort | head -n 1`
CFGS=`ls sessions-to-do/$D/configs`
IPS=`echo 'SELECT ip FROM active_vm' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
ONE_IP=`echo 'SELECT ip FROM active_vm' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2 | head -n1`

for ip in $IPS; do
    for cfg in $CFGS; do
        dest=
        if [ "$cfg" = "torquebox.yml" ]; then dest=/opt/geograph/config/torquebox.yml
        elif [ "$cfg" = "infinispan-udp-conf-geograph.xml" ]; then dest=/opt/geograph/lib/cloud_tm/conf/infinispan-udp-conf-geograph.xml
        elif [ "$cfg" = "standalone.conf" ]; then dest=/opt/torquebox/current/jboss/bin/standalone.conf
        fi
        echo "$cfg -> $ip:$dest"
        scp -i ~/ziparo-keypair.pem sessions-to-do/$D/configs/$cfg root@$ip:$dest
    done
done

echo "Restarting everything on each node..."
for ip in $IPS; do
    ssh -i ~/ziparo-keypair.pem root@$ip 'cd /opt/geograph && ./script/prod_launch.sh' &>/dev/null &
    echo "Restarted $ip"
done
echo "Cleaning old benchmark data..."
./clean-benchmark-data.sh

./wait-for-active-nodes.sh
echo "Starting benchmark..."
./start-benchmark.sh
./wait-for-benchmark.sh
./collect-benchmark-data.sh $ONE_IP ${D/[0-9][0-9][0-9]-/}
echo "Stopping benchmark..."
./stop-benchmark.sh

mv sessions-to-do/$D sessions-done
