# --- Plotting LSMS/RIGA panel data for map products
# Date: 2015.04
# By: Tim Essam, Phd
# For: USAID GeoCenter

# --- Clear workspace, set library list
remove(list = ls())
libs <- c ("reshape", "ggplot2", "dplyr", "RColorBrewer", "grid", "scales", "stringr", "directlabels", "gmodels", "reshape")

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

# --- Preset ggplot backgrounds
g.spec1 <- theme(legend.position = "none", legend.title=element_blank(), 
                 panel.border = element_blank(), legend.key = element_blank(), 
                 legend.text = element_text(size = 12), #Customize legend
                 plot.title = element_text(hjust = 0, size = 17, face = "bold"), # Adjust plot title
                 panel.background = element_rect(fill = "white"), # Make background white 
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(), #remove grid    
                 axis.text.y = element_text(hjust = -0.5, size = 10, colour = dgrayL), #soften axis text
                 axis.text.x = element_text(hjust = .5, size = 10, colour = dgrayL),
                 axis.ticks.y = element_blank(), # remove y-axis ticks
                 axis.title.y = element_text(colour = dgrayL),
                 #axis.ticks.x=element_blank(), # remove x-axis ticks
                 #plot.margin = unit(c(1,1,1,1), "cm"),
                 panel.margin = unit(0.75, "lines"),
                 plot.title = element_text(lineheight = 1 ), # 
                 panel.grid.major = element_blank(), # remove facet formatting
                 panel.grid.minor = element_blank(),
                 strip.background = element_blank(),
                 strip.text.x = element_text(size = 10, colour = dgrayL, face = "bold"), # format facet panel text
                 panel.border = element_rect(colour = "black"),
                 panel.margin = unit(2, "lines")) # Move plot title up


# --- Setting predefined color schema; and dpi settings
clr = "YlOrRd"
dpi.out = 500

# --- Create a date for each observation in panel
d$date <- as.Date(paste(c(d$yearInt), c(d$monthInt), c(1), sep="-"))
head(subset(d, select = c(year, month, date )))

# --- Subset data to remove any observations with no stratum information
dsub <- filter(d, stratumP !="")


# plot settings
# Create settings for fitting a smooth trendline
stat.set1 <- stat_smooth(method = "loess", size = 1, se = "TRUE", span = 1, alpha = 1)

# Set alpha settings (for transparency -- below 1 is not good for Adobe illustrator exports)
transp <- c(1)
dpi.out <- c(300)


# -- Participation in economic activities -- #

# p_ag =  crop + livestock + agr_wage
# p_nonfarm = nonagr_wage + self emp
# p_trans = other + transfers

d.partic <- as.data.frame(select(dsub, p_ag, p_nonfarm, p_trans, HHID, date, stratumP, agehead, femhead, literateSpouse))

# Sort the data for plotting
d.partic$stratumP <- factor(d.partic$stratumP, levels = c("North Rural", "West Rural", "East Rural", 
                                                        "Central Rural", "Other Urban", "Kampala"))

names(d.partic) <- c("Agriculture", "Non-Agriculture", "Transfers", "id", "date", "Region", "age", "female", "lsp")
d.particm <- melt(d.partic, id=c("id", "date", "Region", "age", "female", "lsp"))

p <- ggplot(d.particm, aes(x = date, y = value, colour = variable)) +
  facet_wrap(~Region, ncol = 6) +   stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  theme(legend.position = "top", legend.title=element_blank(), 
        panel.border = element_blank(), legend.key = element_blank()) +
  scale_y_continuous(limits = c(0,1)) + 
    scale_x_date(breaks = date_breaks("12 months"),labels = date_format("%Y")) +
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = transp) +
  labs(x = "", y = "Percent of households participating in activity \n", # label y-axis and create title
       title = "", size = 13) +
  scale_color_brewer(palette="Set2")
#geom_jitter(position = position_jitter(height = 0.05), alpha = transp) 
print(p)


# -- Look into how this varies by age
p <- ggplot(d.particm, aes(x = age, y = value, colour = variable)) +
  facet_wrap(~Region, ncol = 6) +   stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  theme(legend.position = "top", legend.title=element_blank(), 
        panel.border = element_blank(), legend.key = element_blank()) +
        geom_jitter(alpha = 0.1, position = position_jitter(height=0.05)) +
        scale_y_continuous(limits = c(0,1)) + 
        geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = transp) +
  labs(x = "Age of household head", y = "Percent of households participating in activity \n") +
  scale_color_brewer(palette="Set2")
#geom_jitter(position = position_jitter(height = 0.05), alpha = transp) 
print(p)

# -- Look into how this varies by female headedness
d.particm$female <- factor(d.particm$female, levels = c(0, 1), 
                          labels = c("Male Headed", "Female Headed"))
d.particm <- filter(d.particm, female != "NA")

