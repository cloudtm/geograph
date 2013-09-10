 #!/bin/bash
 #usage $1=protocol $2=radius
 
    pr=$1
    radius=$2


 

    if [ "$pr" = "2pc" ]; then
        prot=DEFAULT
    elif [ "$pr" = "to" ]; then
        prot=TOTAL_ORDER
    elif [ "$pr" = "pr" ]; then
        prot=PASSIVE_REPLICATION
    fi

    rm -rf 002-$pr
    cp -r 002-template 002-$pr

    sed -i 's/:cell_size: 10000/:cell_size: '${radius}'/' 002-$pr/geograph_options.yml
    sed -i 's/expectedInitialNodes=4/expectedInitialNodes=5/' 002-$pr/geograph-fenix-framework-ispn.properties
    sed -i 's/transactionProtocol="DEFAULT"/transactionProtocol="'$prot'"/' 002-$pr/infinispan-udp-conf-geograph.xml
