#!/bin/bash

VMIP=$1
      ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'rm -f /opt/geograph/lib/cloud_tm/jars/fenix-framework*'
      scp -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem ~/fenix-framework-latest/* root@$VMIP:/opt/geograph/lib/cloud_tm/jars &
      ssh -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem root@$VMIP 'rm -f /opt/geograph-agent-farm/lib/cloud_tm/jars/fenix-framework*'
      scp -o StrictHostKeyChecking=no -i ~/ziparo-keypair.pem ~/fenix-framework-latest/* root@$VMIP:/opt/geograph-agent-farm/lib/cloud_tm/jars &
wait
