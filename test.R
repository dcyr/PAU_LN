####################################################################################################
#####################################################################################################
###### Preparation of regeneration module
##### Dominic Cyr, in collaboration with Jesus Pascual Puigdevall
rm(list = ls())
home <- path.expand("~")
home <- gsub("/Documents", "", home) # necessary on my Windows machine
setwd(paste(home, "Sync/Travail/ECCC/Mathilde_test", sep ="/"))
###################################################################################################
###################################################################################################
wwd <- paste(getwd(), Sys.Date(), sep = "/")
dir.create(wwd)
setwd(wwd)
#################
require(tidyverse)
require(qmap)
#######

source("../scripts/regenDensityPredictFnc.R")
psDir <- "../data/Pothier-Savard"
source(paste(psDir, "Pothier-Savard.R", sep = "/"))



### input file
df <- read.csv("../input.csv")
### predicting seedling density in case of a fire
df[,"seedlings"] <- seedlingFnc(sp = df$coverType,
                                Ac = df$Ac, G = df$G, iqs = df$iqs,
                                seedCoef = seedCoef, tCoef = tCoef)


################################################################################
#### fitting quantile mapping model,
##### see Maraun, D. (2016). Bias Correcting Climate Change Simulations - a Critical Review. Current Climate Change Reports, 2(4), 211-220. https://doi.org/10.1007/s40641-016-0050-x
#####################
#### Among other things, assumes that the current landscape is at equilibrium with regard to its regeneration potential,
#### i.e. that the resulting distribution of seedling density is in equilibrium with the distribution of IDR100

seedlingQMapFit <- fitQmapQUANT(obs = df$IDR100, mod = df$seedlings,  nboot = 1,
                                qstep = 0.01, wet.day = F)

save(seedlingQMapFit, file = "seedlingQMapFit.RData") ### can be stored as is and used in another script to predict IDR from seedling density

### to load again
# seedlingQMapFit <- get(load("seedlingQMapFit.RData"))



### example, using a vector of seedling density ranging from 0 to max value
seedlingDens <- seq(from = 0, to = max(df$seedlings, na.rm = T), length.out = 100)

## Predicting IDR100 from seedling density
output_IDR100 <- doQmapQUANT(x = seedlingDens,
                                 fobj = seedlingQMapFit, type = "linear")



plot(x = seedlingDens,
     y = output_IDR100,
     type = "l")


