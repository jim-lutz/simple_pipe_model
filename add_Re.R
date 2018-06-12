# add_Re.R
# script to add Reynolds number to all the TCs in ./data/5/*.Rdata files
# saves data.tables as ./data/6/*.Rdata
# Jim Lutz "Tue Jun 12 13:56:03 2018"

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

# get some useful functions
source("functions.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# set up ./data/6/ directory
dir.create(paste0(wd_data,"6/"))

# current working directories
wd_data_in    = paste0(wd_data, "5/")
wd_data_out   = paste0(wd_data, "6/")

# get all the ./data/5/*.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*Data2.Rdata")

# loop through all the files
# for(f in l_Rdata) {

# this is for testing on just one *.Rdata data.table
# f = l_Rdata[1]   # 12PEXBareRawData2.Rdata
f = l_Rdata[2]   # 34PEXR47RawData2.Rdata

# bare filename w/o extension
bfname = str_remove(f,".Rdata")

