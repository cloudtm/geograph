#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh ALL`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    SRC=~/ispn-latest/infinispan-*.jar
    scp -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem $SRC root@$VMIP:/opt/torquebox/current/jboss/modules/org/infinispan/main/infinispan-core-5.2.6-cloudtm-SNAPSHOT.jar &
    scp -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem $SRC root@$VMIP:/opt/cloudtm-jboss-modules/modules/org/infinispan/main/infinispan-core-5.2.6-cloudtm-SNAPSHOT.jar &
#    echo ---
#    ls -l $SRC
#    echo ---
#    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'ls -l /opt/torquebox/current/jboss/modules/org/infinispan/main/infinispan-core*'
#    echo ---
#    ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'ls -l /opt/cloudtm-jboss-modules/modules/org/infinispan/main/infinispan-core*'
done
wait