p <- ggplot(d.particm, aes(x = age, y = value, colour = variable)) +
  facet_wrap(~female, ncol = 2) + stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  theme(legend.position = "top", legend.title=element_blank(), 
        panel.border = element_blank(), legend.key = element_blank()) +
  geom_jitter(alpha = 0.1, position = position_jitter(height=0.05)) +
  scale_y_continuous(limits = c(0,1)) + 
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = transp) +
  labs(x = "Age of household head", y = "Percent of households participating in activity \n") +
  scale_color_brewer(palette="Set2")
  #geom_jitter(position = position_jitter(height = 0.05), alpha = transp) 
print(p)

# -- Look into how this varies by literate spouses
d.particm$lsp <- factor(d.particm$lsp, levels = c(0, 1), 
                           labels = c("Illiterate Spouse", "Literate Spouse"))
d.particm <- filter(d.particm, lsp != "NA")
p <- ggplot(d.particm, aes(x = age, y = value, colour = variable)) +
  facet_wrap(~lsp, ncol = 2) + stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  theme(legend.position = "top", legend.title=element_blank(), 
        panel.border = element_blank(), legend.key = element_blank()) +
  geom_jitter(alpha = 0.1, position = position_jitter(height=0.05)) +
  scale_y_continuous(limits = c(0,1)) + 
  geom_hline(yintercept = 0.5, linetype = "dotted", size = 1, alpha = transp) +
  labs(x = "Age of household head", y = "Percent of households participating in activity \n") +
  scale_color_brewer(palette="Set2")



remove(d.particm, d.partic)



# --- INCOME SHARES ----
# How do shares of income vary across regions?
d.incsh <- as.data.frame(select(dsub, sh1agr_wge, sh1nonagr_wge, sh1crop1, sh1livestock, 
          sh1selfemp, sh1transfer, sh1other, date, HHID, stratumP, pcexpend2011, yearInt, 
          totincome2011, agehead, femhead))

# - rename a few variables
names(d.incsh) <- c("Ag-Wage", "Non-Ag", "Crops", "livestock", "Self-Employment", "Transfers", "Other", "date", "id", "Region", "Expenditures", "Year", "Income", "age", "female")
d.incsh <- filter(d.incsh, Year != "NA")


d.incshm <- melt(d.incsh, id = c("id", "date", "Region", "Expenditures", "Year", "Income", "age", "female"))
d.incshm$Region <- factor(d.incshm$Region, levels = c("West Rural", "East Rural", "North Rural", 
                                                          "Central Rural", "Other Urban", "Kampala"))

d.incshm$female <- factor(d.incshm$female, levels = c(0, 1), 
                          labels = c("Male Headed", "Female Headed"))

