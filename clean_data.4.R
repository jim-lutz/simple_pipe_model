# clean_data.4.R
# script to select test segments to plot in ./data/4/*.Rdata files
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

# get all the ./data/*.4.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*.Rdata")

# loop through all the files
# for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  f = l_Rdata[1]   # 12PEXBareRawData2.Rdata
  
  # bare filename w/o extension
  bfname = str_remove(f,".Rdata")
  
  # build a 1 row data.table of distances in gallons along pipe to TCs
  DT_gal <- pipe_gal(fn.Rdata=f, DT=DT_test_info) 
  
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
                 u.cw      = unique(cold.warm)
            ), by=test.segment][order(unom.GPM,u.cw)]
  
  
  # get the TC variable names
  TCs <- grep("TC[0-9]+", names(DT_data.4[]), value = TRUE )
  
  # # list of variable names to keep
  # varnames <- c('test.segment', 'timestamp', 'record', TCs)
  # 

  # sort DT_data.4 by record
  setkey(DT_data.4, record)
  
  # add distance along pipe to DT_data.5 timestamp and temperatures
  DT_data.5 <- data.table( DT_data.4, DT_gal)
  
  # see if worked
  str(DT_data.5)
  
  # calculate time.zero from the start of each test.segment
  DT_data.5[!is.na(test.segment), time.zero := min(timestamp), by=test.segment]
  
  # minutes since time.zero
  DT_data.5[, mins.zero := as.numeric(difftime(timestamp, 
                                               time.zero, 
                                               units = "mins"))]

  # confirm time.zero & mins.zero
  DT_data.5[ , list(time.zero = unique(time.zero),
                    mins.zero = unique(mins.zero)),
             by=test.segment]

  # look at the first 3 in each test.segment  
  DT_data.5[
    DT_data.5[!is.na(test.segment),.(index=.I[1:3]), by=test.segment]$index, 
        # this give the row numbers of the first 3 rows by test.segment
    list(timestamp, time.zero, mins.zero), 
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
              .SDcols=TCs[3:length(TCs)]]
  
  # calc Tpipe.start
  DT_Tpipe.start[, Tpipe.start := rowMeans(.SD), 
                 .SDcols=TCs[3:length(TCs)]
                 ]
  
  # drop the TCs
  DT_Tpipe.start[, TCs[3:length(TCs)]:=NULL ]
  
  # merge Tpipe.start onto DT_data.5
  DT_data.5 <-  merge(DT_data.5,DT_Tpipe.start, by="test.segment", all.x = TRUE )
   
STOP 

  # look the max mins.zero (duration of test.segment) by test.segment
  plot(
    DT_data.5[!is.na(test.segment), list(max.min = max(mins.zero),
                                       nmin    = (length(record)-1)/60),
            by=test.segment][order(nmin)]$nmin
  )
  # if it's below 10 mins it's likely an incomplete test.

  # find last minute temp rise @ TC14
  # drop the NA test.segments and keep TC14, last thermal couple
  DT_test1 <- DT_data.4[!is.na(test.segment), 
                        list(TC14, nominal.GPM, nrec=length(record)), 
                        by=test.segment]
  
  # select the last 19 rows in each test.segment
  DT_test2 <- DT_test1[,.SD[(.N-19):.N],by=test.segment]
  
  # check if temperature range is > ?
  DT_test3 <-
    DT_test2[ , list( temp.rise = max(TC14)-min(TC14),
                      nom.GPM   = unique(nominal.GPM),
                      nrec      = unique(nrec)              
    ), 
    by=test.segment][order(temp.rise, nom.GPM)]
  
  # quick look at distribution of last 2 minute temperature rise
  plot(  DT_test3$temp.rise  )
  
  
  
  
  STOP  
  # source the findNfixTF.R file
  source(file = FNFTF.fname.R )
  
  # save DT_data.5 as .Rdata
  save(DT_data.5, file = paste0(wd_data_out, f))

  # plotting here?
  
    
  # remove data.tables before next spreadsheet
  rm(DT_data.4, DT_data.5)

# }  loop turned off
  