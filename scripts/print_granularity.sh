#!/bin/bash

for i in $( ls data/csv/); do
    cat $i | cut -d, -f7 | uniq -c | tr -s ' ' | cut -d ' ' -f2 | \
    awk '{sum+=$1} END { printf "Average temperature reads per hour for $i: %3.0f\n",sum/NR}'
done