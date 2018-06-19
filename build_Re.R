# build_Re.R
# script to build function to calculate Reynolds number
# Jim Lutz "Mon Jun 18 14:27:50 2018"

# set packages & etc
source("setup.R")

# work with CHNOSZ
# http://chnosz.net//
if(!require(CHNOSZ)){install.packages("CHNOSZ")}
library(CHNOSZ)

# Reynolds number
# Re = u * D / ν
# u is the mean velocity of the fluid (ft/s)
# D is the inside diameter of the pipe (ft)
# ν is the kinematic viscosity of the fluid (ft^2/s)

# set up paths to working directories
source("setup_wd.R")

# load the viscosity data for check on viscosity calculation info
load(file = paste0(wd_data, "DT_Water.viscosity.Rdata"))

# look at DT_water
DT_water
names(DT_water)

kinematic.viscosity <- function(.DT){
  # function to add kinematic viscosity (visck) in ft^2/s of pure water
  # using CHNOSZ function water.SUPCRT92 to a data.table
  # .DT  = data.table containing T
  #  T  = temperature (deg F)
  
  DT <- copy(.DT)
  
  # add Kelvin temperature to DT
  DT[ , T.K := (T-32)/1.8 + 273.15]
  
  # add pressure 
  DT[ , P.bar := 1]
  
  # add kinematic viscosity (in stokes)
  DT[ , visck := water.SUPCRT92(property='visck', T=T.K, P=P.bar) ]
  
  # convert kinematic viscosity from stokes to ft^2/s
  DT[ , visck := visck * 10^-4 / 9.290304E-02 ]

  # remove pressure and temperature
  DT[ ,  c("T.K", "P.bar") := list(NULL, NULL)]
  
  # return the data.table
  return(DT)
  
}

# for testing
DT_testing <- data.table(T=40:50)
DT_testing <- kinematic.viscosity(DT_testing)

# look at DT_water
DT_water
names(DT_water)

DT_water <- kinematic.viscosity(DT_water)



# calculate kinematic viscosity (ft^2/s)
DT_water[ , nu.calc := kinematic.viscosity(.T = T.F)]

# confirm kinematic viscosity function
ggplot(data=DT_water, 
       aes(x=nu.ft_2_s, y= visck, color=as.factor(Pnom)) )+
  geom_line() 

# r-squared
nu.lm = lm(visck ~ nu.ft_2_s, data=DT_water) 
nu.lm
summary.lm(nu.lm)
# seems to work


