#!/bin/bash
if [ "$1" = "" ]; then
  echo "Please provide a descriptive name for this benchmark"
  exit
fi

TITLE=$1

NOWDATE=`date +%Y%m%d-%H%M%S`
tar -cvzf ~/wpm/${NOWDATE}.tar.gz ~/wpm/log
#rm -rf  ~/wpm/log/csv/*

mkdir ~/experiment-results/$NOWDATE-$TITLE
mv ~/wpm/$NOWDATE.tar.gz ~/experiment-results/$NOWDATE-$TITLE
cp -r ~/wpm/log/csv ~/experiment-results/$NOWDATE-$TITLE/
for ip in `./info/get-active-node-ips.sh`; do
    VMIP=$ip
    mkdir ~/experiment-results/$NOWDATE-$TITLE/$VMIP
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/lib/cloud_tm/conf/infinispan-udp-conf-geograph.xml ~/experiment-results/$NOWDATE-$TITLE/$VMIP 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/config/geograph_options.yml ~/experiment-results/$NOWDATE-$TITLE/$VMIP 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/lib/cloud_tm/conf/jgroups/jgroups-udp.xml ~/experiment-results/$NOWDATE-$TITLE/$VMIP 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/lib/cloud_tm/conf/jgroups/jgroups-tcp.xml ~/experiment-results/$NOWDATE-$TITLE/$VMIP 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/tmp/geograph_startup_boot.log ~/experiment-results/$NOWDATE-$TITLE/$VMIP 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/log/production.log ~/experiment-results/$NOWDATE-$TITLE/$VMIP/geograph.log 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph-agent-farm/log/production.log ~/experiment-results/$NOWDATE-$TITLE/$VMIP/farm.log 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/nohup.log ~/experiment-results/$NOWDATE-$TITLE/$VMIP/torquebox1.log 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/geograph/nohup.out ~/experiment-results/$NOWDATE-$TITLE/$VMIP/torquebox2.log
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/wpm/nohup.out ~/experiment-results/$NOWDATE-$TITLE/$VMIP/wpm.log 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/torquebox/current/jboss/gclogs.log ~/experiment-results/$NOWDATE-$TITLE/$VMIP/gclogs.log 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/root/vmstat.log ~/experiment-results/$NOWDATE-$TITLE/$VMIP/vmstat.log 
    scp -i ~/ziparo-keypair.pem root@$VMIP:/opt/torquebox/current/jboss/standalone/log/server.log  ~/experiment-results/$NOWDATE-$TITLE/$VMIP/server.log 
    scp -i ~/ziparo-keypair.pem -r root@$VMIP:/root/threaddumps ~/experiment-results/$NOWDATE-$TITLE/$VMIP/threaddumps 
    wait
done

cat <<EOF >~/experiment-results/$NOWDATE-$TITLE/readme.txt
Nodes: $NUM_OF_NODES
Flavor: xxlarge
EOF

echo "Collected data into directory ~/experiment-results/$NOWDATE-$TITLE"
echo "You can see these stats at http://cloudtm.ist.utl.pt/ziparo/stats2/index.php?rootFolder=experiment-results/$NOWDATE-$TITLE/csv"
