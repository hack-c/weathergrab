#!/bin/bash

# run this script from the project root.
# run the script `grab_state.R` first to get the data.
# this script will print out a CSV called `latlngreads.csv`, with columns:
#     "latitude", "longitude", "temp reads/hr"
# with one row for each station.

cd ./data/csv/

# write header row
echo "USAFID,WBAN,AVG_READS" >> ../reads_hr.csv

# calculate average reads per hour per station (usually 3 for CO)
for f in $( ls ); do
    echo reading $f...
    cat $f | cut -d, -f7 | uniq -c | tr -s ' ' | cut -d ' ' -f2 | \
    awk -v USAFID="${f:0:6}" -v WBAN="${f:7:5}" '{sum+=$1} END { printf "%s,%s,%3.0f\n", USAFID, WBAN, sum/NR}' >> ../reads_hr.csv
done

cd ../

# sort files so they align
echo
echo sorting files...
cat reads_hr.csv | tail -n +2 | sort --field-separator=',' --key=1,2 > reads_hr_.csv
cat stations.csv | tail -n +2 | sort --field-separator=',' --key=1,2 > stations_.csv

# paste reads per hour field to stations and dump to latlngreads.csv
echo
echo writing latlngreads.csv... 
echo "lat,lon,Temperature Readings per Hour" > latlngreads.csv
paste -d, stations_.csv <(cut -d, -f3 reads_hr_.csv) | cut -d, -f4,5,7 >> latlngreads.csv

echo
echo "done."
cd ../