# check_excel_time.R
# script to compare timestamps in spreadsheet vs R
# works in DT_test_info.Rdata
# Jim Lutz "Tue Apr 10 05:52:59 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# 

# look at DT_test_info
View(DT_test_info)

# start of Excel (Windows) calendar, Excel is decimal days since 1900-01-01
starttime <- ymd("1900-01-01", tz="America/Los_Angeles")

# timestamp into days & seconds
DT_test_info[, `:=` (days.int = as.integer(start),
                     days.dec = as.numeric(start))
           ]
DT_test_info[, seconds := (days.dec-days.int) * 24 * 60 * 60 ]

# convert timestamp to POSIXct, 
DT_test_info[ , timestamp.a := starttime + days(days.int) + seconds(seconds)]

# # get rid of temporary time and date variables
# DT_test_info[, `:=` (timestamp   = timestamp.a,
#                    days.int    = NULL,
#                    days.dec    = NULL,
#                    seconds     = NULL,
#                    timestamp.a = NULL)
#            ]

# in a format to paste into spreadsheet
DT_test_info[,list(timestamp.a)]

# days from starttime
DT_test_info[, `:=` (days.int = as.integer(start),
                     days.R   = difftime(timestamp.a, starttime, units = "days"))
             ]

DT_test_info[,list(start, days.R)]
