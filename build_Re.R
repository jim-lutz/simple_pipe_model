# build_Re.R
# script to build function to calculate Reynolds number
# Jim Lutz "Mon Jun 18 14:27:50 2018"

# set packages & etc
source("setup.R")

# work with CHNOSZ
# http://chnosz.net//
if(!require(CHNOSZ)){install.packages("CHNOSZ")}
library(CHNOSZ)

