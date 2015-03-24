# Purpose: Create graphics of Food consumption scores and dietary diversity
# Author: Tim Essam, GeoCenter / OakStream Systems, LLC
# Date: 2/23/2015


# Clear the workspace
remove(list = ls())

# Load libraries & set working directory
libs <- c ("reshape", "ggplot2", "dplyr", "RColorBrewer", "grid")

# Load required libraries
lapply(libs, require, character.only=T)

# Set working directory for home or away
wd <- c("U:/Uganda/Export/")
wdh <- c("C:/Users/t/Documents/Uganda/Export")
setwd(wd)

# Load data and rename veg to vegetables
d <- read.csv("food.consumption.score.csv", header = T)
names(d)[names(d) == 'veg'] <- 'vegetables'

#Re-order columns based on food consumption patterns observed
# staples, oil, veg, sugar, meat, fruit, pulse, milk
d2 <- d[,c(1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15)]


# Change working directory to graphics folder (Graphs)
gphwd <- c("C:/Users/t/Documents/Uganda/Graph")
gphwdw <- c("U:/Uganda/Graph/")
setwd(gphwdw)


# Lab RGB colors
redL   <- c("#B71234")
dredL  <- c("#822443")
dgrayL <- c("#565A5C")
lblueL <- c("#7090B7")
dblueL <- c("#003359")
lgrayL <- c("#CECFCB")

# Setting predefined color schema; and dpi settings
clr = "YlOrRd"
dpi.out = 500

# Reshape FCS categories for stacked area plot
mdata <- melt(d2, id=c("hid","FCS", "region", "urban", "subRegion", "district"))
names(mdata) <- c("ID", "FCS", "Region", "Urban", "SubRegion", "District", "Food", "Days")

# Check color palettes available.
display.brewer.all()

# Set fontsize for grobs to be included as text on graphs
fsize <- c(16)
fcolor <- c("gray50")

# Set FCS threshold values for Uganda
fcslow = c(21.5)
fcsmid = c(35)


