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
  TCs <- grep("TC[0-9]+", names(DT_data.4[]), value = TRUE )
  
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
        # this gives the row numbers of the first 3 rows by test.segment
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
  
  # add the average GPM
  DT_ave.GPM <-
  DT_data.4[!is.na(test.segment), 
            list(ave.GPM = (sum(pulse1)+sum(pulse2))*gal_pls/2 / # pulses to gallons
                   length(record)*60 # gallons to GPM)
            ), by=test.segment]
            
  # merge ave.GPM onto DT_data.5
  DT_data.5 <-  merge(DT_data.5,DT_ave.GPM, by="test.segment", all.x = TRUE )
  
  # add number of records by test.segment
  DT_data.5[!is.na(test.segment), nrec:=length(record), by=test.segment ]
  
  # add plot.OK = TRUE when nrec>500
  # DT_data.5[nrec>500, plot.OK:=TRUE, by=test.segment ]
  
  # see what that did
  DT_data.5[!is.na(test.segment),
            list(nrec    = unique(nrec),
                 nom.GPM = unique(nominal.GPM), 
                 c.w     = unique(cold.warm), 
                 Tstart  = unique(Tpipe.start) 
            ),
            by=test.segment][order(nom.GPM, Tstart)]

  # save DT_data.5 as .Rdata
  save(DT_data.5, file = paste0(wd_data_out, f))

  # plotting here?
  
    
  # remove data.tables before next spreadsheet
  rm(DT_data.4, DT_data.5)

# }  loop turned off
  