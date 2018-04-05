# read_data.R
# script to read TC data values from 
# /home/jiml/HotWaterResearch/projects/How Low/Carl's data/*.xlsx
# Jim Lutz "Wed Apr  4 15:44:00 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# set up wd_pipe_data
wd_pipe_data <- "/home/jiml/HotWaterResearch/projects/How Low/Carl's data"

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# 

# loop through all the file names
# (this is going to be really ugly)
# for(i in 1:nrow(DT_test_info)) {
  
  # for now test on the first spreadsheet
  i = 1
  
  # read in the data as a tibble
  tb_data <- read_xlsx(path = DT_test_info[i]$file,
                         sheet = "Sheet1",
                         range = "A23:R65487", # hope got all data ever
                         col_names = FALSE)
  # number at top looks OK
  pluck(tb_data, 7,2)
  
  pluck(tb_data, 1,2)
  # date is a chr 
  # [1] "40130.118900462963"

  tail(tb_data)
  pluck(tb_data,65462,2)
  
  nrow(tb_data)
  
  t <-   tail(tb_data)

  # seems to have read it all OK except for date  
  
# }