# --- Plotting LSMS/RIGA panel data for map products
# Date: 2015.04
# By: Tim Essam, Phd
# For: USAID GeoCenter

# --- Clear workspace, set library list
remove(list = ls())
libs <- c ("reshape", "ggplot2", "dplyr", "RColorBrewer", "grid", "scales", "stringr", "directlabels", "gmodels")

# Lab RGB colors
redL   <- c("#B71234")
dredL  <- c("#822443")
dgrayL <- c("#565A5C")
lblueL <- c("#7090B7")
dblueL <- c("#003359")
lgrayL <- c("#CECFCB")

# --- Load required libraries
lapply(libs, require, character.only=T)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdw)

# Create settings for fitting a smooth trendline
stat.set <- stat_smooth(method = "loess", size = 1, se = "TRUE", span = 1, alpha = 1)


# --- Set plot specifications for reuse throughout file
g.spec <- theme(legend.position = "none", legend.title=element_blank(), 
                panel.border = element_blank(), legend.key = element_blank(), 
                legend.text = element_text(size = 14), #Customize legend
                plot.title = element_text(hjust = 0, size = 17, face = "bold"), # Adjust plot title
                panel.background = element_rect(fill = "white"), # Make background white 
                panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #remove grid    
                axis.text.y = element_text(hjust = -0.5, size = 14, colour = dgrayL), #soften axis text
                axis.text.x = element_text(hjust = .5, size = 14, colour = dgrayL),
                axis.ticks.y = element_blank(), # remove y-axis ticks
                axis.title.y = element_text(colour = dgrayL),
                #axis.ticks.x=element_blank(), # remove x-axis ticks
                #plot.margin = unit(c(1,1,1,1), "cm"),
                plot.title = element_text(lineheight = 1 ), # 
                panel.grid.major = element_blank(), # remove facet formatting
                panel.grid.minor = element_blank(),
                strip.background = element_blank(),
                strip.text.x = element_text(size = 13, colour = dgrayL, face = "bold"), # format facet panel text
                panel.border = element_rect(colour = "black"),
                panel.margin = unit(2, "lines")) # Move plot title up


# --- Stunting indicators at individual level
# --- Read in as a dplyr data frame tbl
d.ind <- tbl_df(read.csv("UGA_201504_ind_all.csv"))

# Look at stunting by months of age across regions
# First cross-tabulate data to get percentages for each region
library(gmodels)
d.indf <- filter(d.ind, stunted!="NA", stratumP!="", yearInt!="NA") 

CrossTable(d.indf$stunted, d.indf$stratumP)

# Relevel factors for stratum to get order on graphics

d.indf$stratumP <- factor(d.indf$stratumP, levels = c("West Rural", "North Rural", "East Rural", 
                                                      "Central Rural", "Kampala", "Other Urban"))

# --- First plot data overtime and ignore age
ggplot(d.indf, aes(x = stunting)) + geom_density(aes(fill = stratumP, y = ..count..)) + 
  facet_wrap(stratumP~year, ncol = 3) +
  geom_vline(xintercept = c(-2.0), alpha = 0.25, linetype ="dotted", size = 1) + g.spec


# Create labels for year variable
d.indf$year <- factor(d.indf$year, levels = c(2009, 2010, 2011), 
                        labels = c("2009/10", "2010/11", "2011/12"))


# Graph smoothed stunting rates with data jittered  
ggplot(d.indf, aes(x = ageMonths, y = wasted, colour = factor(gender))) + 
  stat_smooth(method = "loess", se = TRUE, span = 1.0, size = 1.15, alpha = 0.1 )+
  facet_wrap(~year, ncol = 3) +
  geom_point(alpha=0.15) + geom_jitter(position = position_jitter(height=0.05), alpha = 0.175) + 
  theme(legend.position="top", legend.key = element_blank(), legend.title=element_blank()) +
  # customize y-axis
  geom_hline(yintercept = c(0.5), linetype = "dotted", size = 1, alpha = .25) +
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "", size = 13) + g.spec1


