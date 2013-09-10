if [ $# -ne 2 -a $# -ne 3 ]; then
  echo "Usage $0 <snapshot-name> <instance-name> [<flavor-id>]"
  exit
fi
. spawn/alg.sh
if [ "x$3" != "x" ]; then
    FLAVOR_ID=`./info/flavor-to-id.sh $3`
else
    FLAVOR_ID=16
fi
echo 'INSERT INTO active_nodes (ip, hostname) VALUES ("temp'$RANDOM'", "'$2'") ON DUPLICATE KEY UPDATE ip = "temp'$RANDOM'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
./spawn/set-node-roles-by-name.sh
#nova boot --image "$1" --flavor="$FLAVOR_ID" --key-name ziparo-keypair $2
n=`echo $2 | sed -e 's/[^0-9]//g'`
p=`echo $2 | sed 's/-.*$//'`
if [ -f spawn/${p}_nodes ]; then
    t=`wc -l spawn/${p}_nodes | awk '{print $1}'`
    n=$(((n - 1) % t))
    node=
    i=0
    for nn in `cat spawn/${p}_nodes`; do
        if [ $i -eq $n ]; then
            node=$nn
            break
        fi
        i=$((i+1)) 
    done
    echo nova boot --image "$1" --flavor="$FLAVOR_ID" --key-name=algKey $2 --availability-zone nova:$node
    nova boot --image "$1" --flavor="$FLAVOR_ID" --key-name=algKey $2 --availability-zone nova:$node
else
    echo nova boot --image "$1" --flavor="$FLAVOR_ID" --key-name=algKey $2
    nova boot --image "$1" --flavor="$FLAVOR_ID" --key-name=algKey $2
fi
