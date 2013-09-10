#!/bin/bash
if [ "$1" = "stubborn" ]; then
    STUBBORN=1
else
    STUBBORN=0
fi

NUM_OF_NODES=`./info/get-active-node-ips.sh | wc -l`
if [ "$NUM_OF_NODES" = "" ]; then
    echo "NUM_OF_NODES is not set"
    exit -1
fi
echo "Waiting for nodes ($NUM_OF_NODES) to become active... initial sleep 20 seconds"
##sleep 20s
ACTIVE_COUNT=0
SPAWNING=`echo 'SELECT COUNT(*) FROM active_nodes WHERE ip LIKE "temp%"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
TRIALS=0
while [ $ACTIVE_COUNT -lt $NUM_OF_NODES ]; do
    TRIALS=$((TRIALS + 1))
    ACTIVE_NODES=`./info/get-active-node-ips.sh`
    ACTIVE_COUNT=0
    SLEEPING_NODES=""
    echo "Trial $TRIALS..."
    for ip in $ACTIVE_NODES; do
        echo -n "$ip"
        BOTH=`echo 'SELECT geograph AND farm FROM active_nodes WHERE IP = "'$ip'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
        GEOGRAPH=`echo 'SELECT geograph FROM active_nodes WHERE IP = "'$ip'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
        FARM=`echo 'SELECT farm FROM active_nodes WHERE IP = "'$ip'"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2`
        OK=0
        if [ $GEOGRAPH -eq 0 -a $FARM -eq 0 ]; then
            echo ": please specify geograph and/or farm in the walkietalkie table, or disable this entry"
            continue
        fi
        if [ $BOTH -eq 1 ]; then
            DES_OK=3
            echo -n ": "
        elif [ $GEOGRAPH -eq 1 ]; then
            DES_OK=2
            echo -n " (only geograph): "
        elif [ $FARM -eq 1 ]; then
            DES_OK=2
            echo -n " (only farm): "
        fi
        ping -w 2 $ip &>/dev/null
        STATUS=
        if [ $? -eq 0 ]; then
            OK=$((OK + 1))
            STATUS=ping
            if [ $BOTH -eq 1 -o $GEOGRAPH -eq 1 ]; then
                wget -O /tmp/out $ip:8080 &>/dev/null
                if [ $? -eq 0 ]; then
                    OK=$((OK + 1))
                    STATUS=${STATUS},geograph
                fi
            fi
            if [ $BOTH -eq 1 -o $FARM -eq 1 ]; then
                wget -O /tmp/out $ip:8080/farm &>/dev/null
                if [ $? -eq 0 ]; then
                    OK=$((OK + 1))
                    STATUS=${STATUS},farm
                fi
            fi
            echo -n "$STATUS"
        fi
        echo
        if [ $OK -eq $DES_OK ]; then
            ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
        else
            SLEEPING_NODES="$SLEEPING_NODES $ip"
        fi
    done
    if [ $SPAWNING -gt 0 ]; then
        echo "The following nodes are still spawning:"
        echo 'SELECT hostname FROM active_nodes WHERE ip LIKE "temp%"' | mysql -ugeograph -p$DATABASE_PASSWORD -h$DATABASE_IP walkietalkie | tail -n+2
    fi
    if [ $ACTIVE_COUNT -lt $NUM_OF_NODES -o $SPAWNING -eq 1 ]; then
        echo "The following nodes are still sleeping: $SLEEPING_NODES..."
        if [ $TRIALS -ge 15 -a $STUBBORN -eq 1 ]; then
            echo "...trying to wake them..."
            for node in $SLEEPING_NODES; do
            ./java/java-start.sh $node
            done
            TRIALS=0
        fi
        sleep 4s
        echo '--'
    fi
done
echo
echo "$ACTIVE_COUNT of $NUM_OF_NODES nodes are active (ping + context '/' + context '/farm')"
