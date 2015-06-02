
# --- Clear workspace, set library list
remove(list = ls())

library(GWmodel)
library(dplyr)
library(useful)
library(coefplot)
library(gstat)
library(sp)
library(nlme)
library(RColorBrewer)
library(ape) # -- for Global Moran's I

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

# Loac data as a spatial points data frame, setting lat/lon in process
d2009.spdf <- SpatialPointsDataFrame(d2009[, 4:5], d2009)
DM <- gw.dist(dp.locat = coordinates(d2009.spdf), longlat = TRUE)

# Set up the covariates to be used
# --- Summary statistics using spatial correlations (using 15% of data as adapative kernel)

# --- These take some time to run, so run with care ---#
gw.ss.bx  <- gwss(d2009.spdf, vars = c("hazardShk", "femhead", "hhsize"), 
                  kernel = "boxcar", adaptive = TRUE, bw = 275, quantile = TRUE)

gw.ss.bs  <- gwss(d2009.spdf, vars = c("hazardShk", "femhead", "hhsize", "literateSpouse"),  
                  kernel = "bisquare", adaptive = TRUE, bw = 275, quantile = TRUE)

# Create a map of results for correlations
map.na = list("SpatialPointsDataFrame", scale = 100, col = 1)
map.scale.1 = list("SpatialPointsDataFrame", layout.scale.bar())
map.layout <- list(map.na, map.scale.1)
mypal1 <- brewer.pal(8, "Reds")

X11(width = 10, height = 12)
spplot(gw.ss.bx$SDF, "hazardShk_IQR", col.regions = mypal1, cuts = 7,
       main = "GW standard deviations for 2009 Hazard Shocks")


# Fit different models and compare results
hazardLM <- lm(hazardShk ~ femhead + agehead + ageheadsq + marriedHohp + gendMix + mixedEth + hhsize + under15 + youth15to24 + depRatio + mlabor + flabor + literateHoh + literateSpouse + educHoh + landless + agwealth + wealthindex_rur + infraindex + hhmignet + stratumP, data = d2009)
summary(hazardLM)
coefplot(hazardLM)

# Global model estimated using logistic binomial 
hazardGLM <- glm(hazardShk ~ femhead + agehead + ageheadsq + marriedHohp + gendMix + 
                   mixedEth + hhsize + under15 + youth15to24 + depRatio + mlabor + 
                   flabor + literateHoh + literateSpouse + educHoh + landless + 
                   agwealth + wealthindex_rur + infraindex + hhmignet + stratumP, data = d2009, 
                 family = binomial(link = "logit"))
summary(hazardGLM)
coefplot(hazardGLM)

# Plot the reults side-by-side
multiplot(hazardLM, hazardGLM)

# Test the residuals for spatial dependence
res.glm <-as.data.frame(cbind(d2009$latitude, d2009$longitude, resids=resid(hazardGLM), d2009$stratumP))
names(res.glm) <- c("lat", "lon", "resid", "region")

# plot residuals from GLM
ggplot(res.glm, aes(y = lat, x = lon, size = resid)) +
  geom_jitter(alpha = 0.25, position = position_jitter(height=0.1))

# --- Test for spatial autocorrelation in residuals
# Generate inverse distance weights
res.dist <- as.matrix(dist(cbind(res.glm$lon, res.glm$lat)))
res.dist.inv <- 1/res.dist 
diag(res.dist.inv) <- 0
res.dist.inv[is.infinite(res.dist.inv)] <- 0 # Seems like there are some infinite values in matrix


# Now test for spatial autocorrelation in residuals
Moran.I(res.glm$resid, res.dist.inv)


# Fit sequential models to find best set of variables to test
depvar <- "hazardShk"
indepvars <- c("femhead", "agehead", "ageheadsq", "marriedHohp", "gendMix", "mixedEth", 
               "hhsize", "under15", "youth15to24", "depRatio", "mlabor", "flabor", "literateHoh", 
               "literateSpouse", "educHoh", "landless", "agwealth", "wealthindex_rur", 
               "infraindex", "hhmignet")

# Determine optimal AIC and variable combination using model selection function
mod.sel <- model.selection.gwr(depvar, indepvars, data = d2009.spdf, kernel = "bisquare",
                               adaptive = TRUE, bw = 275)
sorted.mods <- model.sort.gwr(mod.sel, numVars= length(indepvars), 
                              ruler.vector = mod.sel[[2]][,2])
model.list <- sorted.mods[[1]]

# View results
X11(width = 10, height = 12)
model.view.gwr(depvar, indepvars, model.list = model.list)
plot(sorted.mods[[2]][,2], col = "black", pch = 20, lty = 5, 
     main = "GWR model selection procedure", ylab = "AICc", xlab = "Model No.", type = "b")

# Run selection of optimal bandwidth
bw.gwr.1 <- bw.gwr(hazardShk~hhsize+infraindex+landless+hhmignet+gendMix+mixedEth+literateSpouse+femhead+youth15to24+depRatio+educHoh+ageheadsq+agehead+mlabor+flabor+marriedHohp+under15+wealthindex_rur+agwealth, data = d2009.spdf, approach = "AICc", kernel = "bisquare", adaptive = TRUE)

# 531 is the lucky number

# Run GWR using robust 
gwr.res <- gwr.robust( hazardShk~hhsize+infraindex+landless+hhmignet+gendMix+mixedEth+literateSpouse+femhead+youth15to24+depRatio+educHoh+ageheadsq+agehead+mlabor+flabor+marriedHohp+under15+wealthindex_rur+agwealth, data = d2009.spdf, bw = bw.gwr.1, kernel = "bisquare", 
                       adaptive = TRUE, F123.test = TRUE)

# Run binomial model
gwr.res.binom <- gwr.generalised( hazardShk~hhsize+infraindex+landless+hhmignet+gendMix+mixedEth+literateSpouse+
                                    femhead+youth15to24+depRatio+educHoh+ageheadsq+agehead+mlabor+flabor+
                                    marriedHohp+under15+wealthindex_rur+agwealth, 
                                  data = d2009.spdf, bw = bw.gwr.1, family = "binomial", kernel = "bisquare", 
                                  adaptive = TRUE, dMat = DM, cv = TRUE)

print(gwr.res.binom)
print(gwr.res.binom$GW.arguments)

# Print the results
X11(width = 10, height = 12)
spplot(gwr.res.binom$SDF, "femhead", key.space = "right", 
        main = "Robust GWR estimates for Female Headed Households")

write.csv( res.binom.df, "gwr.binom.hazardShk.csv")

# Check for collinearity
gwr.collin.diagno(hazardShk~hhsize+infraindex+landless+hhmignet+gendMix+mixedEth+literateSpouse+femhead+
                    youth15to24+depRatio+educHoh+ageheadsq+agehead+mlabor+flabor+marriedHohp+
                    under15+wealthindex_rur+agwealth, data = d2009.spdf, bw = bw.gwr.1, kernel = "bisquare", 
                  adaptive = TRUE, DM)


