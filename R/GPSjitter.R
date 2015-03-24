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
wdh <- c("c:/Users/Tim/Documents/Uganda/Export")
setwd(wdh)

# Read in data; subset GPS info and jitter for no overlap
d <- read.csv("UgandaGeo.csv", header=TRUE)

#Drop records with missing lat/lon values
d <- na.omit(d)

# Use geoR package to jitter the stacked coordinates
gps <- subset(d, select = c(longitude, latitude))
jitgps <- jitter2d(gps, max=0.01)

# Subset data to be recobined with GIS info
data <- subset(d, select = c(hid))
geo <- cbind(jitgps, data)

# Export jittered data to GIS/export folder
write.csv(geo, "GPSjitter.csv")

