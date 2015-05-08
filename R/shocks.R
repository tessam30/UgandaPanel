# --- Plotting LSMS/RIGA panel data for map products
# Date: 2015.04
# By: Tim Essam, Phd
# For: USAID GeoCenter

# --- Clear workspace, set library list
remove(list = ls())
libs <- c ("reshape", "ggplot2", "dplyr", "RColorBrewer", "grid", "scales", "stringr", "directlabels")

# --- Load required libraries
lapply(libs, require, character.only=T)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdw)

# --- Read in as a dplyr data frame tbl
d <- tbl_df(read.csv("UGA_201504_all.csv"))

# --- Tabulation statistics of interest
shktab <- table(d$year, d$hazardShk, d$stratumP)
ftable(shktab)

# Lab RGB colors
redL   <- c("#B71234")
dredL  <- c("#822443")
dgrayL <- c("#565A5C")
lblueL <- c("#7090B7")
dblueL <- c("#003359")
lgrayL <- c("#CECFCB")

# --- Setting predefined color schema; and dpi settings
clr = "YlOrRd"
dpi.out = 500

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


# --- Generate a start date
startDate <- as.Date("2009-01-01")
xm <- seq(startDate, by = "month", length.out = 36)

# --- Create a date for each observation in panel
d$date <- as.Date(paste(c(d$year), c(d$month), c(1), sep="-"))
head(subset(d, select = c(year, month, date )))

# --- Subset data to remove any observations with no stratum information
dsub <- filter(d, stratumP !="")


# --- Create a generic ggplot function for exploratory purposes
# Note the use of "aes_string" to incorporate variables into ggplot call

myplot <- function(x, y, z){
  ggplot(dsub, aes_string(x = x, y = y, colour = z)) + facet_wrap(~stratumP, ncol = 6) + 
  geom_smooth(method = "loess", size = 1, se = "FALSE") + 
  g.spec
}

myplot("year", "totincome1", "stratumP")

# --- Food security indicators (FCS & dietary diversity) alongside stunting/wasting/underweight

dsub$stratumP <- factor(dsub$stratumP, levels = c("West Rural", "North Rural", "East Rural", 
                                                  "Central Rural", "Other Urban", "Kampala"))
ggplot(dsub, aes(x = date, y = dietDiv, colour = stratumP)) +
  stat_smooth(method = "loess") + facet_wrap(~ stratumP, ncol = 6) +
  g.spec + scale_x_date(breaks = date_breaks("12 months"),
                        labels = date_format("%Y")) +
  scale_y_continuous(breaks = seq(0, 12, 2), limits = c(0,12)) + # customize y-axis
  labs(x = "", y = "Average number of food groups consumed\n", # label y-axis and create title
       title = "Households in Western Rural zones lag behind in dietary diversity scores.", size = 13)
  
# --- Add accompanying distribution plot to show how data cluster
ggplot(dsub, aes(dietDiv, colour = year)) + facet_wrap(year ~stratumP, ncol = 6 ) + 
  geom_density(aes(y = ..count..)) + g.spec + scale_colour_brewer(palette="Set2") # apply faceting and color palette

# --- Add FCS indicators by region
dsub$stratumP <- factor(dsub$stratumP, levels = c("North Rural", "West Rural", "East Rural", 
                                                  "Central Rural", "Other Urban", "Kampala"))

ggplot(dsub, aes(x = date, y = FCS, colour = stratumP)) + 
  stat_smooth(method = "loess", size = 1.25) + facet_wrap(~ stratumP, ncol = 6) + geom_point(alpha=0.15)+ 
  g.spec + scale_x_date(breaks = date_breaks("12 months"),
                        labels = date_format("%Y")) +
  scale_y_continuous(breaks = seq(0, 110, 10 ), limits = c(0,110)) + # customize y-axis
  labs(x = "", y = "Average number of food groups consumed\n", # label y-axis and create title
       title = "Households in North rural zones lag behind in food consumption scores.", size = 13)

# Plot distribution of data by years (not that interesting)
dsub$fyear <- as.factor(dsub$year)
ggplot(dsub, aes(x = FCS, fill = fyear)) + geom_density(aes(y = ..count..), alpha=0.3) 

# --- Stunting indicators at individual level
# --- Read in as a dplyr data frame tbl
d.ind <- tbl_df(read.csv("UGA_201504_ind_all.csv"))

# Look at stunting by months of age across regions
# First cross-tabulate data to get percentages for each region
library(gmodels)
d.indf <- filter(d.ind, stunted!="NA", stratumP!="") 

CrossTable(d.indf$stunted, d.indf$stratumP)

# Relevel factors for stratum to get order on graphics
d.indf$stratumP <- factor(d.indf$stratumP, levels = c("West Rural", "East Rural", "North Rural", 
                                                  "Central Rural", "Kampala", "Other Urban"))

# Graph smoothed stunting rates with data jittered  
ggplot(d.indf[d.indf$year == 2009, ], aes(x = ageMonths, y = stunted, colour = stratumP)) + 
  stat_smooth(method = "loess", linesize = 1.5) +
  facet_wrap(~stratumP, ncol=3) + 
  g.spec + geom_point(alpha=0.15, jitter= TRUE) + # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "Child stunting was most prevalent in the West Rural region in 2009.", size = 13)


