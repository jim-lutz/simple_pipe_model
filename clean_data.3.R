# clean_data.3.R
# script to do clean up testflag in ./data/3/*.Rdata files
# saves data.tables as ./data/4/*.Rdata
# Jim Lutz "Tue Apr 10 05:52:59 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
# View(DT_test_info)

# set up ./data/4/ directory
dir.create(paste0(wd_data,"4/"))

# current working directories
wd_data_in    = paste0(wd_data, "3/")
wd_data_out   = paste0(wd_data, "4/")

# get all the ./data/*.3.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*.Rdata")

# loop through all the files
for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  #  f = l_Rdata[1]
  
  # load a data.table DT_data.3
  load(file = paste0(wd_data_in,f) )
  
  # look at DT_data.3  
  DT_data.3

  # look at TestFlag
  View(DT_data.3[!is.na(TestFlag), list(timestamp,TestFlag)])
  
  # see if there are any duplicate timestamps
  anyDuplicated(DT_data.3[,timestamp])
  # [1] 0
  
  # look at suspicious timestamp
  DT_data.3[ymd_hms("2009-11-13 02:51:20", tz = "America/Los_Angeles") < timestamp &
              timestamp < ymd_hms("2009-11-13 02:59:20", tz = "America/Los_Angeles"),
            list(timestamp, TestFlag)]
 
  attributes(DT_data.3[,timestamp]) 
  
  # timestamps match those in spreadsheet
  DT_data.3[, list(start = min(timestamp),
                   end   = max(timestamp))]
  #                  start                 end
  # 1: 2009-11-15 02:51:13 2009-12-08 06:31:31  
  
  
  DT_data.3[1:10,timestamp]
  