# clean_data.2.R
# script to do clean up nominal from timestamp ./data/2/*.Rdata files
# also converts timestamp back to POSIXct
# saves data.tables as ./data/3/*.Rdata
# Jim Lutz "Thu Apr  5 17:19:21 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
View(DT_test_info)

# set up ./data/3/ directory
dir.create(paste0(wd_data,"3/"))

# get all the ./data/*.2.Rdata files
l_Rdata <- list.files(path = paste0(wd_data, "2/"), pattern = "*.Rdata")

# loop through all the files
for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  f = l_Rdata[3]
  
  # load a data.table DT_data.1
  load(file = paste0(wd_data, "2/",f) )
  
  # look at DT_data.2  
  DT_data.2

  # number of colums
  ncols <- ncol(DT_data.2)
  
  # rows without any data
  DT_data.2[rowSums(is.na(DT_data.2))==ncols,]
  # 114
  
  # get rid of rows without any data
  DT_data.2a <- DT_data.2[rowSums(is.na(DT_data.2))=ncols,]
  
  # find timestamp is NOMINAL or timestamp
  good.timestamp <-
  identical(DT_data.2a[grepl("NOMINAL", timestamp), timestamp],
            DT_data.2a[ !(grepl("^4[0-9]{4}", timestamp)),timestamp])
  # should be TRUE 
  # check for this and warn if it doesn't happen
  if(good.times != TRUE) { cat("timestamp has some problems in f") }

  # make a nominal column
  DT_data.2a[grepl("NOMINAL", timestamp), nominal:=timestamp]
  
  # duplicate nominal from row above if NA
  DT_data.2a[,segment := cumsum(!is.na(nominal))]
  DT_data.2a[,nominal := nominal[1], by = "segment"]
  DT_data.2a[,segment := NULL]

  # remove rows with NOMINAL in timestamp
  DT_data.2b <- DT_data.2a[!grepl("NOMINAL", timestamp),]
  
  # how many different nominal tests
  DT_data.2b[ , list(n=length(timestamp)), by="nominal"]

  # start of Excel (Windows) calendar, Excel is decimal days since
  starttime <- ymd("1900-01-01", tz="America/Los_Angeles")
  
  # timestamp into days & seconds
  DT_data.2b[, `:=` (days.int = as.integer(timestamp),
                     days.dec = as.numeric(timestamp))
             ]
  DT_data.2b[, seconds := (days.dec-days.int) * 24 * 60 * 60 ]
  
  # convert timestamp to POSIXct, 
  DT_data.2b[ , timestamp.a := starttime + days(days.int) + seconds(seconds)]
  
  str(DT_data.2b)
  

  
  

 