# Create customized text as grob to be inserted
my_grobP = grobTree(textGrob("Poor", x=0.06,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
my_grobB = grobTree(textGrob("Borderline", x=0.205,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
my_grobA = grobTree(textGrob("Acceptable", x=.63,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))

# Create stacked area plot using ggplot2; First create basic layer
c <- ggplot(mdata, aes(FCS, Days, group = Food, colour = Food))

# Create smoothed lowess of the food categories where days ~ FCS; Add labeels and set x,y padding
pp <- c + stat_smooth(size = 1.25, se = FALSE) + labs(x ="Food Consumption Score", title = "Uganda Food Consumption Scores by Food Groups", 
         y = "Consumed (Days/Week)", colour = lgrayL) + scale_y_continuous(breaks = c(1:7), limits = c(0, 7.01), expand = c(0,0)) + 
  # Set the color schema and limits for x axis
  scale_colour_brewer(palette="Set2") + scale_x_continuous(breaks = seq(0, 110, by = 10), limits = c(0, 112), expand = c(0,0)) +
  
  # Create vertical lines at 21.5 and 35 which are thresholds for Bangladesh    
  geom_vline(xintercept=c(fcslow, fcsmid), linetype="dotted", size = 1) +
  
  # Order the legend, remove spaces around lines and adjust background colors and add bounding boxes for thresholds
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank(), 
        panel.background=element_rect(fill="white"), axis.ticks.y=element_blank(),
        axis.text.y  = element_text(hjust=0, size=10, colour = dgrayL), axis.ticks.x=element_blank(),
        axis.text.x  = element_text(hjust=0, size=10, colour = dgrayL),
        axis.title.x = element_text(colour=dgrayL , size=11), strip.background=element_rect(colour="white", fill="white"),
        axis.title.y=element_text(vjust=1.5, colour = dgrayL)) + annotate("rect", xmin = 0, xmax = fcslow, ymin = 0, ymax = 7,
        alpha = 0.25) + annotate("rect", xmin = fcslow, xmax = fcsmid, ymin = 0, ymax = 7,  alpha = 0.16) +
  annotation_custom(my_grobP) + annotation_custom(my_grobB) + annotation_custom(my_grobA) 
print(pp)
ggsave(pp, filename = paste("FCS.Country", ".png"), width=11, height=8, dpi = dpi.out)


c <- ggplot(mdata, aes(FCS, Days, group = Food, colour = Food))
# Same graphs but now faceted for the SubRegions in Uganda
fsize <- c(10)
# Create customized text as grob to be inserted
my_grobP = grobTree(textGrob("Poor", x=0.06,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
my_grobB = grobTree(textGrob("Borderline", x=0.205,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
my_grobA = grobTree(textGrob("Acceptable", x=.63,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))

pp <- c + stat_smooth(size = 0.80, se = FALSE) + labs(x ="Food Consumption Score", title = "Uganda Food Consumption Scores by Food Groups and Regions", 
      y = "Consumed (Days/Week)", colour = lgrayL) + scale_y_continuous(breaks = c(1:7), limits = c(0, 7.2), expand = c(0,0)) + 
# Set the color schema and limits for x axis
  scale_colour_brewer(palette="Set2") + scale_x_continuous(breaks = seq(0, 110, by = 10), limits = c(0, 112), expand = c(0,0)) +
  
# Create vertical lines at 28 and 42 which are thresholds for Bangladesh    
  geom_vline(xintercept=c(fcslow,fcsmid), linetype="dotted", size = 1) +
  
# Order the legend, remove spaces around lines and adjust background colors and add bounding boxes for thresholds
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank(), 
        panel.background=element_rect(fill="white"), axis.ticks.y=element_blank(),
        axis.text.y  = element_text(hjust=0, size=10, colour = dgrayL), axis.ticks.x=element_blank(),
        axis.text.x  = element_text(hjust=0, size=10, colour = dgrayL),
        axis.title.x = element_text(colour=dgrayL , size=11), strip.background=element_rect(colour="white", fill="white"),
        axis.title.y=element_text(vjust=1.5, colour = dgrayL)) + annotate("rect", xmin = 0, xmax = fcslow, ymin = 0, ymax = 7,
        alpha = 0.25) + annotate("rect", xmin = fcslow, xmax = fcsmid, ymin = 0, ymax = 7,  alpha = 0.16) +
  annotation_custom(my_grobP) + annotation_custom(my_grobB) + annotation_custom(my_grobA) +
  facet_wrap(~Region, ncol = 1)
print(pp)
ggsave(pp, filename = paste("FCS.Division", ".png"), width=10, height=14, dpi = dpi.out)


c <- ggplot(mdata, aes(FCS, Days, group = Food, colour = Food))
# Same graphs but now faceted for the SubRegions in Uganda
fsize <- c(6)
# Create customized text as grob to be inserted
my_grobP = grobTree(textGrob("Poor", x=0.075,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
my_grobB = grobTree(textGrob("Borderline", x=0.26,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
my_grobA = grobTree(textGrob("Acceptable", x=.63,  y=.55, hjust=0,
                             gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))
# Customize graphic
pp <- c + stat_smooth(size = 0.5, se = FALSE) + labs(x ="Food Consumption Score", title = "Bangladesh Food Consumption Scores by Food Groups (across LSMS Sub-Regions)", 
       y = "Consumed (Days/Week)", colour = lgrayL) + scale_y_continuous(breaks = c(1:7), limits = c(0, 7.2), expand = c(0,0)) + 
  # Set the color schema and limits for x axis
  scale_colour_brewer(palette="Set2") + scale_x_continuous(breaks = seq(0, 110, by = 10), limits = c(0, 110), expand = c(0,0)) +
  
  # Create vertical lines at 28 and 42 which are thresholds for Bangladesh    
  geom_vline(xintercept=c(fcslow,fcsmid), linetype="dotted", size = 1) +
  
  # Order the legend, remove spaces around lines and adjust background colors and add bounding boxes for thresholds
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank(), 
        panel.background=element_rect(fill="white"), axis.ticks.y=element_blank(),
        axis.text.y  = element_text(hjust=0, size=6, colour = dgrayL), axis.ticks.x=element_blank(),
        axis.text.x  = element_text(hjust=0, size=6, colour = dgrayL),panel.margin = unit(1.15, "lines"),
        axis.title.x = element_text(colour=dgrayL , size=11), strip.background=element_rect(colour="white", fill="white"),
        axis.title.y=element_text(vjust=1.5, colour = dgrayL)) + annotate("rect", xmin = 0, xmax = fcslow, ymin = 0, ymax = 7,
        alpha = .175) + annotate("rect", xmin = fcslow, xmax = fcsmid, ymin = 0, ymax = 7,  alpha = 0.075) +
  annotation_custom(my_grobP) + annotation_custom(my_grobB) + annotation_custom(my_grobA) +
  facet_wrap(~SubRegion, ncol = 1)
print(pp)
ggsave(pp, filename = paste("FCS.District", ".svg"), width=18, height=10, dpi = dpi.out)

fsize <- c(8)
my_grobP = grobTree(textGrob("Poor", x=0.075,  y=.55, hjust=0,
           gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))

# Make similar graphs but this time show the distribution of data
c <- ggplot(mdata, aes(FCS, fill = Region)) + facet_wrap(~Region)
pp <- c + geom_density(aes(y = ..count..)) + labs(x ="Food Consumption Score", title = "Uganda Food Consumption Score Distributions by Region", 
         y = "Number of Households", colour = lgrayL) + geom_vline(xintercept=c(fcslow,fcsmid), linetype="dotted", size = 1) +
  annotate("rect", xmin = 0, xmax = fcslow, ymin = 0, ymax = 200,
        alpha = .175) + annotate("rect", xmin = fcslow, xmax = fcsmid, ymin = 0, ymax = 200,  alpha = 0.075) +
  scale_x_continuous(breaks = seq(0, 100, by = 20), limits = c(0, 100), expand = c(0,0)) +
  scale_y_continuous(breaks = seq(0, 200, by = 25), limits = c(0, 200), expand = c(0,0)) +
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank(),
        panel.background=element_rect(fill="white"), axis.ticks.y=element_blank(), 
        axis.text.y  = element_text(hjust=0, size=6, colour = dgrayL), axis.ticks.x=element_blank(),
        axis.text.x  = element_text(hjust=0, size=6, colour = dgrayL), panel.margin = unit(1.15, "lines"),
        axis.title.x = element_text(colour=dgrayL , size=11), strip.background=element_rect(colour="white", fill="white"),
        axis.title.y=element_text(vjust=1.5, colour = dgrayL)) +  scale_fill_brewer(palette = "Pastel2" ) +
  guides(fill = guide_legend(override.aes = list(colour = NULL))) + annotation_custom(my_grobP)
pp
ggsave(pp, filename = paste("FCS.Distributions", ".png"), width=18, height=10, dpi = dpi.out)


colors()[c(189)] # Check the colors
# http://research.stowers-institute.org/efg/R/Color/Chart/ - tutorial/demo

fsize <- c(10)
fcolor <- c("gray40")
my_grobP = grobTree(textGrob("Poor", x=0.075,  y=.55, hjust=0,
           gp=gpar(col=fcolor , fontsize=fsize , fontface="italic")))

# Make similar graphs but this time show the distribution of data
c <- ggplot(mdata, aes(FCS, fill = Region)) + facet_wrap(~SubRegion, ncol = 2)
pp <- c + geom_density(aes(y = ..count..)) + labs(x ="Food Consumption Score", title = "Uganda Food Consumption Score Distributions by LSMS Sub-Regions", 
        y = "Number of Households", colour = lgrayL) + geom_vline(xintercept=c(fcslow,fcsmid), linetype="dotted", size = 1) +
  annotate("rect", xmin = 0, xmax = fcslow, ymin = 0, ymax = 90,
           alpha = .25) + annotate("rect", xmin = fcslow, xmax = fcsmid, ymin = 0, ymax = 90,  alpha = 0.175) +
  scale_x_continuous(breaks = seq(0, 100, by = 20), limits = c(0, 120), expand = c(0,0)) +
  scale_y_continuous(breaks = seq(0, 100, by = 25), limits = c(0, 90), expand = c(0,0)) +
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank(),
        panel.background=element_rect(fill="white"), axis.ticks.y=element_blank(), 
        axis.text.y  = element_text(hjust=0, size=6, colour = dgrayL), axis.ticks.x=element_blank(),
        axis.text.x  = element_text(hjust=0, size=6, colour = dgrayL), panel.margin = unit(1.15, "lines"),
        axis.title.x = element_text(colour=dgrayL , size=11), strip.background=element_rect(colour="white", fill="white"),
        axis.title.y=element_text(vjust=1.5, colour = dgrayL)) +  scale_fill_brewer(palette = "Set3" ) +
  guides(fill = guide_legend(override.aes = list(colour = NULL))) + annotation_custom(my_grobP)
pp
ggsave(pp, filename = paste("FCS.Distributions", ".png"), width=10, height=10, dpi = dpi.out)


* Create ggvis graph using data (not currenlty used).
mdata %>% 
  ggvis(~FCS, ~Days) %>%
  group_by(Food) %>%
  layer_model_predictions(model = "loess", se = FALSE, stroke = ~Food) %>%
  add_axis("x", title = "Food Consumption Score") %>%
  add_axis("y", title = "Consumed (days/week)")


################################
# Create diet diversity graphs #
################################

# Clear the workspace
remove(list = ls())

# Load dietary diversity data for another dimension of food security baseline
setwd(wd)
library(plyr)

# Set working directory again
wd <- c("C:/Users/t/Box Sync/Uganda/Export")
wdw <- c("U:/Uganda/Export")
setwd(wdw)

# Load data and rename veg to vegetables
dd <- read.csv("diet.diversity.csv", header = T)

# Lab RGB colors
redL     <- c("#B71234")
dredL   <- c("#822443")
dgrayL   <- c("#565A5C")
lblueL   <- c("#7090B7")
dblueL 	<- c("#003359")
lgrayL	<- c("#CECFCB")
dpi.out = 500

names(dd) <- c("Diet", "HHID", "Region", "SubRegion")

# Plot density of dietary diversity by District & Division

c <- ggplot(dd, aes(Diet, fill = Region)) + facet_wrap(~SubRegion, ncol = 2)
pp <- c + geom_density(aes(y = ..count..)) + labs(x = "Number of different foods consumed (dotted line represents LSMS sample average)", 
	title = "Uganda Dietary Diversity Score Distributions by LSMS Sub-Region", y = "Number of Households", colour = lgrayL) + 
  scale_x_continuous(breaks = seq(0, 12, by = 2), limits = c(0, 13), expand = c(0,0)) +
  scale_y_continuous(breaks = seq(0, 90, by = 25), limits = c(0, 90), expand = c(0,0)) +
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank(),
        panel.background=element_rect(fill="white"), axis.ticks.y=element_blank(), 
        #panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text.y  = element_text(hjust=0, size=6, colour = dgrayL), axis.ticks.x=element_blank(),
        axis.text.x  = element_text(hjust=0, size=6, colour = dgrayL), panel.margin = unit(1.15, "lines"),
        axis.title.x = element_text(colour=dgrayL , size=11), strip.background=element_rect(colour="white", fill="white"),
        axis.title.y=element_text(vjust=1.5, colour = dgrayL)) +  scale_fill_brewer(palette = "Set3" ) +
  guides(fill = guide_legend(override.aes = list(colour = NULL))) + geom_vline(aes(xintercept=mean(Diet, na.rm=T)),    
         color="gray50", linetype="dashed", size=0.5)
pp
setwd("U:/Uganda/Graph")
ggsave(pp, filename = paste("Diet.Diversity", ".png"), width=10, height=10, dpi = dpi.out)

