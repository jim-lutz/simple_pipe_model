# export_data.5.R
# script to export data behind fDeltaT & AVPV charts 
# Jim Lutz "Mon Jun  4 10:50:26 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
source("functions.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
names(DT_test_info)
View(DT_test_info)

# DT_test_info data to export
fname, title, matl, nom.diam, R.value, ODin, IDin, gal_pls, ft_gal,
TC1_gal, TC2_gal, TC3_gal, TC4_gal, TC5_gal, TC6_gal, 
TC13_gal, TC14_gal, TC22_gal, TC23_gal,
TC1_ft, TC2_ft, TC3_ft, TC4_ft, TC5_ft, TC6_ft
TC13_ft, TC14_ft, TC22_ft, TC23_ft 


# set up ./data/5/ directory
dir.create(paste0(wd_data,"5/"))

# current working directories
wd_data_in    = paste0(wd_data, "4/")
wd_data_out   = paste0(wd_data, "5/")

