#!/bin/bash
if [ $# -lt 2 ]; then
   echo "Usage: $0 <instance-image> <num-nodes> [<flavor>]"
   exit
fi

./clean-presence-signals-from-vm.sh

INSTIMG=$1
NODES=$2

if [ "$3" = "" ]; then
   FLAVOR=12
else
   FLAVOR=$3
fi

STILL_LOGS=`ls ~/wpm/log/csv/ | wc -l`
if [ $STILL_LOGS -ne 0 ]; then
  echo "There are still logs in wpm data directory, please collect them before starting a new experiment"
  exit
fi

echo "launching $NODES nodes with flavor $FLAVOR"

JAVAPID="`cat ~/wpm/logService.pid`"
echo "KILLING LOGSERVICE, PID $JAVAPID"
kill -9  $JAVAPID
echo "----THE FOLLOWING JAVA SERVICES ARE STILL ALIVE---"
jps

echo "--ARCHIVING OLD CSV FILES-"
NOWDATE=`date +%d%m%y-%H%M%S`
#tar -cvzf ~/wpm/log/bak/${NOWDATE}.tar.gz ~/wpm/log
tar -cvzf ~/wpm/${NOWDATE}.tar.gz ~/wpm/log
rm -rf  ~/wpm/log/csv/*

echo "--RESTARTING LOG SERVICE-"
cd ~/wpm
./run_log_service_alg.sh
cd ~/scripts

cd ~/gossipRouter
nohup ./start.sh &
cd 
source .openrc.sh
#nova image-list

for x in $(seq 1 $NODES); do
  nova boot --image "$INSTIMG" --flavor="$FLAVOR"  --key-name ziparo-keypair geo-cluster-$x
  sleep 30s
done

