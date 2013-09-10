#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh ALL`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    bash ./single-update-fenix.sh $VMIP &
done
wait
