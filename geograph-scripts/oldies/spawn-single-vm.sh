if [ $# -ne 2 -a $# -ne 3 ]; then
  echo "Usage $0 <snapshot-name> <instance-name> [<flavor-id>]"
  exit
fi
. ~/.openrc.sh
if [ "x$3" != "x" ]; then
    FLAVOR_ID=`./info/flavor-to-id.sh $3`
else
    FLAVOR_ID=16
fi
echo 'INSERT INTO active_nodes (ip, hostname) VALUES ("temp'$RANDOM'", "'$2'") ON DUPLICATE KEY UPDATE ip = "temp'$RANDOM'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
./spawn/set-node-roles-by-name.sh
nova boot --image "$1" --flavor="$FLAVOR_ID" --key-name ziparo-keypair $2
