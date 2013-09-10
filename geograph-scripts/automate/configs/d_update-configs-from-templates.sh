#!/bin/bash
for i in 1 2 4 8 16 32 64 100; do
    rm -rf 001-2pc-gmu-repl3-${i}b
    cp -r 001-2pc-gmu-repl3-template 001-2pc-gmu-repl3-${i}b
    sed -i 's/expectedInitialNodes=4/expectedInitialNodes='$i'/' 001-2pc-gmu-repl3-${i}b/geograph-fenix-framework-ispn.properties
done

for pr in 2pc to pr switching; do
    if [ "$pr" = "2pc" ]; then
        prot=DEFAULT
    elif [ "$pr" = "to" ]; then
        prot=TOTAL_ORDER
    elif [ "$pr" = "pr" ]; then
        prot=PASSIVE_REPLICATION
    elif [ "$pr" = "switching" ]; then
        prot=DEFAULT
    fi
    rm -rf 002-$pr
    cp -r 002-template 002-$pr
    sed -i 's/expectedInitialNodes=4/expectedInitialNodes=5/' 002-$pr/geograph-fenix-framework-ispn.properties
    sed -i 's/transactionProtocol="DEFAULT"/transactionProtocol="'$prot'"/' 002-$pr/infinispan-udp-conf-geograph.xml
done
