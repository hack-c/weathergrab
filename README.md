```
 __      __               __  .__                    ________            ___.    
/  \    /  \ ____ _____ _/  |_|  |__   ___________  /  _____/___________ \_ |__  
\   \/\/   // __ \\__  \\   __\  |  \_/ __ \_  __ \/   \  __\_  __ \__  \ | __ \ 
 \        /\  ___/ / __ \|  | |   Y  \  ___/|  | \/\    \_\  \  | \// __ \| \_\ \
  \__/\  /  \___  >____  /__| |___|  /\___  >__|    \______  /__|  (____  /___  /
       \/       \/     \/          \/     \/               \/           \/    \/ 

by Charlie Hack
4/7/2015
```
WeatherGrab
===========
WeatherGrab is a set of utilities for pulling **ISD** data from the National Climate Data Center's ftp server.   

WeatherGrab uses the R standard distribution and `bash`. 

Usage
-----
To get the data, run  

```
    $ Rscript scripts/grab_state.R
```
If you like, edit the top two lines of the script to get the state and year of your choosing.  

The other script, `print_station_granularity.sh`, uses that data to find how frequently each station takes a temperature reading.

ASOS Stations
-------------
The following `CALL WBAN` ASOS station-pairs are in Colorado:  

```
ALS 23061
DRO 93005
LHX 23067
PUB 93058
TAD 23070
COS 93037
LIC 93010
APA 93067
LXV 93009
EEO 94050
ASE 93073
AKO 24015
GJT 23066
MTJ 93013
CEZ 93069
CAG 24046
```