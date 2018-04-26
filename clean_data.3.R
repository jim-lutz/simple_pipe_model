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
# for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  f = l_Rdata[1]
  
  # bare filename w/o extension
  bfname = str_remove(f,".Rdata")
  
  # load a data.table DT_data.3
  load(file = paste0(wd_data_in,f) )
  
  # look at DT_data.3  
  DT_data.3

  # add empty columns to DT_data.3
  DT_data.3[, `:=` (nom.pipe.diam = as.character(),
                    pipe.matl     = as.character(),
                    insul.level   = as.character(),
                    cold.warm     = as.character(),
                    test.num      = as.character())
            ]
  
  # extract nom.pipe.diam, pipe.matl, insul.level from file name
  fnom.pipe.diam <- paste0(str_sub(bfname,1,1),'/',str_sub(bfname,2,2))
  fpipe.matl <- str_match(bfname, "[1-9]([a-zA-Z]+)(Ba|R[45])")[2]
  finsul.level <- str_match(bfname, "(PEX|CPVC|RigidCU)(.+)Raw")[3]
  
  # build file name of the findNfixTF.R file to source
  FNFTF.fname.R <- paste0(wd,"/findNfixTF.",bfname,".R")
STOP  
  # source the findNfixTF.R file
  source(file = FNFTF.fname.R )

   
  # tests DT_data.4 after findNfixTF.R
  # ==================================
    
  # tests to build
  # test.num == "TEST [1-9][0-9]*"
  
  
  
  
    
  # This is the end of the QA testing
  # Now build comments
  
  # collect comments for 5 records before and after every START and END
  # build lead & lag columns
  DT_lag_comments <- DT_data.4[,shift(TestFlag,n = 5:1, type = "lag", give.names = TRUE)]
  DT_lead_comments <- DT_data.4[,shift(TestFlag,n = 1:5, type = "lead", give.names = TRUE)]
 
  # combine the lead & lag columns into DT_table 
  DT_comments <- data.table(DT_data.4,DT_lag_comments,DT_lead_comments)
  
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

  # turn comments that don't include START or END into NA 
  DT_other_comments <-
    DT_comments[!is.na(comment) & !( str_detect(comment,"END") |
                                       str_detect(comment,"START") ) ,
                comment := NA]

  # list the other comments
  DT_comments[, list(n=length(record)), by=other.comment]
  
  # list comments, these should just be about the tests
  DT_comments[, list(n=length(record)), by=comment]
  
}  
  