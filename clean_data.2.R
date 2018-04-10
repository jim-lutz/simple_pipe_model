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
# View(DT_test_info)

# set up ./data/3/ directory
dir.create(paste0(wd_data,"3/"))

# get all the ./data/*.2.Rdata files
l_Rdata <- list.files(path = paste0(wd_data, "2/"), pattern = "*.Rdata")

# loop through all the files
for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  #  f = l_Rdata[7]
  
  # load a data.table DT_data.1
  load(file = paste0(wd_data, "2/",f) )
  
  # look at DT_data.2  
  DT_data.2

  # str(DT_data.2)
  
  # number of colums
  ncols <- ncol(DT_data.2)
  
  # rows without any data
  DT_data.2[rowSums(is.na(DT_data.2))==ncols,]
  # 114
  
  # keep only rows with any data
  DT_data.2a <- DT_data.2[rowSums(is.na(DT_data.2))!=ncols,]
  
  # save only rows without "STEADY-STATE PORTION OF TEST"
  # this was an different label in the middle of some of nominal GPM tests
  DT_data.2a <- DT_data.2a[!grepl("STEADY-STATE PORTION OF TEST", timestamp),]

  # find rows w/o NMONINAL or timestamp
  DT_data.2a[!grepl("NOMINAL", timestamp) & !(grepl("^[34][0-9]{4}", timestamp))]
  # problem in "34RigidCuBareRawData1.Rdata"
  
  # save only rows where timestamp is a number or "NOMINAL"
  DT_data.2a <- DT_data.2a[grepl("NOMINAL", timestamp) | (grepl("^[34][0-9]{4}", timestamp))]
  

  # find timestamp is NOMINAL or timestamp
  good.timestamp <-
  identical(DT_data.2a[grepl("NOMINAL", timestamp), timestamp],
            DT_data.2a[ !(grepl("^[34][0-9]{4}", timestamp)),timestamp])
  # should be TRUE 
  # check for this and warn if it doesn't happen
  if(good.timestamp != TRUE) { cat("timestamp has some problems in ",f,"\n") }

  # make a nominal column
  DT_data.2a[grepl("NOMINAL", timestamp), nominal:=timestamp]
  
  # duplicate nominal from row above if NA
  DT_data.2a[,segment := cumsum(!is.na(nominal))]
  DT_data.2a[,nominal := nominal[1], by = "segment"]
  DT_data.2a[,segment := NULL]

  # keep only rows without NOMINAL in timestamp
  DT_data.2b <- DT_data.2a[!grepl("TEST", timestamp),]
  
  # how many different nominal tests
  DT_data.2b[ , list(n=length(timestamp)), by="nominal"]

  # fix some typos
  DT_data.2b[, nominal := str_replace(nominal,"GOM","GPM")] # fix a typo
  DT_data.2b[, nominal := str_replace(nominal, "NOMINALl", "NOMINAL")] # this was probably a typo sometime
  
  # find nominal GPM
  DT_data.2b[, nominal.GPM := str_extract(nominal, "NOMINAL .+ GPM")]
  DT_data.2b[, nominal.GPM := str_remove(nominal.GPM, "NOMINAL ")]
  DT_data.2b[, nominal.GPM := str_remove(nominal.GPM, " GPM")]
  DT_data.2b[, nominal.GPM := as.numeric(nominal.GPM)]
  DT_data.2b[, list(n=length(timestamp)), by="nominal.GPM"][order(nominal.GPM)]

  DT_data.2b[is.na(nominal.GPM)]
  
  # check for missing nominal.GPM
  if(nrow(DT_data.2b[is.na(nominal.GPM)])>0) { cat("nominal.GPM has some problems in ", f,"\n") }
  
  # find test.type
  DT_data.2b[grepl("COLD", nominal) & grepl("START", nominal), test.type := "COLD START"]
  DT_data.2b[grepl("WARM", nominal) & grepl("START", nominal), test.type := "WARM START"]
  DT_data.2b[grepl("STEADY", nominal) & grepl("STATE", nominal), test.type := "STEADY STATE"]

  # how many different test.types
  DT_data.2b[ , list(n=length(timestamp)), by="test.type"]
  
  # check for missing test.types
  if(nrow(DT_data.2b[is.na(test.type)])>0) { cat("test.types has some problems in ", f,"\n") }
  if(nrow(DT_data.2b[is.na(test.type)])==nrow(DT_data.2b)) {
    cat("test.types missing for all records in ", f,"\n")
  }
    
  
  # start of Excel (Windows) calendar, Excel is decimal days since 1900-01-01
  starttime <- ymd("1900-01-01", tz="America/Los_Angeles")
  
  # timestamp into days & seconds
  DT_data.2b[, `:=` (days.int = as.integer(timestamp),
                     days.dec = as.numeric(timestamp))
             ]
  DT_data.2b[, seconds := (days.dec-days.int) * 24 * 60 * 60 ]
  
  # convert timestamp to POSIXct, 
  DT_data.2b[ , timestamp.a := starttime + days(days.int) + seconds(seconds)]
  
  # get rid of temporary time and date variables
  DT_data.2b[, `:=` (timestamp   = timestamp.a,
                     days.int    = NULL,
                     days.dec    = NULL,
                     seconds     = NULL,
                     timestamp.a = NULL)
                     ]

  # rename DT_data.2b to DT_data.3 for later use
  DT_data.3 <- DT_data.2b
  
  # save in .Rdata
  save(DT_data.3, file = paste0(wd_data,"3/", f))
  
}

  
