#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh ALL`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    scp -i ~/ziparo-keypair.pem ~/wpm/wpm.jar root@$VMIP:/opt/wpm/wpm.jar &
done
wait
