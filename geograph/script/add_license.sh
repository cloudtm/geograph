#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit -1
fi

(sed -e 's/^/# /' LICENSE.txt && echo) | cat - $1 >/tmp/licfile
mv /tmp/licfile $1
