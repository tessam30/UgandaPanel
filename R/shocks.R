# --- Plotting LSMS/RIGA panel data for map products
# Date: 2015.04
# By: Tim Essam, Phd
# For: USAID GeoCenter

# --- Clear workspace, set library list
remove(list = ls())
libs <- c ("reshape", "ggplot2", "dplyr", "RColorBrewer", "grid")

# --- Load required libraries
lapply(libs, require, character.only=T)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdh)

# --- Read in as a dplyr data frame tbl
d <- tbl_df(read.csv("UGA_201504_all.csv"))

# --- Tabulation statistics of interest
shktab <- table(d$year, d$hazardShk, d$stratumP)
ftable(shktab)

# --- Group stat of interest by year and stratumP
# Calculate the std. err for proporitions using sqrt(p*(1-p)/n)
hzdshk <- group_by(d, year, stratumP)
hzd <- summarise(hzdshk, 
                 shock = mean(hazardShk, na.rm = TRUE),
                 shock.n = n(),
                 shock.se = sqrt(shock*(1-shock)/shock.n))
                 

# --- remove rows missing stratumP information
hzd <- subset(hzd, hzd$stratumP!="")

ggplot(hzd, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 21, fill = "white", size = 3) + 
  facet_wrap(~ stratumP) + stat_smooth(method = "loess", size = 1) +
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) + 
  theme_bw()







