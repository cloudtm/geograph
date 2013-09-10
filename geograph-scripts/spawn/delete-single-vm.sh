if [ $# -ne 1 ]; then
  echo "Usage $0 <instance-name>"
  exit
fi
. spawn/alg.sh
nova delete $1
echo 'DELETE FROM active_nodes WHERE hostname = "'$1'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie
