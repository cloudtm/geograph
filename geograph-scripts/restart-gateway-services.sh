#!/bin/bash
JAVAPID="`cat ~/wpm/logService.pid`"
echo "KILLING LOGSERVICE, PID $JAVAPID"
kill -9  $JAVAPID
echo "----THE FOLLOWING JAVA SERVICES ARE STILL ALIVE---"
jps

echo "--RESTARTING LOG SERVICE-"
cd ~/wpm
./run_log_service_alg.sh

cd ~/gossipRouter
nohup ./start.sh $LOCAL_IP &
cd

cd ~/geograph-scripts
./track-provider/stop-track-provider.sh
./track-provider/start-track-provider.sh

