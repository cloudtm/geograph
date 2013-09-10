#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    echo "* $VMIP - geograph:"
    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'cd /opt/geograph && git pull'
    echo "* $VMIP - farm:"
    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'cd /opt/geograph-agent-farm && git pull'
    echo "* $VMIP - madmass:"
    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'cd /opt/madmass && git pull'
done
