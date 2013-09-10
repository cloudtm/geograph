#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <config-directory>"
    exit -1
fi
#PAO: REMOVED FROM HERE MOVED UP
#cd automate/configs
#./update-configs-from-templates.sh
#cd ../..

if [ "$1" = "DOWNLOAD" ]; then
    GET=1
    IPS=`./info/get-active-node-ips.sh ALL | head -n1`
    CFGS="nuno.jar geograph-torquebox.yml farm-torquebox.yml infinispan-udp-conf-geograph.xml standalone.conf geograph-production.rb farm-production.rb geograph-fenix-framework-ispn.properties farm-fenix-framework-ispn.properties geograph_options.yml geograph-jgroups-tcp.xml geograph-jgroups-udp.xml jgroups-lard.xml standalone-ha.xml wpm_resource_controller.config"
    mkdir downloaded-configs
else
    GET=0
    CFGS=`ls $1`
    IPS=`./info/get-active-node-ips.sh ALL`
fi

for ip in $IPS; do
    bash  automate/send-configurations-single.sh $1 $ip $GET $CFGS & 
done
wait