# Graph smoothed stunting rates with data jittered  
ggplot(d.indf[d.indf$year == 2010, ], aes(x = ageMonths, y = stunted, colour = stratumP)) + 
  stat_smooth(method = "loess", linesize = 1.5) +
  facet_wrap(~stratumP, ncol=3) + 
  g.spec + geom_point(alpha=0.15, jitter= TRUE) + # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "Child stunting was most prevalent in the West Rural region in 2010", size = 13)


# Graph smoothed stunting rates with data jittered  
ggplot(d.indf[d.indf$year == 2011, ], aes(x = ageMonths, y = stunted, colour = stratumP)) + 
  stat_smooth(method = "loess", linesize = 1.5) +
  facet_wrap(~stratumP, ncol=3) + 
  g.spec + geom_point(alpha=0.15, jitter= TRUE) + # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "Child stunting was most prevalent in the West Rural region in 2011", size = 13)


# Graph smoothed stunting rates with data jittered  
ggplot(d.indf, aes(x = ageMonths, y = stunted, colour = stratumP)) + 
  stat_smooth(method = "loess", linesize = 1.5) +
  facet_wrap(stratumP, ncol=3) + 
  g.spec + geom_point(alpha=0.15, jitter= TRUE) + # customize y-axis
  labs(x = "Age of child (in months)", y = "Percent stunted\n", # label y-axis and create title
       title = "Child stunting was most prevalent in the West Rural region in 2011", size = 13)





# --- convert binaries of interest into factors for cdplot
d$hzdShock <- as.factor(d$hazardShk)
d$hlthShock <- as.factor(d$healthShk)
d$crimeShock  <- as.factor(d$crimeShk)

# --- subset the data
dsub.nine <- subset(d, year== 2009)
dsub.ten <- subset(d, year== 2010)
dsub.elev <- subset(d, year== 2011)

# --- Plot conditional density of shocks versus various dep vars
cdplot(crimeShock ~ depRatio, data = dsub.nine)



# --- Hazard plots
dsub$stratumP <- factor(dsub$stratumP, levels = c("North Rural", "Central Rural", "West Rural", 
                                                  "East Rural", "Other Urban", "Kampala"))


# --- Create a plot that fits a binomial glm function to the data for each region
ggplot(filter(dsub, hazardShk!="NA"), aes(x = date, y = hazardShk, colour = stratumP)) +  facet_wrap(~stratumP, ncol = 6) + 
  stat_smooth(method = "glm", family = "binomial", size = 1.5, geom = "line", ) + 
  g.spec + scale_y_continuous(lim=c(0,1)) + 
  scale_x_date(breaks = date_breaks("12 months"),labels = date_format("%Y")) +
  geom_hline(yintercept = c(0.5), linetype = "dotted", size = 1, alpha = 0.125) +
  geom_hline(yintercept = c(0.25, 0.75), linetype = "dotted", size = 1, alpha = 0.10) 
  

# --- Same plot for health shocks, but first reorder facets for plotting in order
dsub$stratumP <- factor(dsub$stratumP, levels = c("East Rural", "North Rural", "Central Rural", 
                                            "West Rural", "Other Urban", "Kampala"))

end <- max(dsub$date)
ggplot(dsub, aes(x = date, y = healthShk, colour = stratumP)) + facet_wrap(~stratumP, ncol = 3) + 
  stat_smooth(method = "glm", family = "binomial", size = 1, geom = "line") + 
  g.spec + scale_y_continuous(limits = c(0,1)) + 
  scale_x_date(breaks = date_breaks("12 months"),labels = date_format("%Y")) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = .125)


# --- same plot for crime shocks
dsub$stratumP <- factor(dsub$stratumP, levels = c("Central Rural", "East Rural", "Other Urban", 
                                                  "North Rural", "Kampala", "West Rural"))

ggplot(dsub, aes(x = date, y = crimeShk, colour = stratumP)) + facet_wrap(~stratumP, ncol = 3) + 
  stat_smooth(method = "glm", family = "binomial", size = 1, geom = "line") + 
  g.spec + scale_x_date(breaks = date_breaks("12 months"), labels = date_format("%Y"))


# --- Look at dependency ratios overtime and resort to order
dsub$stratumP <- factor(dsub$stratumP, levels = c("North Rural", "East Rural", "West Rural", 
                                                  "Central Rural", "Other Urban", "Kampala"))

ggplot(dsub, aes(x = year, y = depRatio, colour = stratumP)) + facet_wrap(~stratumP, ncol = 6) + 
  geom_smooth(method = "loess", size = 1, se = "FALSE") + 
  g.spec


# --- What about farm specializations overtime across regions
myplot(dsub$mhh)









# --- Group and summarise shock data
shkH <- group_by(d, year, stratumP) %>%
    summarise(shock = mean(hazardShk, na.rm = TRUE), # create mean values for shock
            shock.n = n(), 
            shock.se = sqrt(shock*(1-shock)/shock.n)) %>% # calculate standard error
    filter(stratumP !="") # Filter missing values of stratum variable

