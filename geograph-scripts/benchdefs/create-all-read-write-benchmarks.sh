#!/bin/bash
for machines in 2 4 8 16 32 64; do
    echo $machines machines:
    for agent_type in ProbReadPost10UpdatePos90Agent; do #ProbReadPost50UpdatePos50Agent; do #ProbReadPost10UpdatePos90Agent ProbReadPost50UpdatePos50Agent; do
        case $agent_type in
            ProbReadPost90UpdatePos10Agent) wl=90R-10U ;;
            ProbReadPost10UpdatePos90Agent) wl=10R-90U ;;
            ProbReadPost50UpdatePos50Agent) wl=50R-50U ;;
        esac
        echo $wl workload:
        ./benchdefs/create-benchmark.sh SCALABILITY-$wl-2TT-${machines}B 2 $((machines * 4)) $agent_type 2000
        ./benchdefs/create-benchmark.sh SCALABILITY-$wl-0TT-${machines}B 5 $((machines * 4)) $agent_type 0
    done
done
