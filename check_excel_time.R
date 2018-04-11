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

# look at DT_test_info
View(DT_test_info)

str(DT_test_info)
# note start and end are chr not num

# # start of Excel (Windows) calendar, Excel is decimal days since 1900-01-01
# starttime <- ymd("1900-01-01", tz="America/Los_Angeles")
# 
# str(starttime)
# 
# # check R days between 2009-11-13 and 1900-01-01, 40130 from spreadsheet
# testdate <- ymd("2009-11-13", tz="America/Los_Angeles")
# 
# str(difftime(testdate, starttime, units = "days"))
# # Class 'difftime'  atomic [1:1] 40128
# #   ..- attr(*, "units")= chr "days"

# R is probably missing leap years or something
# see https://stackoverflow.com/questions/19172632/converting-excel-datetime-serial-number-to-r-datetime

# serial dates as.numeric
DT_test_info[, `:=` (start.num = (as.numeric(start)),
                     end.num   = (as.numeric(  end)))
             ]
str(DT_test_info)
DT_test_info[,list(start.num, end.num)]

# serial dates as.Date
DT_test_info[, `:=` (start.ct = as.POSIXct(start.num * 24*60*60,
                                           origin="1899-12-30",
                                           tz = "UTC"),
                     end.ct   = as.POSIXct(end.num * 24*60*60,
                                           origin="1899-12-30",
                                           tz = "UTC"))
             ]
str(DT_test_info)
DT_test_info[,list(fname, start.num, start.ct, end.num, end.ct)]
attributes(DT_test_info$start.ct)
attributes(DT_test_info$end.ct)

# change the timezones
force_tz(DT_test_info$start.ct, tzone = "America/Los_Angeles")
force_tz(DT_test_info$end.ct, tzone = "America/Los_Angeles")

# look at what happened
DT_test_info[,list(fname, start.num, start.ct, end.num, end.ct)]
attributes(DT_test_info$start.ct)
attributes(DT_test_info$end.ct)



# save the test info data as a csv file
write.csv(DT_test_info, file= paste0(wd_data,"DT_test_info.csv"), row.names = FALSE)

# save the test info data as an .Rdata file
save(DT_test_info, file = paste0(wd_data,"DT_test_info.Rdata"))