# --- Round off and convert to percentage
shkH$rdshock <- percent(round(shkH$shock, digits = 2)) 

# Re-order factors for plotting in order
shkH$stratumP <- factor(shkH$stratumP, levels = c("North Rural", "Central Rural", "West Rural", 
                                                  "East Rural", "Other Urban", "Kampala"))
# --- Create ggplot of data
p <-ggplot(shkH, aes(x = year, y = shock, colour = stratumP)) + 
      geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
      facet_wrap(~ stratumP, ncol = 6) + 
      #geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
      geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
        #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
      g.spec + 
      scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
      scale_y_continuous(limits = c(0,1)) + # customize y-axis
      labs(x = "", y = "Percent of households reporting shock\n", # label y-axis and create title
         title = "Natural hazards (droughts, floods & fires) are the most common  household shocks across Uganda", size = 13) +
      scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)










# Run same analysis for health shocks
shkHlth <- group_by(d, year, stratumP) %>%
      summarise(shock = mean(healthShk, na.rm = TRUE),
                shock.n = n(),
                shock.se = sqrt(shock*(1-shock)/shock.n)) %>%
      filter(stratumP !="")
# Re-order factors for plotting in order
shkHlth %>% arrange(desc(shock, year))
shkHlth$stratumP <- factor(shkHlth$stratumP, levels = c("East Rural", "Central Rural", "North Rural", 
                                                  "West Rural", "Other Urban", "Kampala"))


# --- Create ggplot of data
p <-ggplot(shkHlth, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
  facet_wrap(~ stratumP, ncol = 6) + 
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
  
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
  g.spec + 
  scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
  scale_y_continuous(limits = c(0,1)) + # customize y-axis
  labs(x = "", y = "Percent of households reporting shock\n", # label y-axis and create title
       title = "Health shocks are second most common type of shock.", size = 13) +
  scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p






# Run same analysis for crime shocks
shkCr <- group_by(d, year, stratumP) %>%
  summarise(shock = mean(crimeShk, na.rm = TRUE),
            shock.n = n(),
            shock.se = sqrt(shock*(1-shock)/shock.n)) %>%
  filter(stratumP !="")
# Re-order factors for plotting in order
shkCr %>% arrange(desc(shock, year))
shkCr$stratumP <- factor(shkCr$stratumP, levels = c("Central Rural", "East Rural", "Other Urban", 
                                                        "North Rural", "Kampala", "West Rural"))

# --- Create ggplot of data
p <-ggplot(shkHlth, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
  facet_wrap(~ stratumP, ncol = 6) + 
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
  
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
  g.spec + 
  scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
  scale_y_continuous(limits = c(0,1)) + # customize y-axis
  labs(x = "", y = "Percent of households reporting shock\n", # label y-axis and create title
       title = "Crime shocks have steadily declined since 2009.", size = 13) +
  scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)


# --- Look at mosquito net use in the household (does anyone use nets?)
mosq <- group_by(d, year, stratumP) %>%
  summarise(shock = mean(mosqNet, na.rm = TRUE),
            shock.n = n(),
            shock.se = sqrt(shock*(1-shock)/shock.n)) %>%
  filter(stratumP !="")
# Re-order factors for plotting in order
mosq %>% arrange(desc(shock, year))

# rearrange factor variables to show trends in order
mosq$stratumP <- factor(mosq$stratumP, levels = c("Kampala", "East Rural", "North Rural", 
                                                        "Other Urban", "Central Rural", "West Rural"))
# Plot use overtime
p <-ggplot(mosq, aes(x = year, y = shock, colour = stratumP)) + 
  geom_point(shape = 16, fill = "white", size = 4) +stat_smooth(method = "loess", size = 1) +
  facet_wrap(~ stratumP, ncol = 6) + 
  geom_errorbar(aes(ymin = shock - shock.se, ymax = shock + shock.se, width = 0.1)) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = 0.10) +
  
  #geom_text(aes(x = year, y = shock, ymax = shock, label = rdshock, vjust = 0, hjust = .2)) +
  g.spec + 
  scale_x_continuous(breaks = seq(2009, 2011, 1)) + #customize x-axis
  scale_y_continuous(limits = c(0,1)) + # customize y-axis
  labs(x = "", y = "Percent of households using mosquito nets\n", # label y-axis and create title
       title = "Mosquito net use.", size = 13) +
  scale_colour_brewer(palette="Set2") # apply faceting and color palette
print(p)









# --- Explort food consumption scores
# Create mean value by statrum for each year

d$FCSmean <- group_by(d, year, stratumP) %>% mutate(mean(FCS, na.omit = TRUE))

c <- ggplot(d, aes(FCS, fill = stratumP)) + facet_wrap(stratumP ~ year)
pp <- c + geom_density(aes(y = ..count..)) + 
  geom_vline(d, aes(xintercept = FCSmean ), linetype = "dashed", size = 1)










