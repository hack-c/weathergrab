#######################################################################
################[ Get state-level ISD data for 1 year ]################
################[ Charlie Hack                        ]################
################[ 4/7/2015                            ]################
#######################################################################

# inspiration: http://blue.for.msu.edu/lab-notes/NOAA_0.1-1/NOAA-ws-data.pdf

# library for plotting
library("rgdal")

# state and year to download from
state <- "CO"
year <- 2015

# download station list csv
file <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv"
repeat {
    try(download.file(file, "data/ish-history.csv", quiet=TRUE))
    if (file.info("data/ish-history.csv")$size > 0) {break}
}

# read csv
hst <- read.csv("data/ish-history.csv")

# labels and scaling
names(hst)[c(3, 9)] <- c("NAME", "ELEV") 
hst <- hst[hst$CTRY == "US", ]
hst$LAT <- hst$LAT/1000
hst$LON <- hst$LON/1000
hst$ELEV <- hst$ELEV/10
hst$BEGIN <- as.numeric(substr(hst$BEGIN, 1, 4))
hst$END <- as.numeric(substr(hst$END, 1, 4))

# make list of stations that match year and state
co.list <- hst[hst$STATE == state & (hst$BEGIN <= year & hst$END >= year & !is.na(hst$BEGIN)), ]
outputs <- as.data.frame(matrix(NA, dim(co.list)[1], 2))

# download
for (y in year:year) {
    y.co.list <- co.list[co.list$BEGIN <= y & co.list$END >= y, ]
    for (s in 1:dim(y.co.list)[1]) {
        outputs[s, 1] <- paste(sprintf("%06d", y.co.list[s,1]), "-", sprintf("%05d", y.co.list[s,2]), "-", y, ".gz", sep="")
        wget <- paste("wget -P data/raw ftp://ftp.ncdc.noaa.gov/pub/data/noaa/", y, "/", outputs[s,1], sep="")
        outputs[s, 2] <- try(system(wget, intern=FALSE, ignore.stderr=TRUE))
        write(outputs[s,], stdout())
    }
}

# read fixed-width files, apply some transformations and dump to csv
files <- list.files("data/raw/")
column.widths <- c(4,6,5,4,2,2,2,2,1,6,7,5,5,5,4,3,1,1,4,1,5,1,1,1,6,1,1,1,5,1,5,1,5,1)
stations <- as.data.frame(matrix(NA, length(files), 6))
names(stations) <- c("USAFID", "WBAN", "YR", "LAT", "LONG", "ELEV")
for (i in 1:length(files)) {
    data <- read.fwf(paste("data/raw/", files[i], sep=""), column.widths)
    data <- data[, c(2:8, 10:11, 13, 16, 19, 29, 31, 33)]
    names(data) <- c("USAFID", "WBAN", "YR", "M", "D", "HR", "MIN", "LAT", "LONG", "ELEV", "WIND.DIR", "WIND.SPD", "TEMP", "DEW.POINT", "ATM.PRES")
    data$LAT <- data$LAT/1000
    data$LONG <- data$LONG/1000
    data$WIND.SPD <- data$WIND.SPD/10
    data$TEMP <- data$TEMP/10
    data$DEW.POINT <- data$DEW.POINT/10
    data$ATM.PRES <- data$ATM.PRES/10
    write.csv(data, file=paste("data/csv/", files[i], ".csv", sep=""))
    stations[i,1:3] <- data[1,1:3]
    stations[i,4:6] <- data[1, 8:10]
    write(paste("wrote", files[i], sep=" "), stdout())
}

# write "index" csv of stations with meta info.
write.csv(stations, file="data/stations.csv", row.names=FALSE)
