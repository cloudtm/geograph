#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage $0 <dataset-name>"
    echo "<dataset-name> is something like read-intensive.1m.description"
    exit -1
fi

DATASET_NAME=$1

./benchmark/wait-for-benchmark-end.sh &&
./benchmark/benchmark-collect-data.sh $DATASET_NAME &&
./benchmark/benchmark-stop.sh
