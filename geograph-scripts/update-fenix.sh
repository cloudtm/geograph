#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh ALL`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'rm -f /opt/geograph/lib/cloud_tm/jars/fenix-framework*'
    scp -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem ~/fenix-framework-latest/* root@$VMIP:/opt/geograph/lib/cloud_tm/jars &
    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'rm -f /opt/geograph-agent-farm/lib/cloud_tm/jars/fenix-framework*'
    scp -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem ~/fenix-framework-latest/* root@$VMIP:/opt/geograph-agent-farm/lib/cloud_tm/jars &
done
