#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit -1
fi

grep 'Oriani' $1 >&/dev/null
