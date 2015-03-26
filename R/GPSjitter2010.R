# Purpose: Crack open LSMS data, offset GPS, and plot a bit and look at spat. corr.
# Author: Tim Essam (GeoCenter / OakStream Systems, LLC)
# Required packages: lots of spatial package
# Date: 2/23/2015

# Clear the workspace
remove(list=ls())

# load libraries for use in tinkering with data
libs <- c ("geoR", "akima", "leaflet", "dplyr", "lattice",
           "sp", "maptools", "raster", "rgdal", "maps", "mapdata",
           "RgoogleMaps", "mapproj", "RColorBrewer", "ape")

# Load required libraries
lapply(libs, require, character.only=T)

# Set working directory to Ethiopia project
wdw <- c("U:/Uganda/Export")
wdh <- c("c:/Users/Tim/Documents/UgandaPanel/Export")
setwd(wdh)

# Read in data; subset GPS info and jitter for no overlap
d <- read.csv("UgandaGeo2010.csv", header=TRUE)
d$hh <- d$HHID

# Rename lat lon variables
names(d)[names(d) == "lat_mod"] <- "latitude"
names(d)[names(d) == "lon_mod"] <- "longitude"

# Use geoR package to jitter the stacked coordinates
gps <- subset(d, select = c(longitude, latitude))
gps <- na.omit(gps)
jitgps <- jitter2d(gps, max=0.01)

# Subset data to be recobined with both sets of GIS info
data <- subset(d, select = c(hh, longitude, latitude))
data <- na.omit(data)
names(data)[names(data) == "latitude"] <- "lat_stack"
names(data)[names(data) == "longitude"] <- "lon_stack"

# Combine both sets of data
geo <- cbind(jitgps, data)

# Add in a year for identification when merging in Stata
geo$year <- rep(2010, dim(geo)[1])

# Export jittered data to GIS/export folder
write.csv(geo, "GPSjitter2010.csv")

