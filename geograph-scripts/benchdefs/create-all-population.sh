#!/bin/bash
for machines in 2 4 8 16 32; do
    ./benchdefs/create-benchmark.sh SCALABILITY-POPULATION-${machines}B 3 $((machines * 4)) Blogger1kAgent 0
done
