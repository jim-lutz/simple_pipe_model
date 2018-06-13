# check_viscosity.R
# script to compare (dynamic) viscosity from CHNOSZ with
# viscosity from miniREFPROP.exe
# also check if need to worry about impact of pressure on viscosity
# Jim Lutz "Wed Jun 13 10:41:09 2018"

# set packages & etc
source("setup.R")

# work with CHNOSZ
# http://chnosz.net//
if(!require(CHNOSZ)){install.packages("CHNOSZ")}
library(CHNOSZ)

# water
# Dynamic viscosity (g cm^-1 s^-1)
water.SUPCRT92(property='visc', T = 298.15, P = 1)
#          visc
# 1 0.008904924

# density (kg m^3)
water.SUPCRT92(property='rho', T = 298.15, P = 1)
#        rho
# 1 997.0614

# Reynolds number
# Re = ρ * u * D / μ
# ρ is the density of the fluid (kg/m3)
# u is the mean velocity of the fluid (m/s)
# D is the inside diameter of the pipe (m)
# μ is the dynamic viscosity of the fluid (Pa·s = N·s/m2 = kg/(m·s))




# set up paths to working directories
source("setup_wd.R")

# read water_from_miniREFPROP.csv
# need to put names, units, etc before data and data names
DT_miniREFPROP <- 
  fread(file = paste0(wd_data, "water_from_miniREFPROP.csv"),
        skip = 2,
      verbose = TRUE)

# see what came through
str(DT_miniREFPROP)
