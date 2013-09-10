#!/bin/bash

ip=$2
GET=$3
declare -a params
params=( "$@" )


    echo IP $ip

    #echo elems in params: ${#params[@]}
    #echo resto...
    for i in `seq 3 $((${#params[@]} - 1))`
    do
        cfg=${params[$i]}
#
#
#    for cfg in $CFGS; do
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
        elif [ "$cfg" = "nuno.jar" ]; then dest=/opt/geograph/lib/cloud_tm/jars/fenix-framework-backend-infinispan.jar
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
