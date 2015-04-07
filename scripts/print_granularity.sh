#!/bin/bash

cd ./data/csv/

for f in $( ls ); do
    cat $f | cut -d, -f7 | uniq -c | tr -s ' ' | cut -d ' ' -f2 | \
    awk -v USAFID="${f:0:6}" -v WBAN="${f:7:5}" '{sum+=$1} END { printf "avg. temp reads/hr for %s-%s: %3.0f\n", USAFID, WBAN, sum/NR}'
done

cd ../..