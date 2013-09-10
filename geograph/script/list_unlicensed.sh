#!/bin/bash
find . -iname '*.rb' | xargs grep -L 'Oriani'
