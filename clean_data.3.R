# clean_data.3.R
# script to identify Carl's test segments in ./data/3/*.Rdata files
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
  
  # make sure it's POSIXct and right time zone
  attributes(DT_data.3[,timestamp]) 
  # $class
  # [1] "POSIXct" "POSIXt" 
  # 
  # $tzone
  # [1] "America/Los_Angeles"
  
  # timestamps match those in spreadsheet
  DT_data.3[, list(start = min(timestamp),
                   end   = max(timestamp))]
  #                  start                 end
  # 1: 2009-11-13 02:51:13 2009-12-06 06:31:32
  
  # see if START and ENDs match
  DT_data.3[TestFlag=="START" | TestFlag=="END",  list(timestamp,TestFlag)]
  # appear to
  
  # count START and ENDs
  DT_data.3[TestFlag=="START" | TestFlag=="END",  list(timestamp,TestFlag), 
            by=TestFlag][ ,list(n=length(timestamp)), by=TestFlag]
  #    TestFlag  n
  # 1:    START 60
  # 2:      END 59
  # not quite
  
  # TestFlag and timestamp only
  DT_TFt <- DT_data.3[TestFlag=="START" | TestFlag=="END", list(TestFlag,timestamp)]

  # add a variable identifying testnum
  DT_TFt[,testnum := cumsum(TestFlag=="START")]
  
  # now cast
  DT_test <- dcast(DT_TFt, testnum ~ TestFlag, value.var = "timestamp")

  # reset the column order
  setcolorder(DT_test, c("testnum","START","END"))
  
  # look at it
  DT_test
  
  # see which STARTs are after the ENDs
  DT_test[END<START,]
  # none
  DT_test[is.na(END)|is.na(START),]
  #    testnum               START  END
  # 1:      10 2009-11-13 08:38:11 <NA>
  
  #looking at spreadsheet should probably be at
  #       timestamp record
  # 11/13/2009 8:52	808382
  
  # collect comments 5 records before and after START and END
  # build lead & lag columns
  DT_lag_comments <- DT_data.3[,shift(TestFlag,n = 5:1, type = "lag", give.names = TRUE)]
  DT_lead_comments <- DT_data.3[,shift(TestFlag,n = 1:5, type = "lead", give.names = TRUE)]
 
  # combine the lead & lag columns into DT_data.3 
  DT_comments <- data.table(DT_data.3,DT_lag_comments,DT_lead_comments)
  
  # list of lead/lag_comment column names
  lead_lag_cols <- grep("TestFlag_", names(DT_comments), value = TRUE)
  
  # build comment
  DT_comments[, comment:= do.call(paste, c(DT_comments[,lead_lag_cols,with=FALSE]))]
  
  # remove the lead_lag_cols
  set(DT_comments, j=lead_lag_cols, value = NULL)
  
  # keep comment only if there's something in TestFlag
  DT_comments[is.na(TestFlag), comment := NA ]
  
  # remove "NA" from comment
  DT_comments[,comment:= str_remove_all(comment,"NA")]
  DT_comments[,comment:= str_trim(comment,"both")]
  
