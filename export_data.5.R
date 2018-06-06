# export_data.5.R
# script to export data behind fDeltaT & AVPV charts 
# Jim Lutz "Mon Jun  4 10:50:26 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
source("functions.R")

# current working directory
wd_data_5    = paste0(wd_data, "5/")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
names(DT_test_info)
# View(DT_test_info)

# DT_test_info data to export
fwrite(DT_test_info[,list(fname, title, matl, nom.diam, R.value, 
                          ODin, IDin, gal_pls, ft_gal,
                          TC1_gal, TC2_gal, TC3_gal, TC4_gal, TC5_gal, TC6_gal, 
                          TC13_gal, TC14_gal, TC22_gal, TC23_gal,
                          TC1_ft, TC2_ft, TC3_ft, TC4_ft, TC5_ft, TC6_ft,
                          TC13_ft, TC14_ft, TC22_ft, TC23_ft)
                    ],
       file = paste0(wd_data_5, "test_info.csv")
       )

# get all the ./data/5/*.Rdata files
l_Rdata <- list.files(path = wd_data_5, pattern = "*.Rdata")

# just one *.Rdata data.table
f = l_Rdata[3]   # 34PEXR47RawData2.Rdata

# bare filename w/o extension
bfname = str_remove(f,".Rdata")

# load in data.table DT_data.5
load(file = paste0(wd_data_5,f) )

# look at DT_data.5  
DT_data.5
str(DT_data.5)
names(DT_data.5)


# DT_data.5 AVPV & Tnorm data to export
fwrite(DT_data.5[,list(test.segment, ts.label, 
                       timestamp, time.zero, mins.zero,
                       pulse1, pulse2, pulse.smooth, GPM.smooth, AV,
                       TC1, TC2, TC3, TC4, TC5, TC6, 
                       TC1_gal, TC2_gal, TC3_gal,TC4_gal, TC5_gal, TC6_gal,
                       TC1_AVPV, TC2_AVPV, TC3_AVPV, TC4_AVPV, TC5_AVPV, TC6_AVPV,
                       TC2_T.end, TC3_T.end, TC4_T.end, TC5_T.end, TC6_T.end)
                    ],
       file = paste0(wd_data_5, bfname, ".AVPV_Tnorm.csv")
)



