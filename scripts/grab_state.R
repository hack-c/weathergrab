#######################################################################
################[ Get state-level ISD data for 1 year ]################
################[ Charlie Hack                        ]################
################[ 4/7/2015                            ]################
#######################################################################


# inspiration and most of the code from: 
# http://blue.for.msu.edu/lab-notes/NOAA_0.1-1/NOAA-ws-data.pdf
#     by Paul L. Delamater, Andrew O. Finley, and Chad Babcock
#
# need to have the following directory structure in place:
#
# - root
#   - data
#     - raw
#     - csv


# # state and year to download from
# state <- "CO"
# year <- 2015

# # download station list csv
# write("getting isd-history.csv from ncdc...", stdout())
# write(" ", stdout())
# isd_history <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv"
# repeat {
#     try(download.file(isd_history, "data/isd-history.csv", quiet=FALSE))
#     if (file.info("data/isd-history.csv")$size > 0) {break}
# }

# # read csv
# write("reading in contents...", stdout())
# write(" ", stdout())
# hst <- read.csv("data/isd-history.csv")

# # labels and scaling
# write("restricting dataset to us, applying scaling...", stdout())
# write(" ", stdout())
# names(hst)[c(3, 9)] <- c("NAME", "ELEV") 
# hst <- hst[hst$CTRY %in% c("US", "CA"),]
# hst$LAT <- hst$LAT/1000
# hst$LON <- hst$LON/1000
# hst$ELEV <- hst$ELEV/10
# hst$BEGIN <- as.numeric(substr(hst$BEGIN, 1, 4))
# hst$END <- as.numeric(substr(hst$END, 1, 4))

# # make list of stations that match year and state
# write("restricting dataset to stations matching state and time params...", stdout())
# write(" ", stdout())
# co.list <- hst[hst$BEGIN <= year & hst$END >= year & !is.na(hst$BEGIN), ]
# outputs <- as.data.frame(matrix(NA, dim(co.list)[1], 2))

# # download. this can take a while.
# write("downloading station data...", stdout())
# write(" ", stdout())
# for (y in year:year) {
#     y.co.list <- co.list[co.list$BEGIN <= y & co.list$END >= y, ]
#     for (s in 1:dim(y.co.list)[1]) {
#         outputs[s, 1] <- paste(sprintf("%06d", y.co.list[s,1]), "-", sprintf("%05d", y.co.list[s,2]), "-", y, ".gz", sep="")
#         wget <- paste("wget -P data/raw ftp://ftp.ncdc.noaa.gov/pub/data/noaa/", y, "/", outputs[s,1], sep="")  # need a directory called data/raw/
#         outputs[s, 2] <- try(system(wget, intern=FALSE, ignore.stderr=TRUE))
#         write(toString(outputs[s,]), stdout())
#     }
# }

# unpack gzipped archives
write("unzipping...", stdout())
write(" ", stdout())
system("gunzip -r data/raw", intern=FALSE, ignore.stderr=TRUE)

# read fixed-width files, apply some transformations and dump to csv
write("reading in station data and preprocessing...", stdout())
write(" ", stdout())
files <- list.files("data/raw/")

# this next bit refers to the PDF documenting the data format. very brittle, let's hope they don't change it
column.widths <- c(4,6,5,4,2,2,2,2,1,6,7,5,5,5,4,3,1,1,4,1,5,1,1,1,6,1,1,1,5,1,5,1,5,1)
stations <- as.data.frame(matrix(NA, length(files), 6))
names(stations) <- c("USAFID", "WBAN", "YR", "LAT", "LONG", "ELEV")
for (i in 1:length(files)) {
    write(paste("preprocessing ", files[i], "...", sep=""), stdout())
    data <- read.fwf(paste("data/raw/", files[i], sep=""), column.widths)
    data <- data[, c(2:8, 10:11, 13, 16, 19, 29, 31, 33)]
    names(data) <- c("USAFID", "WBAN", "YR", "M", "D", "HR", "MIN", "LAT", "LONG", "ELEV", "WIND.DIR", "WIND.SPD", "TEMP", "DEW.POINT", "ATM.PRES")
    data$LAT <- data$LAT/1000
    data$LONG <- data$LONG/1000
    data$WIND.SPD <- data$WIND.SPD/10
    data$TEMP <- data$TEMP/10
    data$DEW.POINT <- data$DEW.POINT/10
    data$ATM.PRES <- data$ATM.PRES/10
    write(paste("writing", toString(files[i]), "to csv..."), stdout())
    write.csv(tail(data, n=5), file=paste("data/csv/", files[i], ".csv", sep=""), row.names=FALSE)  # needs to be a directory called data/csv/
    stations[i,1:3] <- data[1,1:3]
    stations[i,4:6] <- data[1,8:10]
    write(paste("wrote ", toString(files[i]), ".csv", sep=""), stdout())
    write(" ", stdout())
}

# write "index" csv of stations with meta info.
write("writing index file, stations.csv...", stdout())
write.csv(stations, file="data/stations.csv", row.names=FALSE)
write("done.", stdout())
write(" ", stdout())
