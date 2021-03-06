# clean_data.4.R
# script to add info for test segments in ./data/4/*.Rdata files
# saves data.tables as ./data/5/*.Rdata
# Jim Lutz "Wed May  2 06:00:05 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
source("functions.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
# View(DT_test_info)

# set up ./data/5/ directory
dir.create(paste0(wd_data,"5/"))

# current working directories
wd_data_in    = paste0(wd_data, "4/")
wd_data_out   = paste0(wd_data, "5/")

# get all the ./data/4/*.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*.Rdata")

# loop through all the files
# for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  # f = l_Rdata[1]   # 12PEXBareRawData2.Rdata
  f = l_Rdata[2]   # 34PEXR47RawData2.Rdata
  
  # bare filename w/o extension
  bfname = str_remove(f,".Rdata")
  
  # build a 1 row data.table of distances in gallons along pipe to TCs
  DT_gal <- pipe_gal(fn.Rdata=f, DT=DT_test_info) 
  
  # build the .xlsx filename
  xlsx.fname <- str_replace(f,".Rdata",".xlsx")
  
  # get gal_pls from DT_test_info
  gal_pls <- as.numeric(DT_test_info[fname==xlsx.fname,gal_pls])
  
  # load a data.table DT_data.4
  load(file = paste0(wd_data_in,f) )
  
  # look at DT_data.4  
  DT_data.4

  str(DT_data.4)
  
  # look at the test.segments
  DT_data.4[!is.na(test.segment), 
            list(start.rec = min(record),
                 start.time = min(timestamp),
                 nrec      = length(record),
                 utest.num = unique(test.num),
                 unom.GPM  = unique(nominal.GPM),
                 ave.GPM   = (sum(pulse1)+sum(pulse2))*gal_pls/2 / # pulses to gallons
                                length(record)*60, # gallons to GPM
                 u.cw      = unique(cold.warm)
            ), by=test.segment][order(unom.GPM,u.cw)]
  
  
  # get the TC variable names
  TC.names <- grep("TC[0-9]+", names(DT_data.4[]), value = TRUE )
  
  # sort DT_data.4 by record
  setkey(DT_data.4, record)
  
  # add distance along pipe to DT_data.5 timestamp and temperatures
  DT_data.5 <- data.table( DT_data.4, DT_gal)
  
  # see if worked
  str(DT_data.5)
  names(DT_data.5)
  
  # change TCn_gal to TCn_pipe.vol
  setnames(DT_data.5, 
           old = c('TC1_gal', 'TC2_gal', 'TC3_gal', 
                   'TC4_gal', 'TC5_gal', 'TC6_gal'),
           new = c('TC1_pipe.vol', 'TC2_pipe.vol', 'TC3_pipe.vol', 
                   'TC4_pipe.vol', 'TC5_pipe.vol', 'TC6_pipe.vol')
             )
  
  # calculate time.zero from the start of each test.segment
  DT_data.5[!is.na(test.segment), time.zero := min(timestamp), by=test.segment]
  
  # minutes since time.zero
  DT_data.5[, mins.zero := as.numeric(difftime(timestamp, 
                                               time.zero, 
                                               units = "mins"))]

  # look at time.zero & mins.zero
  DT_data.5[ , list(time.zero = unique(time.zero),
                    mins.zero = unique(mins.zero)),
             by=test.segment]

  # calc Tair.ave by test.segment
  DT_data.5[!is.na(test.segment), Tair.ave := (mean(TairNear)+mean(TairFar))/2,
            by=test.segment]
  
  # add Tpipe.start
  # get temperatures of TC3 and beyond at time.zero
  DT_Tpipe.start <-
    DT_data.5[!is.na(test.segment) & mins.zero==0,
              .SD,
              by=test.segment,
              .SDcols=TC.names[3:length(TC.names)]]
  
  # calc Tpipe.start
  DT_Tpipe.start[, Tpipe.start := rowMeans(.SD), 
                 .SDcols=TC.names[3:length(TC.names)]
                 ]
  
  # drop the TC.names from Tpipe.start
  DT_Tpipe.start[, TC.names[3:length(TC.names)]:=NULL ]
  
  # merge Tpipe.start onto DT_data.5
  DT_data.5 <-  merge(DT_data.5,DT_Tpipe.start, by="test.segment", all.x = TRUE )

    
  # calc average GPM
  DT_ave.GPM <-
  DT_data.4[!is.na(test.segment), 
            list(ave.GPM = (sum(pulse1)+sum(pulse2))*gal_pls/2 / # pulses to gallons
                   length(record)*60 # gallons to GPM)
            ), by=test.segment]
            
  # merge ave.GPM onto DT_data.5
  DT_data.5 <-  merge(DT_data.5,DT_ave.GPM, by="test.segment", all.x = TRUE )

  # remove unneeded data.tables
  rm(DT_ave.GPM, DT_gal, DT_Tpipe.start)
  
  # calc smoothed average pulses per second using lowess function with default settings
  # average pulses
  DT_data.5[, pulse.ave := (pulse1 + pulse2)/2]
  
  # look to see if it's working appropriately
  DT_data.5[, list(pulse1,pulse2,pulse.ave)]
  
  # lowess by test.segment
  DT_data.5[ , pulse.smooth := lowess(pulse.ave)$y, by=test.segment]

  # check to see if it's working appropriately
  DT_data.5[test.segment==1, list(pulse1,pulse2,pulse.ave, pulse.smooth)]
  # that looks good. it's $y of lowess that I'm after
  qplot(data=DT_data.5[test.segment==35], x=1:length(pulse.smooth), y=pulse.smooth)
  
  # look at smoothed pulses
  # ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36])+
  #   geom_step(aes(x=mins.zero, y= pulse.ave) ) +
  #   geom_path(aes(x=mins.zero, y= pulse.smooth), color="red" ) +
  #   ggtitle( paste0('smoothed pulses by test.segment in ', bfname) )+
  #   scale_x_continuous(name = "duration of draw (min)",limits = c(0,2))+
  #   scale_y_continuous(name = "smoothed flow (pulses)",limits = c(0,5)) +
  #   facet_wrap(~test.segment)
  # 
  # ggsave(filename = paste0(bfname,"smoothedpulses.png"), path=wd_charts,
  #        width = 19, height = 10 )
  
  # calc smoothed GPM
  DT_data.5[ , GPM.smooth := pulse.smooth * gal_pls * 60]
  
  # look at the GPM.smooth
  # ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36])+
  #   geom_path(aes(x=mins.zero, y= GPM.smooth, color=as.factor(test.segment)))+
  #   ggtitle( paste0('smoothed flow by test.segment in ', bfname) )+
  #   scale_x_continuous(name = "duration of draw (min)")+
  #   scale_y_continuous(name = "smoothed flow (GPM)",limits = c(0,5))
  
  # ggsave(filename = paste0(bfname,"smoothedflow.png"), path=wd_charts)
  
  # check assumption of 1 second per record
  DT_data.5[ !is.na(test.segment), 
             time.step := difftime(timestamp,
                                   shift(timestamp, n=1, type="lag"),
                                   units = "secs"),
             by=test.segment]
  qplot(1 - as.numeric(DT_data.5[!is.na(test.segment)]$time.step))
  summary(as.numeric(DT_data.5[!is.na(test.segment)]$time.step))
   # Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   #    1       1       1       1       1       1      36
  max(DT_data.5[!is.na(test.segment)]$time.step, na.rm = TRUE)
  # Time difference of 1.000001 secs
  min(DT_data.5[!is.na(test.segment)]$time.step, na.rm = TRUE)
  # Time difference of 0.999999 secs
  which.max(DT_data.5[!is.na(test.segment)]$time.step)
  # [1] 62
  DT_data.5[60:64, timestamp]
  
  mean(as.numeric(DT_data.5[!is.na(test.segment)&!is.na(time.step)]$time.step))
  # Time difference of 1 secs
  sd(DT_data.5[!is.na(test.segment)&!is.na(time.step)]$time.step)
  # [1] 4.040719e-07
  
  
  # calc actual delivered volume, cumulative sum of the GPM by test.segment
  DT_data.5[ , deliv.vol:=cumsum(GPM.smooth)/60, by=test.segment]
  
  # calc TCn_dVol.norm at each TC
  # list of TC_gal names, these are the names of the columns that contain TCn_pipe.vol
  TC_pipe.vol.names <- grep("TC[0-9]+_pipe.vol", names(DT_data.5), value = TRUE)
  
  # list of TCn_dVol.norm column names
  TC_dVol.norm.names <- str_replace(TC_pipe.vol.names, "_pipe.vol", "_dVol.norm")
  
  # calc TCn_dVol.norm by TC
  DT_data.5[ !is.na(test.segment), 
             (TC_dVol.norm.names) := deliv.vol/.SD,
             .SDcols = TC_pipe.vol.names,
             by=test.segment]
  
  names(DT_data.5)
  
  # see what TCn_dVol.norm looks like for TC6
  # ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36])+
  #   geom_path(aes(x=mins.zero, y= TC6_dVol.norm, color=as.factor(test.segment)))+
  #   ggtitle( paste0('TC6_dVol.norm by test.segment in ', bfname) )+
  #   scale_x_continuous(name = "duration of draw (min)")+
  #   scale_y_continuous(name = "actual volume to pipe volume")
  # seems OK
  
  # add number of records by test.segment
  DT_data.5[!is.na(test.segment), nrec:=length(record), by=test.segment ]

  # look at temperatures for TC6
  # ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36]) +
  #   geom_path(aes(x=mins.zero, y= TC6, color=as.factor(test.segment))) +
  #   ggtitle( paste0('TC6 by test.segment in ', bfname) ) +
  #   scale_x_continuous(name = "duration of draw (min)") +
  #   scale_y_continuous(name = "temperature" ) + # ,limits = c(125,140))
  #   facet_wrap(~test.segment)
  # 
  # ggsave(filename = paste0(bfname,"TC6_top.png"), path=wd_charts,
  #        width = 19, height = 10 )
  
    
  # calc normalized temperature

  # first the TCn_T.end
  # list of TCn_1min column names
  TC_1min.names <- paste0(TC.names, "_1min")
  
  # list of TCn_T.end column names
  TC_T.end.names <- paste0(TC.names, "_T.end")
  
  # find the TC temperature for one minute ago
  DT_data.5[ !is.na(test.segment), 
             (TC_1min.names) := shift(.SD, n=60, type="lag"),
             .SDcols = TC.names,
             by=test.segment]
  
  # look at temperatures for TC2 & TC2_1min
  # ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36]) +
  #   geom_path(aes(x=mins.zero, y= TC2, color=as.factor(test.segment))) +
  #   geom_path(aes(x=mins.zero, y= TC2_1min, color=as.factor(test.segment))) +
  #   ggtitle( paste0('TC2 & TC2_1min by test.segment in ', bfname) ) +
  #   scale_x_continuous(name = "duration of draw (min)") +
  #   scale_y_continuous(name = "temperature" ) + # ,limits = c(125,140))
  #   facet_wrap(~test.segment)
  # # this works except for test segments less than one minute long

  # find TCn_1mindelta
  # list of TCn_1mindelta column names
  TC_1mindelta.names <- paste0(TC.names, "_1mindelta")
  
  # calculate the TC delta Ts for one minute ago, this almost a derivative
  DT_data.5[ !is.na(test.segment), 
             (TC_1mindelta.names) := .SD - shift(.SD, n=60, type="lag"),
             .SDcols = TC.names,
             by=test.segment]
  
  # look at temperatures for TC2_1mindelta
  # ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36]) +
  #   geom_path(aes(x=mins.zero, y= TC2_1mindelta, color=as.factor(test.segment))) +
  #   ggtitle( paste0('TC2_1mindelta by test.segment in ', bfname) ) +
  #   scale_x_continuous(name = "duration of draw (min)") +
  #   scale_y_continuous(name = "delta temperature from 1 minute ago" ,limits = c(-5,5)) + #
  #   facet_wrap(~test.segment)
  # this works except for test segments less than one minute long
  
  # set an end flag when TCn_1mindelta < 0.5 deg F 
  # list of TCn_flag.end column names
  TC_flag.end.names <- paste0(TC.names, "_flag.end")
  
  # remove TC_flag.end.names columns, for use when debugging
  DT_data.5[, (TC_flag.end.names) := NULL]
  
  # loop through all the TC.names starting with TC2
  for(tc in 2:length(TC.names)) {
    
    # for debugging only tc=3
    
    # set end flag to logical
    # create commands to set TC_flag.end for each TC
    c_flag.end.false <- paste0("DT_data.5[", TC.names[tc], " > 100 & ", TC_1mindelta.names[tc]," >= 0.5, ",TC_flag.end.names[tc]," := FALSE]")
    c_flag.end.true  <- paste0("DT_data.5[", TC.names[tc], " > 100 & ", TC_1mindelta.names[tc]," <  0.5, ",TC_flag.end.names[tc]," := TRUE ]")
    
    # evaluate those commands
    eval(parse(text=c_flag.end.false))
    eval(parse(text=c_flag.end.true))
  
    # make DT_record.Tend, a data.table of the records when 
    # create command to find the record for the
    # first TC_flag.end is true by test.segment
    c_make.DT_record.Tend <-
      paste0(
        "DT_record.Tend <- ",
        "DT_data.5[ !is.na(test.segment) & ", 
        TC_flag.end.names[tc], "==TRUE, ",
        "list(",TC.names[tc],"_record.Tend = min(record)), ",
        "by=test.segment ] ")

    # evaluate the command
    eval(parse(text=c_make.DT_record.Tend))
    
    # calc TCn_T.end by test.segment
    # make DT_T.end, a data.table of the TC_T.end by test.segment
    # create command
    c_make.DT_T.end <-
      paste0(
        "DT_T.end<-",
        "DT_data.5[record %in% DT_record.Tend$",TC.names[tc],"_record.Tend ,",
                   "list(",TC.names[tc],"_T.end=",TC.names[tc],",",
                        " test.segment)",
                 "]"
        )
    
    # evaluate the command
    eval(parse(text=c_make.DT_T.end))
    

    # merge DT_T.end onto DT_data.5
    DT_data.5 <-
      merge(DT_data.5, DT_T.end, by="test.segment", all = TRUE)
    
    
    # calc TCn_T.norm
    # create command
    c_calc.TCn_T.norm <-
      paste0(
        "DT_data.5[!is.na(",TC.names[tc],"_T.end),",
                  TC.names[tc],"_T.norm := (",TC.names[tc],"-Tpipe.start)/(",
                   TC.names[tc],"_T.end-Tpipe.start)," ,
              " by=test.segment]")
    
    # evaluate the command
    eval(parse(text=c_calc.TCn_T.norm))

  } # end of TC loop

  names(DT_data.5)
  
  # see what's there
  DT_data.5[test.segment==35 & TC6 > 100,
            list(timestamp, TC6, TC6_1min, TC6_1mindelta, TC6_flag.end)][280:300]
  
  # make labels for test.segment facet charts
  DT_ts.labels <-
  DT_data.5[,list(nominal.GPM = unique(nominal.GPM),
                  ave.GPM     = unique(ave.GPM),
                  Tpipe.start = unique(Tpipe.start),
                  Tair.ave    = unique(Tair.ave)),
            by=test.segment]
  
  # make a label for charts by test.segment
  DT_ts.labels[!is.na(test.segment), 
               ts.label := sprintf(
                 fmt = "Test Segment %02i:\nGPM=%3.2f,Tstart=%3.1f,Tair=%3.1f",
                 test.segment, ave.GPM, Tpipe.start, Tair.ave),
               by=test.segment]
  
  # merge ts.label onto DT_data.5
  DT_data.5 <-
  merge(DT_data.5,DT_ts.labels[!is.na(test.segment)
                               ,list(test.segment,ts.label) ], 
        by.x = "test.segment", by.y = "test.segment", all = TRUE)

  names(DT_data.5)
  
  # get a list of the ts.labels in the right order
  levels.ts.label <-
  DT_data.5[!is.na(test.segment), 
            list(test.segment = unique(test.segment),
                 unom.GPM     = unique(nominal.GPM),
                 ave.GPM      = unique(ave.GPM),
                 u.cw         = unique(cold.warm),
                 Tpipe.start  = unique(Tpipe.start),
                 ts.label     = unique(ts.label)
                 ), 
            by=test.segment][order(unom.GPM,u.cw,ave.GPM)]$ts.label
  
  # make a factor for ts.label in the right order,
  DT_data.5[!is.na(test.segment),
            f_ts.label := factor(ts.label, levels=levels.ts.label)]

  # look at temperatures for all the TCs
  ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36]) +
    geom_path(aes(x=mins.zero, y= TC2), color='#8E063B') +
    geom_path(aes(x=mins.zero, y= TC3), color='#CA9CA4') +
    geom_path(aes(x=mins.zero, y= TC4), color='#C2C2C2') +
    geom_path(aes(x=mins.zero, y= TC5), color='#A1A6C8') +
    geom_path(aes(x=mins.zero, y= TC6), color='#023FA5') +
    ggtitle( paste0('TC temperatures by test.segment, 3/4in PEX insulated') ) +
    scale_x_continuous(name = "duration of draw (min)" ,limits = c(0,15) ) +
    scale_y_continuous(name = "temperature" ) + # ,limits = c(125,140))
    facet_wrap(~ f_ts.label)

  ggsave(filename = paste0(bfname,"TCtemps.png"), path=wd_charts,
         width = 19, height = 20 )
  
  
  
  
  # look at TCn_T.norm by TCn_dVol.norm for all the TCs and test.segments
  ggplot(data=DT_data.5[!is.na(test.segment) & test.segment %in% 1:36]) +
    geom_path(aes(x=TC3_dVol.norm, y= TC3_T.norm),color='#CA9CA4') +
    geom_path(aes(x=TC4_dVol.norm, y= TC4_T.norm),color='#C2C2C2') +
    geom_path(aes(x=TC5_dVol.norm, y= TC5_T.norm),color='#A1A6C8') +
    geom_path(aes(x=TC6_dVol.norm, y= TC6_T.norm),color='#023FA5') +
    ggtitle( paste0('normalized temperature vs normalized delivered volume by test.segment, 3/4in PEX insulated') ) +
    scale_x_continuous(name = "normalized delivered volume" ,limits = c(0,15)) +
    scale_y_continuous(name = "normalized temperature") + 
    facet_wrap(~f_ts.label)

  ggsave(filename = paste0(bfname,"T.norm_dVol.norm.png"), path=wd_charts,
         width = 19, height = 20 )

  
  names(DT_data.5)
  
  
  # save DT_data.5 as .Rdata
  save(DT_data.5, file = paste0(wd_data_out, f))


  # remove data.tables before next spreadsheet
  rm(DT_data.4, DT_data.5)

}  # loop turned off
  