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
d <- read.csv("GeovarsPanel.csv", header=TRUE)

# Use geoR package to jitter the stacked coordinates
gps <- subset(d, select = c(lat_stack, lon_stack))
jitgps <- jitter2d(gps, max=0.01)
names(jitgps)[names(jitgps) == "lat_stack"] <- "latitude"
names(jitgps)[names(jitgps) == "lon_stack"] <- "longitude"
                      
# Subset data to be recobined with both sets of GIS info
geo <- cbind(d, jitgps)

# Export jittered data to GIS/export folder
write.csv(geo, "GPSjitterPanel.csv")

# Export three cuts of data to see lot/long over time using leaflet maps
table(d$ptrack, d$year)


dbeg <- subset(geo, year == 2009, select = c(latitude, longitude, ptrack))
dmid <- subset(geo, year == 2010 & ptrack == 2, select = c(latitude, longitude, ptrack))
dend <- subset(geo, year == 2011 & ptrack == 3 , select = c(latitude, longitude, ptrack))

# ---- Make maps of begging
mbeg <- leaflet(dbeg) %>% 
        addCircles(lat = ~ latitude, lng = ~ longitude) %>% 
        addTiles()
mbeg

# ---- 2nd wave of data (new entries)
mmid <- leaflet(dmid) %>% 
        addCircles(lat = ~ latitude, lng = ~ longitude, color = "red") %>% 
        addTiles() 
mmid

# ---- 3rd wave of data 
mend = leaflet(dend) %>% 
        addCircles(lat = ~ latitude, lng = ~ longitude, color = "blue") %>% 
        addTiles()
mend

levels(geo$ptrack)[1]<- "one wave"
levels(geo$ptrack)[2]<- "two waves"
levels(geo$ptrack)[3]<- "three waves"
geo$ptrackM <- geo$ptrack*2

# Assign a reversed color brewer palette to the map
cols <- rev(brewer.pal(length(levels(geo$ptrack)), "Spectral"))
geo$colors <- cols[unclass(geo$ptrack)]
test <-leaflet(geo) %>%
        addCircles(lat = ~latitude, lng = ~ longitude, 
                   color = ~colors, radius = ~ptrackM) %>%
        addTiles()
test