# Graph smoothed stunting rates with data jittered  
ggplot(d.indf, aes(x = ageMonths, y = stunted, colour = year)) + 
  stat_smooth(method = "loess", se = FALSE, span = 1.0, size = 1.15, alpah = 0.05 )+
  facet_wrap(~stratumP, ncol = 3) +
  geom_point(alpha=0.15) + geom_jitter(position = position_jitter(height=0.05), alpha = 0.10) + 
  theme(legend.position="top", legend.key = element_blank(), legend.title=element_blank())+
  # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "", size = 13) + g.spec1

# Graph smoothed underweight rates with data jittered  
ggplot(d.indf, aes(x = ageMonths, y = underwgt, colour = factor(yearInt))) + 
  stat_smooth(method = "loess", se = FALSE, span = 1.0, size = 1.15, alpah = 0.05 )+
  #facet_wrap(~stratumP, ncol = 3) +
  geom_point(alpha=0.15) + geom_jitter(position = position_jitter(height=0.05), alpha = 0.10) + 
  theme(legend.position="top", legend.key = element_blank(), legend.title=element_blank())+
  # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent underweight \n", # label y-axis and create title
       title = "", size = 13)

# Graph smoothed stunting rates with data jittered  
ggplot(d.indf, aes(x = ageMonths, y = underwgt, colour = stratumP)) + 
  stat_smooth(method = "loess", se = TRUE, span = 1.0, size = 1.15, alpah = 0.05 )+
  facet_wrap(~stratumP, ncol = 3) +
  geom_point(alpha=0.15) + geom_jitter(position = position_jitter(height=0.05), alpha = 0.10) + 
  theme(legend.position="top", legend.key = element_blank(), legend.title=element_blank())+
  # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "", size = 13)

# graph percent in each category by region, over time
d.ind.stunt <- tbl_df(read.csv("UGA_201505_ind_stunt.csv"))
d.ind.stunt <- filter(d.ind.stunt, stratumP != "", stuntStatus != "")

ggplot(d.ind.stunt, aes(x = year, y = pctstuntStat, colour = stuntStatus)) + geom_line()
  #stat_smooth(method = "loess", se = FALSE, span = 1.0, size = 1.15, alpah = 0.05 )+
  facet_wrap(~stratumP, ncol = 3) +
  geom_point(alpha=0.15) + #geom_jitter(position = position_jitter(height=0.05), alpha = 0.10) + 
  theme(legend.position="top", legend.key = element_blank(), legend.title=element_blank())+
  # customize y-axis
  labs(x = "", y = "Percent of children with stunting classification \n", # label y-axis and create title
       title = "", size = 13) +
  scale_x_continuous(breaks = c(2009, 2010, 2011))






# Graph smoothed wasting rates with data jittered  
ggplot(d.indf, aes(x = ageMonths, y = underwgt, colour = stratumP)) + 
  stat.set +
  facet_wrap(stratumP ~ year, ncol=3) + 
  g.spec + geom_point(alpha=0.15) + geom_jitter(position = position_jitter(height=0.05), alpha = 0.10) + 
  # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "Child stunting was most prevalent in the West Rural region in 2009.", size = 13)

# Reshape data so it can be plotted 





# Scatter the data to see how indicators correlate

# --- First filter data to only get those w/ regional info
target <- c("West Rural", "East Rural", "North Rural", "Central Rural", "Kampala", "Other Urban")
ggplot(filter(d.indf, stratumP %in% target), aes(x = stunting, y = underweight)) + 
  geom_point()  + stat_binhex() + stat_smooth(method="loess", span=1) + facet_wrap(~year)

ggplot(filter(d.indf, stratumP %in% target), aes(x = stunting, y = wasting)) + 
  geom_point()  + stat_binhex() + stat_smooth(method="loess", span=1) + facet_wrap(~year)
