#!/bin/bash

# run this script from the project root.
# run the script `grab_state.R` first to get the data.
# this script will print out a CSV called `lastreads.csv`, with columns:
#
#     usafid,wban,y,m,d,h,min,lat,lng
#
# one row for each station.

cd data/csv/

echo "usafid,wban,y,m,d,h,min,lat,lng" > lastreads.csv

for f in $( ls ); do
    echo reading $f...
    cat $f | tail -n1 | cut -d, -f1,2,3,4,5,6,7,8,9 >> lastreads.csv
    cat lastreads.csv | sed "$ d" > lastreads.csv  # remove the last line which gets duplicated
done

cd ../../

