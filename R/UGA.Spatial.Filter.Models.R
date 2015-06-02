# Purpose: Run satial logistic regressions on shock variables
# Author: Tim Essam, PhD (USAID GeoCenter)
# Date: 2015/05/05
# packages: RColorBrewer, spdep, classInt, foreign, MASS, maptools, ggplot2


# Clear the workspace
remove(list = ls())

req_lib <- c("RColorBrewer", "spdep", "classInt", "foreign", "MASS", "maptools", "ggplot2", "dplyr")
lapply(req_lib, library, character.only = TRUE)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdw)


data  <- read.csv("UGA_201505_GWRcut.csv", header = TRUE, sep = ",")
names(data)

data$educHoh <- as.numeric((data$educHoh))
utils::View(data)

d2009 <- filter(data, year == 2009)
d2010 <- filter(data, year == 2010)
d2011 <- filter(data, year == 2011)

x <- d2009$longitude
y <- d2009$latitude
xy <- as.matrix(d2009[4:5])
distThresh <- dnearneigh(xy, 0, 100, longlat = TRUE)

## this sets up a distance threshold of a weights matrix within 100 km.
weights <- nb2listw(distThresh, style = "W")

# Make set of dummy variables from month of interview, remove july to make it the base
month <-dummy(d2009$monthInt)
month <- as.data.frame(month)
month <- dplyr::select(month, -(monthInt7))
d2009 <- cbind.data.frame(d2009, month)

# Define exogenous paramenters for the model
exog <- dplyr::select(d2009, femhead, agehead, ageheadsq, marriedHohp, hhsize, gendMix, under15,
               youth15to24, depRatio, mlabor, flabor, mixedEth, hhmignet, literateHoh, 
               literateSpouse, educHoh, agwealth, landless, infraindex, monthInt1, monthInt2, 
               monthInt3, monthInt4, monthInt5, monthInt6, monthInt8, monthInt9, 
               monthInt10, monthInt11, monthInt12)
exog <- as.matrix(exog)

depvar <- d2009$healthShk

# Run the SAR error model 
## This applies a spatial error model.  The catch is that this essentially treats it as a linear regression, 
## ignoring any complexity from the fact that foodshk is really a binary variable.
sar <- errorsarlm(depvar ~ exog, listw = weights)
summary(sar)


#Create spatial filter by calculating eigenvectors.
weightsB <- nb2listw(distThresh, style = "B")

## We need a non-row-standardized set of weights here, so style = "B"
n <- length(distThresh)
M <- diag(n) - matrix(1,n,n)/n
B <- listw2mat(weightsB)
MBM <- M %*% B %*% M
eig <- eigen(MBM, symmetric=T)
EV <- as.data.frame( eig$vectors[ ,eig$values/eig$values[1] > 0.25])
colnames(EV) <- paste("EV", 1:NCOL(EV), sep="")

## run a logistic regression (GLM with family=binomial)
full.glm <- glm(depvar ~ exog + ., data=EV, family=binomial)
summary(full.glm)

## Several of the eigenvectors are significant, although only femhead and agehead have  
## significant relationships from the original variables.
sf.glm <- stepAIC(glm(depvar ~ exog , data=EV, family=binomial), scope=list(upper=full.glm), direction="forward")
summary(sf.glm)
multiplot(full.glm, sf.glm)

sf.glm.res <- round(residuals(sf.glm, type="response"))
moran.test(sf.glm.res, weights)