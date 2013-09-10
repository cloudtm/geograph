#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <config-directory>"
    exit -1
fi

cd automate/configs
./update-configs-from-templates.sh
cd ../..

if [ "$1" = "DOWNLOAD" ]; then
    GET=1
    IPS=`./info/get-active-node-ips.sh ALL | head -n1`
    CFGS="geograph-torquebox.yml farm-torquebox.yml infinispan-udp-conf-geograph.xml standalone.conf geograph-production.rb farm-production.rb geograph-fenix-framework-ispn.properties farm-fenix-framework-ispn.properties geograph_options.yml geograph-jgroups-tcp.xml geograph-jgroups-udp.xml jgroups-lard.xml standalone-ha.xml wpm_resource_controller.config geograph_database.yml farm_database.yml wpm_resource_consumer.config"
    mkdir downloaded-configs
else
    GET=0
    CFGS=`ls $1`
    IPS=`./info/get-active-node-ips.sh ALL`
fi

for ip in $IPS; do
    echo IP $ip
    for cfg in $CFGS; do
        dest=
        dest2=
        if [ "$cfg" = "geograph-torquebox.yml" ]; then dest=/opt/geograph/config/torquebox.yml
        elif [ "$cfg" = "farm-torquebox.yml" ]; then dest=/opt/geograph-agent-farm/config/torquebox.yml
        elif [ "$cfg" = "infinispan-udp-conf-geograph.xml" ]; then dest=/opt/geograph/lib/cloud_tm/conf/infinispan-udp-conf-geograph.xml
        elif [ "$cfg" = "standalone.conf" ]; then dest=/opt/torquebox/current/jboss/bin/standalone.conf
        elif [ "$cfg" = "geograph-production.rb" ]; then dest=/opt/geograph/config/environments/production.rb
        elif [ "$cfg" = "farm-production.rb" ]; then dest=/opt/geograph-agent-farm/config/environments/production.rb
        elif [ "$cfg" = "geograph-fenix-framework-ispn.properties" ]; then dest=/opt/geograph/lib/cloud_tm/conf/fenix-framework-ispn.properties
        elif [ "$cfg" = "farm-fenix-framework-ispn.properties" ]; then dest=/opt/geograph-agent-farm/lib/cloud_tm/conf/fenix-framework-ispn.properties
        elif [ "$cfg" = "geograph_options.yml" ]; then dest=/opt/geograph/config/geograph_options.yml; dest2=/opt/geograph-agent-farm/config/geograph_options.yml
        elif [ "$cfg" = "geograph-jgroups-tcp.xml" ]; then dest=/opt/geograph/lib/cloud_tm/conf/jgroups/jgroups-tcp.xml
        elif [ "$cfg" = "geograph-jgroups-udp.xml" ]; then dest=/opt/geograph/lib/cloud_tm/conf/jgroups/jgroups-udp.xml
        elif [ "$cfg" = "jgroups-lard.xml" ]; then dest=/opt/geograph/lib/cloud_tm/conf/jgroups-lard.xml; dest2=/opt/geograph-agent-farm/lib/cloud_tm/conf/jgroups-lard.xml
        elif [ "$cfg" = "standalone-ha.xml" ]; then dest=/opt/torquebox/current/jboss/standalone/configuration/standalone-ha.xml
        elif [ "$cfg" = "wpm_resource_controller.config" ]; then dest=/opt/wpm/config/resource_controller.config
        elif [ "$cfg" = "geograph_database.yml" ]; then dest=/opt/geograph/config/database.yml
        elif [ "$cfg" = "farm_database.yml" ]; then dest=/opt/geograph-agent-farm/config/database.yml
	elif [ "$cfg" = "wpm_resource_consumer.config" ]; then dest=/opt/wpm/config/resource_consumer.config
        else
            echo "Unknown configuration file $cfg"
            exit -1
        fi
        #echo "$cfg -> $ip:$dest"
        if [ $GET -eq 0 ]; then
            scp -i ~/ziparo-keypair.pem $1/$cfg root@$ip:$dest 
            if [ "$dest2" != "" ]; then
                scp -i ~/ziparo-keypair.pem $1/$cfg root@$ip:$dest2 
            fi
        else
            scp -i ~/ziparo-keypair.pem root@$ip:$dest downloaded-configs/$cfg
        fi
    done
    echo
done
wait
