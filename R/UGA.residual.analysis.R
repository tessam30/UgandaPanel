# ADD REQUIRED PACKAGES
require(sp)
require(spdep)
require(car)
require(MASS)
library(rgdal)
library(geoR)
library(dplyr)

# --- Set working directory for home or away
wd <- c("U:/UgandaPanel/Export/")
wdw <- c("C:/Users/Tim/Documents/UgandaPanel/Export")
wdh <- c("C:/Users/t/Documents/UgandaPanel/Export")
setwd(wdw)

data  <- read.csv("UGA_201505_GWRcut.csv", header = TRUE, sep = ",")
names(data)

data$educHoh <- as.numeric((data$educHoh))
data$monthInt <- as.factor(data$monthInt)

# Set July as the base month
data$monthInt <- factor(data$monthInt, levels = c("7", "1", "2", "3", "4", "5", "6", "8", "9", "10", "11", "12"))

# Filter to 2009 data
d2009 <- filter(data, year == 2009)

# Subset data and ever so slightly jitter data to calculated nearest neighbors
gps <- subset(d2009, select = c(latitude, longitude))
jitgps <- jitter2d(gps, max=0.001)
jitgps <- rename(jitgps, lat = latitude, lon = longitude)

d2009$lat <- jitgps$lat
d2009$lon <- jitgps$lon

# Test for global autocorrelation in the dependent variable
# -- Create sp object from lat, lon coords in data

# filter d2009 to remove nas for FCS (only needed if looking at FCS)
#d2009 <- filter(d2009, FCS != "NA")

# Fit a GLM on hazard shocks
hazardGLM <- glm(hazardShk ~ femhead + agehead + ageheadsq + marriedHohp + gendMix + 
                   mixedEth + hhsize +  youth15to24 + depRatio + mlabor + 
                   flabor + literateHoh + literateSpouse + educHoh + landless + 
                   agwealth + wealthindex_rur + infraindex + hhmignet + stratumP + monthInt, data = d2009, 
                 family = binomial(link = "logit"))
summary(hazardGLM)

# Report odds-ratios from results
exp(coef(hazardGLM))
coefplot(hazardGLM)

# Check model against constant only model
with(hazardGLM, null.deviance - deviance)
with(hazardGLM, df.null - df.residual)
with(hazardGLM, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))
-





# Define a data projection for Uganda using spatialreference.org and 
# searching UTM 36 N zone - - giving epsg = 32635
coordinates(d2009) <- ~lon +lat
proj4string(d2009) <- CRS("+init=epsg:32635")
plot(d2009, pch = 20, col = "steelblue")

# Create a neighbors matrix
nm <- knn2nb(knearneigh(d2009))
all.linked <- max(unlist(nbdists(nm, d2009)))
nb <- dnearneigh(d2009, 0, all.linked)
colW <- nb2listw(nb, style = "W")

# PERMUTATION TEST FOR MORAN'S-I -- Final value of the Iperm$res vector is the observed statistic
set.seed(6022015) # for reproducibility set seed.

# Wrap permutation up in a function to easily use on any dependent variable of consideration
# x = string indicating variable of interest
# n = number of permutations to run
spat.corr.test <- function(x, n) 
  {n = n
    perm.test <- moran.mc(d2009@data[,x], listw=colW, nsim=n, alternative="greater")
    mean(perm.test$res[1:n])
    var(perm.test$res[1:n])
    plot(perm.test)
    perm.test$res[n+1]
  }

# Call function for various arguments
spat.corr.test("FCS", 999)
