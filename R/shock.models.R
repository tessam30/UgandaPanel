# Purpose: Run logistic regressions on shock variables
# Author: Tim Essam, PhD (USAID GeoCenter)
# Date: 2015/05/05
# packages: dplyr, coefplot, useful, ggplot2


# ---- Load required packages from library
# Clear the workspace
remove(list = ls())

# install.packages("devtools")
# devtools::install_github("hadley/haven")

# Load libraries & set working directory
libs <- c ("ggplot2", "useful", "dplyr", "RColorBrewer", "coefplot", 
           "stringr", "haven", "corrgram", "ellipse", "sandwich", "robust", "aod")

# Load required libraries
lapply(libs, require, character.only=T)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdw)


# --- Load in Riga + LSMS data for all years and subset into years
vul <- tbl_df(read.csv("UGA_201504_all.csv", header = TRUE, sep =",", stringsAsFactors = FALSE))

# - Filter out obs missing sampling information
vul <- filter(vul, stratumP !="", educHoh !="", intDate !="")


# Re-order stratumP to set Kampala as base
vul$stratumP <- factor(vul$stratumP, levels = c("Kampala", "Other Urban", "North Rural", 
                                                 "East Rural","West Rural", "Central Rural"))
vul$educHoh <- as.factor(vul$educHoh)
vul$educHoh <- factor(vul$educHoh, levels = c("No Eduction", "Pre-primary", "Primary", "Post-primary",
                                              "Junior Techincal/Vocational ", "Lower Secondary", "Upper Secondary",
                                              "Post-Secondary Specialized", "Tertiary"))


# Subset data for plotting/modeling
vul1 <- vul[vul$year == 2009, ]
vul2 <- vul[vul$year == 2010, ]
vul3 <- vul[vul$year == 2011, ]

# Check out correlation of variables
corr.d1 <- dplyr::select(vul1, anyshock, hazardShk, femhead, agehead, marriedHohp, hhsize, gendMix, mixedEth,
                 under5, youth15to24, depRatio, mlabor, flabor, literateHoh,
                 literateSpouse, educHoh, landless, agwealth, wealth, infraindex, hhmignet,
                 dist_road, dist_popcenter, dist_market, dist_borderpost, srtm_uga, stratumP)

corr.d2 <- dplyr::select(vul2, anyshock, hazardShk, femhead, agehead, marriedHohp, hhsize, gendMix, mixedEth,
                 under5, youth15to24, depRatio, mlabor, flabor, literateHoh,
                 literateSpouse, educHoh, landless, agwealth, wealth, infraindex, hhmignet,
                 dist_road, dist_popcenter, dist_market, dist_borderpost, srtm_uga, stratumP)

corr.d3 <- dplyr::select(vul3, anyshock, hazardShk,  femhead, agehead, marriedHohp, hhsize, gendMix, mixedEth,
                 under5, youth15to24, depRatio, mlabor, flabor, literateHoh,
                 literateSpouse, educHoh, landless, agwealth, wealth, infraindex, hhmignet,
                 dist_road, dist_popcenter, dist_market, dist_borderpost, srtm_uga, stratumP)


# Plot correlations for each year
corrgram(corr.d1, upper = panel.ellipse , lower.panel = panel.bar)
corrgram(corr.d2, upper = panel.ellipse , lower.panel = panel.bar)
corrgram(corr.d3, upper = panel.ellipse , lower.panel = panel.bar)

# --- List covariates of models
# hhchars = femhead + agehead + marriedHohp + hhsize + gendMix + mixedEth
# agechars = under5 + youth15to24 + depRatio + mlaborShare + flaborShare 
# educ  = literateHoh + literateSpouse + educHoh
# assets = landless + agwealth + wealth + infraindex + hhmignet
# geo = dist_road + dist_popcenter + dist_market + dist_borderpost + srtm_uga

# make a ggplot function for quick visualization of bivariate plots
ggplot(vul, aes(x = agwealth, y = hazardShk, colour = stratumP)) + geom_smooth(method = "glm", family = "binomial") +
  facet_wrap(stratumP~ year, ncol = 6)

# Fit a logistic moodel to hazard Shocks
hzd1.1 <- glm(hazardShk ~ femhead + agehead + marriedHohp + hhsize + gendMix + mixedEth +
                under5 + youth15to24 + depRatio + mlabor + flabor  +
                literateHoh + literateSpouse + educHoh +
                landless + agwealth + wealth + infraindex + hhmignet + factor(month) +
                factor(stratumP), 
                data = vul1, family = binomial(link = "logit"))

hzd2.1 <- glm(hazardShk ~ femhead + agehead + marriedHohp + hhsize + gendMix + mixedEth +
                under5 + youth15to24 + depRatio + mlabor + flabor  +
                literateHoh + literateSpouse + educHoh +
                landless + agwealth + wealth + infraindex + hhmignet + factor(month) +
                factor(stratumP), 
              data = vul2, family = binomial(link = "logit"))

# # Robust standard-errore
# # cov.m1 <- vcovHC(hzd1.1, type="HC0")
# # std.err <- sqrt(diag(cov.m1))
# # r.est <- cbind(Estimate= coef(hzd1.1), "Robust SE" = std.err,
#                "Pr(>|z|)" = 2 * pnorm(abs(coef(hzd1.1)/std.err), lower.tail=FALSE),
#                LL = coef(hzd1.1) - 1.96 * std.err,
#                UL = coef(hzd1.1) + 1.96 * std.err)


# http://www.ats.ucla.edu/stat/r/dae/logit.htm

# Check results
summary(hzd1.1)

# Plot graphics
multiplot(hzd1.1, hzd2.1)



