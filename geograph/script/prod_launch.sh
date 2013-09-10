#!/bin/bash
if [ $# -eq 0 ]; then
  START_GEOGRAPH=1
  START_FARM=1
  START_WPM=1
  START_THREADDUMP=1
  START_VMSTAT=1
else
  START_GEOGRAPH=0
  START_FARM=0
  START_WPM=0
  START_THREADDUMP=0
  START_VMSTAT=0
fi

while [ "x$1" != "x" ]; do
  if [ "$1" = "geograph" ]; then
    START_GEOGRAPH=1
  elif [ "$1" = "farm" ]; then
    START_FARM=1
  elif [ "$1" = "wpm" ]; then
    START_WPM=1
  elif [ "$1" = "threaddump" ]; then
    START_THREADDUMP=1
  elif [ "$1" = "vmstat" ]; then
    START_VMSTAT=1
  else
    echo "Unknown app '$1'"
    exit -1
  fi
  shift
done

killall -9 java
killall jboss-thread-dumper.sh
killall vmstat

/root/clean-all-logs.sh
touch /tmp/prod_launch.log
echo "" > /tmp/prod_launch.log
echo "" > /opt/geograph/nohup.out
echo "" >/opt/geograph/nohup.log

MYIP=$(/sbin/ifconfig eth0 | grep "inet " | awk -F: '{print $1}'| awk '{print $2}')
echo "My IP address is $MYIP"

sed -i".bak" '/madmass-node/d' /etc/hosts
echo "$MYIP madmass-node" >> /etc/hosts
echo "Host 'madmass-node' IP has been set to $MYIP" >> /tmp/prod_launch.log

# run TorqueBox
echo "" > $JBOSS_HOME/standalone/log/server.log
echo "" > $JBOSS_HOME/standalone/log/boot.log
rm -rf ${JBOSS_HOME}/standalone/tmp/*
rm -rf ${JBOSS_HOME}/standalone/data/*
rm -rf ${JBOSS_HOME}/standalone/deployments/*
nohup torquebox run --clustered --bind-address $MYIP --jvm-options -Djboss.bind.address.management=$MYIP &>/opt/geograph/nohup.log &

if [ $START_VMSTAT -eq 1 ]; then
	vmstat 5 >/root/vmstat.log &
fi

if [ $START_THREADDUMP -eq 1 ]; then
	/root/jboss-thread-dumper.sh &
fi

if [ $START_GEOGRAPH -eq 1 ]; then
	# run Geograph
	cd /opt/geograph
	echo "" >  log/development.log
	echo "" >  log/production.log
	echo "in /opt/geograh" >> /tmp/prod_launch.log
	torquebox deploy --env=production
	if [ $START_FARM -eq 1 ]; then
		sleep 20
	fi
fi

if [ $START_FARM -eq 1 ]; then
	# run the farm
	cd  /opt/geograph-agent-farm
	echo "" >  log/development.log
	echo "" >  log/production.log
	torquebox deploy --context-path=/farm --env=production
fi

if [ $START_WPM -eq 1 ]; then
	# run WPM
	cd /opt/wpm
	./run_cons_prod.sh
fi


