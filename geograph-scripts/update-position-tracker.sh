#!/bin/bash
if [ $# -eq 0 ]; then
    VMIPS=`./info/get-active-node-ips.sh`
else
    VMIPS=$*
fi
for VMIP in $VMIPS; do
    SRC=~ziparo/daniele-scripts/pedro_position_tracker.rb
    scp -i ~/ziparo-keypair.pem $SRC root@$VMIP:/opt/geograph-agent-farm/lib/behaviors/random_position_tracker.rb
    echo ---
    ls -l $SRC
    echo ---
    ssh -i ~/ziparo-keypair.pem root@$VMIP 'ls -l /opt/geograph-agent-farm/lib/behaviors/'
done
