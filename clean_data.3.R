# clean_data.3.R
# script to identify Carl's test segments in ./data/3/*.Rdata files
# saves data.tables as ./data/4/*.Rdata
# Jim Lutz "Tue Apr 10 05:52:59 2018"

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
  
  # bare filename w/o extension
  bfname = str_remove(f,".Rdata")
  
  # load a data.table DT_data.3
  load(file = paste0(wd_data_in,f) )
  
  # look at DT_data.3  
  DT_data.3

  # clean up TestFlag entries by bfname

  # build file name to source
  FNFR.fname <- paste0(wd,"/",bfname,".findNfixTF.R")
  
  # source the file
  source(file = FNFR.fname )
    
  # tests on data
  # =============
    
  # report if there are any duplicate timestamps
  if( anyDuplicated(DT_data.3[,timestamp]) ) { 
    cat("duplicate timestamps in ", f,"\n") 
    }

  # check attributes to :
  # make sure it's POSIXct 
  atimestamp <- attributes(DT_data.3[,timestamp]) 
  if(atimestamp$class[1] != "POSIXct") {
    cat("a timestamp in ", f," is not POSIXct","\n") 
  }
  # make sure it's the right time zone
  if(atimestamp$tzone!="America/Los_Angeles") {
    cat("a time zone in ", f," is not America/Los_Angeles","\n") 
  }
  
  # do start and end timestamps match those in DT_test_info spreadsheet
  timestamp.data <- 
    DT_data.3[, list(start = min(timestamp),end = max(timestamp))]

  timestamp.info <- # need to force these times to America/Los_Angeles
    DT_test_info[fname==paste0(bfname, ".xlsx"), 
                 list(start = force_tz(start.ct, tzone = "America/Los_Angeles"), 
                      end = force_tz(end.ct, tzone = "America/Los_Angeles")
                 )]
  if( !identical(timestamp.data$start,timestamp.info$start) ) {
    cat("start and end times in ", f, " and DT_test_info do not match","\n") 
  }
  
  # get the START and END TestFlags 
  DT_SE_TestFlags <-
    DT_data.3[TestFlag=="START" | TestFlag=="END",  list(timestamp,TestFlag), 
              by=TestFlag][ ,list(n=length(timestamp)), by=TestFlag]
  
  # report if the number of START and END TestFlags don't match
  if(DT_SE_TestFlags[TestFlag=="START",n]!=DT_SE_TestFlags[TestFlag=="END",n]) {
    cat("different number of STARTs and ENDs in ", f, "\n") 
    }
  
  # collect comments for 5 records before and after every START and END
  # build lead & lag columns
  DT_lag_comments <- DT_data.3[,shift(TestFlag,n = 5:1, type = "lag", give.names = TRUE)]
  DT_lead_comments <- DT_data.3[,shift(TestFlag,n = 1:5, type = "lead", give.names = TRUE)]
 
  # combine the lead & lag columns into DT_table 
  DT_comments <- data.table(DT_data.3,DT_lag_comments,DT_lead_comments)
  
  # list of lead/lag_comment column names
  lead_lag_cols <- c(
    grep("TestFlag_lag", names(DT_comments), value = TRUE),
    "TestFlag",
    grep("TestFlag_lead", names(DT_comments), value = TRUE)
  )
    
  # build comment
  DT_comments[, comment:= do.call(paste, c(DT_comments[,lead_lag_cols,with=FALSE]))]
  
  # remove the lag and lead columns
  set(DT_comments, j=grep("TestFlag_lag", names(DT_comments), value = TRUE), value = NULL)
  set(DT_comments, j=grep("TestFlag_lead", names(DT_comments), value = TRUE), value = NULL)
  
  # keep comment only if there's something in TestFlag
  DT_comments[is.na(TestFlag), comment := NA ]
  
  # remove "NA" from comment
  DT_comments[,comment:= str_remove_all(comment,"NA")]
  DT_comments[,comment:= str_trim(comment,"both")]
  
  # make other.comments column for comments that don't include START or END
  DT_comments[!is.na(comment) & !( str_detect(comment,"END") |
                                     str_detect(comment,"START") ) ,
              other.comment := comment]

  # remove comments that don't include START or END
  DT_other_comments <-
    DT_comments[!is.na(comment) & !( str_detect(comment,"END") |
                                       str_detect(comment,"START") ) ,
                comment := NA]

  # list the other comments
  DT_comments[, list(n=length(record)), by=other.comment]
  
  # list comments
  DT_comments[, list(n=length(record)), by=comment]
  
}  
  