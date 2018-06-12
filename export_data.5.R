# export_data.5.R
# script to create TCn_T.norm & TCn_dVol.norm charts 
# and export data behind them
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

# export DT_test_info data to test_info.csv
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
                       timestamp, mins.zero,
                       pulse1, pulse2, pulse.smooth, GPM.smooth, deliv.vol,
                       TC1, TC2, TC3, TC4, TC5, TC6, 
                       TC1_pipe.vol, TC2_pipe.vol, TC3_pipe.vol,TC4_pipe.vol, TC5_pipe.vol, TC6_pipe.vol,
                       TC1_dVol.norm, TC2_dVol.norm, TC3_dVol.norm, TC4_dVol.norm, TC5_dVol.norm, TC6_dVol.norm,
                       TC2_T.end, TC3_T.end, TC4_T.end, TC5_T.end, TC6_T.end,
                       TC2_T.norm, TC3_T.norm, TC4_T.norm, TC5_T.norm, TC6_T.norm)
                    ],
       file = paste0(wd_data_5, bfname, ".T.norm_dVol.norm.csv")
)


# zoomed in look at TCn_T.norm by TCn_dVol.norm for all the TCs 
# repeat with these test.segments
test.segments = c(35, 23, 13, 09, 11, 21, 33, 25, 
                  27, 07, 19, 22, 17, 29, 05, 03, 31)

for (ts in test.segments) {
  # for debugging only ts = 13
  
  # get the subtitle
  ts.subtitle = DT_data.5[test.segment==ts, 
                        list(ts.subtitle = unique(ts.label))
                        ]
  
  ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% ts]) +
  geom_path(aes(x=TC3_dVol.norm, y= TC3_T.norm),color='#CA9CA4') +
  geom_path(aes(x=TC4_dVol.norm, y= TC4_T.norm),color='#C2C2C2') +
  geom_path(aes(x=TC5_dVol.norm, y= TC5_T.norm),color='#A1A6C8') +
  geom_path(aes(x=TC6_dVol.norm, y= TC6_T.norm),color='#023FA5') +
  ggtitle( paste0('normalized temperature vs normalized delivered volume, 3/4in PEX insulated'),
           subtitle = ts.subtitle) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  scale_x_continuous(name = "normalized delivered volume" ,limits = c(0,5)) +
  scale_y_continuous(name = "normalized temperature" ,limits = c(-0.05,1.01)) 
  
  ggsave(filename = paste0(bfname,"_ts", ts, "_T.norm_dVol.norm.png"), path=wd_charts,
       width = 10, height = 10 )
  
}
  