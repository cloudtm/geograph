#!/bin/bash
./get-active-node-ips.sh | cut -d' ' -f1 | head -n1