# 
p <- ggplot(d.incshm, aes(x = date, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + facet_wrap(~Region, ncol = 6) +
  scale_y_continuous(limits = c(-0, 1))+
  geom_jitter(alpha = 0.1) + theme(legend.position="top", legend.key = element_blank(), legend.title=element_blank()) +
  labs(x = "", y = "Income share \n", # label y-axis and create title
       title ="", size =13) 
p


# Self-employment income shares constitute the largest value for the highest earners
pp <- ggplot(d.incshm, aes(x = Income, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0.0, size = 1.5, span = 1) + 
  scale_y_continuous(limits = c(-0, 1)) + scale_x_log10() +
  geom_jitter(alpha=0.15) + facet_wrap(~Region, ncol = 3) +
  theme(legend.position = "top", legend.title=element_blank(), panel.border = element_blank(), legend.key = element_blank()) +
  labs(x = "Total Income", y = "Income share \n")
pp

# These patterns hold across time
pp <- ggplot(d.incshm, aes(x = Income, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  scale_y_continuous(limits = c(-0, 1)) + scale_x_log10() +
  geom_jitter(alpha=0.15) + facet_wrap(~Year, ncol = 4) +
  theme(legend.position = "top", legend.title = element_blank(), legend.key = element_blank()) +
  labs(x = "Total Income", y = "Income share \n")
pp

# But varies by gender
d.incshm <- filter(d.incshm, female != "NA")

pp <- ggplot(d.incshm, aes(x = Income, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  scale_y_continuous(limits = c(-0, 1)) + scale_x_log10() +
  geom_jitter(alpha=0.15) + facet_wrap(~female, ncol = 4) +
  theme(legend.position = "top", legend.title = element_blank(), legend.key = element_blank()) +
  labs(x = "Total Income", y = "Income share \n")
pp


# -- INCOME SHARES VS. PC EXPENDITURES
pp <- ggplot(d.incshm, aes(x = Expenditures, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0.0, size = 1.5, span = 1) + 
  scale_y_continuous(limits = c(-0, 1)) + scale_x_log10() +
  geom_jitter(alpha=0.15) + facet_wrap(~Region, ncol = 3) +
  theme(legend.position = "top", legend.title=element_blank(), legend.key = element_blank()) +
  labs(x = "Per Capita Expenditures", y = "Income share \n")
pp


pp <- ggplot(filter(d.incshm, female!="NA"), aes(x = Expenditures, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0.0, size = 1.5, span = 1) + 
  scale_y_continuous(limits = c(-0, 1)) + scale_x_log10() +
  geom_jitter(alpha=0.15) + facet_wrap(~female, ncol = 3) +
  theme(legend.position = "top", legend.title=element_blank(), legend.key = element_blank()) +
  labs(x = "Per Capita Expenditures", y = "Income share \n")
pp

pp <- ggplot(d.incshm, aes(x = Expenditures, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 1) + 
  scale_y_continuous(limits = c(-0, 1)) + scale_x_log10() +
  geom_jitter(alpha=0.15) + facet_wrap(~Year, ncol = 4) +
  theme(legend.position = "top", legend.title = element_blank(), legend.key = element_blank()) +
  labs(x = "Per Capita Expenditures", y = "Income share \n")
pp


pp <- ggplot(d.incshm, aes(x = age, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0, size = 1.5, span = 0.75) + 
  scale_y_continuous(limits = c(-0, 1))  +
  geom_jitter(alpha=0.15) + facet_wrap(~Region, ncol = 3) +
  theme(legend.position = "top", legend.title = element_blank(), legend.key = element_blank()) +
  labs(x = "Age of head of household", y = "Income share \n")
pp


remove(d.inc, d.incm, d.incsh, d.incshm)




# Finally, look at specialization typologies and have they evolve over time
d.spec <- as.data.frame(select(dsub, fhh, fmhh, lhh, mhh, divhh, date, HHID, stratumP, pcexpend2011, yearInt, totincome2011, agehead, femhead))
names(d.spec) <- c("Farm", "Farm-Market", "Wages", "Migration", "Diversified" , "date", "id", "Region", "Expenditures", "Year", "Income", "age", "female")
d.spec <- filter(d.spec, Year != "NA")
d.spec$female <- factor(d.spec$female, levels = c(0, 1), 
                         labels = c("Male Headed", "Female Headed"))

d.specm <- melt(d.spec, id = c("id", "date", "Region", "Expenditures", "Year", "Income", "age", "female"))

d.specm$Region <- factor(d.specm$Region, levels = c("West Rural", "East Rural", "North Rural", 
                                                      "Central Rural", "Other Urban", "Kampala"))

# --- Special instructions: wanted to bring each plot to the top, so first use the factor
# command to reorder, then apply manual scale colors (Set 2) to make all gray except var of interest.

d.specm$variable <- factor(d.specm$variable, levels = c("Farm-Market", "Migration", "Farm",
                                                        "Wages", "Diversified"))

p <- ggplot(d.specm, aes(x = Year, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0.0, size = 1.5, span = 1, se = TRUE)+ 
  facet_wrap(~Region, ncol = 6) +
  scale_y_continuous(limits = c(-0, 1))+
  geom_jitter(alpha = 0.0, position = position_jitter(height = 0.05)) +
  theme(legend.position = "top", legend.key=element_blank(), legend.title = element_blank(),
        panel.background = element_rect(fill = "white"), # Make background white 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.grid.major = element_blank(), # remove facet formatting
        panel.grid.minor = element_blank(),
        strip.background = element_blank()) +
  labs(x = "", y = "Percent of households specializing in activity") +
  scale_color_manual(values=c("#A6D854", "#E78AC3", "#66C2A5", "#FC8D62", "#8DA0CB"))
p
# -- List color brewer colors to be used
brewer.pal(8, "Set2")
brewer.pal(8, "Accent")

d.specm09 <- filter(d.specm, Year == 2010)
p <- ggplot(d.specm, aes(x = Expenditures, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0.0, size = 1.5, span = 1, se = TRUE)+ 
  facet_wrap(~Region, ncol = 3) +
  scale_y_continuous(limits = c(-0, 1))+scale_x_log10()+
  geom_jitter(alpha = 0.10, position = position_jitter(height = 0.05)) +
  theme(legend.position = "top", legend.key=element_blank(), legend.title = element_blank(),
        panel.background = element_rect(fill = "white"), # Make background white 
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.grid.major = element_blank(), # remove facet formatting
        panel.grid.minor = element_blank(),
        strip.background = element_blank()) +
  labs(x = "", y = "Percent of households specializing in activity") +
  scale_color_manual(values=c("#A6D854", "#E78AC3", "#66C2A5", "#FC8D62", "#8DA0CB"))
p


p <- ggplot(d.specm, aes(x = age, y = value, colour = variable)) +
  stat_smooth(method = "loess", alpha = 0.3, size = 1.5, span = 1, se = TRUE) + 
  facet_wrap(~Region, ncol = 6) +
  scale_y_continuous(limits = c(-0, 1))+
  geom_jitter(alpha = 0.1, position = position_jitter(height = 0.05)) +
  theme(legend.position = "top", legend.key=element_blank(), legend.title = element_blank()) +
  labs(x = "age", y = "Percent of households specializing in activity") + 
  scale_color_brewer(palette = "Set2")
p





