#######################################################################
################[ Get State Level ISD Data for 1 year ]################
################[ Charlie Hack, 4/7/2015              ]################
################[ borrows freely from this guide:     ]################
###[ http://blue.for.msu.edu/lab-notes/NOAA_0.1-1/NOAA-ws-data.pdf ]###
#######################################################################

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
state.list <- hst[hst$STATE == state & (hst$BEGIN <= year & hst$END >= year & !is.na(hst$BEGIN)), ]
outputs <- as.data.frame(matrix(NA, dim(state.list)[1], 2))

# download
for (y in year:year) {
    y.state.list <- state.list[state.list$BEGIN <= y & state.list$END >= y, ]
    for (s in 1:dim(y.state.list)[1]) {
        write(".", stdout())
        outputs[s, 1] <- paste(sprintf("%06d", y.state.list[s,1]), "-", sprintf("%05d", y.state.list[s,2]), "-", y, ".gz", sep = "")
        wget <- paste("wget -P data/raw ftp://ftp.ncdc.noaa.gov/pub/data/noaa/", y, "/", outputs[s,1], sep = "")
        outputs[s, 2] <- try(system(wget, intern = FALSE, ignore.stderr = TRUE))
    }
}