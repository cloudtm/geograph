#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: $0 <ip> <dest-dir>"
    exit -1
fi

ip=$1
DESTDIR=$2
#CFGS="torquebox.yml infinispan-udp-conf-geograph.xml standalone.conf geograph-production.rb farm-production.rb geograph-fenix-framework-ispn.properties farm-fenix-framework-ispn.properties"
CFGS="geograph-fenix-framework-ispn.properties farm-fenix-framework-ispn.properties"

mkdir -p $DESTDIR

for cfg in $CFGS; do
    src=
    if [ "$cfg" = "torquebox.yml" ]; then src=/opt/geograph/config/torquebox.yml
    elif [ "$cfg" = "infinispan-udp-conf-geograph.xml" ]; then src=/opt/geograph/lib/cloud_tm/conf/infinispan-udp-conf-geograph.xml
    elif [ "$cfg" = "standalone.conf" ]; then src=/opt/torquebox/current/jboss/bin/standalone.conf
    elif [ "$cfg" = "geograph-production.rb" ]; then src=/opt/geograph/config/environments/production.rb
    elif [ "$cfg" = "farm-production.rb" ]; then src=/opt/geograph-agent-farm/config/environments/production.rb
    elif [ "$cfg" = "geograph-fenix-framework-ispn.properties" ]; then src=/opt/geograph/lib/cloud_tm/conf/fenix-framework-ispn.properties
    elif [ "$cfg" = "farm-fenix-framework-ispn.properties" ]; then src=/opt/geograph-agent-farm/lib/cloud_tm/conf/fenix-framework-ispn.properties
    fi
    echo "$ip:$src > $DESTDIR/$cfg"
    scp -i ~/ziparo-keypair.pem root@$ip:$src $DESTDIR/$cfg
done
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <config-directory>"
    exit -1
fi

cd automate/configs
./update-configs-from-templates.sh
cd ../..

CFGS=`ls $1`
IPS=`./info/get-active-node-ips.sh ALL`

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
        elif [ "$cfg" = "jgroups-lard.xml" ]; then dest=/opt/geograph/lib/cloud_tm/conf; dest2=/opt/geograph-agent-farm/lib/cloud_tm/conf
        elif [ "$cfg" = "standalone-ha.xml" ]; then dest=/opt/torquebox/current/jboss/standalone/configuration/standalone-ha.xml
        else
            echo "Unknown configuration file $cfg"
            exit -1
        fi
        #echo "$cfg -> $ip:$dest"
        scp -i ~/ziparo-keypair.pem $1/$cfg root@$ip:$dest
        if [ "$dest2" != "" ]; then
            scp -i ~/ziparo-keypair.pem $1/$cfg root@$ip:$dest2
        fi
    done
    echo
done

