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

test.segment, 
timestamp,"time.zero" "mins.zero"  
"pulse1"        "pulse2"  "pulse.smooth"  "GPM.smooth"   "AV"    
TC1           TC2           TC3           TC4           TC5          TC6 
"TC1_gal"       "TC2_gal"     "TC3_gal"       "TC4_gal"       "TC5_gal"       "TC6_gal"
"TC1_AVPV" "TC2_AVPV" "TC3_AVPV"      "TC4_AVPV"      "TC5_AVPV"      "TC6_AVPV"

[1] "test.segment"  "timestamp"     "record"        "pulse1"        "pulse2"       
[6] "TC1"           "TC2"           "TC3"           "TC4"           "TC5"          
[11] "TC6"           "TairNear"      "TairFar"       "TestFlag"      "nominal"      
[16] "nominal.GPM"   "test.type"     "pipe.matl"     "insul.level"   "cold.warm"    
[21] "pipe.nom.diam" "test.num"      "other.comment" "TC1_gal"       "TC2_gal"      
[26] "TC3_gal"       "TC4_gal"       "TC5_gal"       "TC6_gal"       "time.zero"    
[31] "mins.zero"     "Tair.ave"      "Tpipe.start"   "ave.GPM"       "pulse.ave"    
[36] "pulse.smooth"  "GPM.smooth"    "time.step"     "AV"            "TC1_AVPV"     
[41] "TC2_AVPV"      "TC3_AVPV"      "TC4_AVPV"      "TC5_AVPV"      "TC6_AVPV"     
[46] "nrec"          "TC1_1min"      "TC2_1min"      "TC3_1min"      "TC4_1min"     
[51] "TC5_1min"      "TC6_1min"      "TC1_1mindelta" "TC2_1mindelta" "TC3_1mindelta"
[56] "TC4_1mindelta" "TC5_1mindelta" "TC6_1mindelta" "TC2_flag.end"  "TC2_T.end"    
[61] "fDeltaT"       "TC3_flag.end"  "TC3_T.end"     "TC4_flag.end"  "TC4_T.end"    
[66] "TC5_flag.end"  "TC5_T.end"     "TC6_flag.end"  "TC6_T.end"     "ts.label"     
[71] "f_ts.label"   



