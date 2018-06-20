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
# u (vel) is the mean velocity of the fluid (ft/s)
# D is the inside diameter of the pipe (ft)
# ν (visck) is the kinematic viscosity of the fluid (ft^2/s)

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
  
  # make a local version of the data.table
  DT <- copy(.DT)
  
  # add Kelvin temperature to DT
  DT[ , T.K := (T-32)/1.8 + 273.15]
  
  # add pressure, constant at 1 bar 
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

# confirm kinematic viscosity function
ggplot(data=DT_water, 
       aes(x=nu.ft_2_s, y= visck, color=as.factor(Pnom)) )+
  geom_line() 

# r-squared
nu.lm = lm(visck ~ nu.ft_2_s, data=DT_water) 
nu.lm
summary.lm(nu.lm)
# seems to work

# current working directories
wd_data_in    = paste0(wd_data, "5/")

# get the ./data/5/*Data2.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "Data2.Rdata")

f = l_Rdata[2]   # 34PEXR47RawData2.Rdata

# load a data.table DT_data.5
load(file = paste0(wd_data_in,f) )

# look at DT_data.5  
DT_data.5
str(DT_data.5)
names(DT_data.5)

# look at the number of records by test.segment
DT_data.5[ , list(nrec=length(record)), by=test.segment]

# for testing use the first 20 records from test.segment==1
# only some of the fields
DT_test2 <- 
  DT_data.5[test.segment==1,
            list(test.segment,
                 timestamp,
                 record,
                 TC1,
                 GPM.smooth)
            ][1:20]

# bare filename w/o extension
bfname = str_remove(f,".Rdata")

# build the .xlsx filename
xlsx.fname <- str_replace(f,".Rdata",".xlsx")

# get ID from DT_test_info, (ft)
ID <- as.numeric(DT_test_info[fname==xlsx.fname,IDin])/12

# get ft_gal from DT_test_info
ft_gal <- as.numeric(DT_test_info[fname==xlsx.fname,ft_gal])

# add velocity, (ft/sec)
DT_test2[ , vel := ft_gal * GPM.smooth / 60]

# add kinematic viscosity (ft^2/sec)
DT_test2[ , T:=TC1]
DT_test2 <- kinematic.viscosity(DT_test2); DT_test2
DT_test2[ , T:=NULL]

# add Reynolds number
# Re = vel * ID / visck
DT_test2[ , TC1.Re := vel * ID / visck]




