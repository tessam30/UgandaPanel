# Purpose: Crack open LSMS data, offset GPS, and plot a bit and look at spat. corr.
# Author: Tim Essam (GeoCenter / OakStream Systems, LLC)
# Required packages: lots of spatial package
# Date: 3/31/2015

# Clear the workspace
remove(list=ls())

# ---- Get rpivotTable package
install_github("smartinsightsformdata/rpivotTable")

# load libraries for use in tinkering with data
libs <- c ("geoR", "akima", "leaflet", "dplyr", "lattice",
           "sp", "maptools", "raster", "rgdal", "maps", "mapdata",
           "RgoogleMaps", "mapproj", "RColorBrewer", "ape", 
           "haven", "rpivotTable", "dplyr")

# Load required libraries
lapply(libs, require, character.only=T)

# Set working directory to Ethiopia project
wdw <- c("U:/Uganda/Export")
wdh <- c("c:/Users/Tim/Documents/UgandaPanel/Dataout")
setwd(wdh)

# ----- Use new package to crack open Stata data
d <- read_dta("RigaPanel.dta")

# ----- Use new pivot table package to visualize data
rpivotTable(d, rows = "year", col = "fhh", aggregatorName = "Average",
            vals = "pcexp", rendererName = "Treemap")

# ----- Plot the data to see distributions in space
dsub <- dplyr::select(d, -hh)
dsub <- dplyr::filter(dsub, year = 2009)



