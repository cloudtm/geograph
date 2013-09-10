#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    bash git-pull-all-single.sh $VMIP &
done
wait
