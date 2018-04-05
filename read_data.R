# read_data.R
# script to read TC data values from 
# /home/jiml/HotWaterResearch/projects/How Low/Carl's data/*.xlsx
# saves uncleaned, unlabeled data.tables as *.xlsx.1.Rdata
# Jim Lutz "Wed Apr  4 15:44:00 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# set up wd_pipe_data
wd_pipe_data <- "/home/jiml/HotWaterResearch/projects/How Low/Carl's data"

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
View(DT_test_info)

# loop through all the file names
# (this is going to be really ugly)
for(i in 1:nrow(DT_test_info)) {
  
  # this is for testing on just the first spreadsheet
  # i = 1

  # read in the data as a tibble
  tb_data <- read_xlsx(path = DT_test_info[i]$file,
                         sheet = "Sheet1",
                         range = DT_test_info[i]$data_range, 
                         col_names = FALSE)

  # read in the notes as a tibble
  tb_notes <- read_xlsx(path = DT_test_info[i]$file,
                       sheet = "Sheet1",
                       range = DT_test_info[i]$notes_range, 
                       col_names = FALSE)
  
  # merge notes onto data
  tb_data <- bind_cols(tb_data,tb_notes)

  # convert to data.table
  DT_data.1 <- as.data.table(tb_data)

  # save data.table
  save(DT_data.1, file = paste0(wd_data,DT_test_info[i]$fname,".1.Rdata"))

  }
# Error: Cell references aren't uniformly A1 or R1C1 format:
# A24:R115758
# In addition: There were 34 warnings (use warnings() to see them)
# all but the last warning are about 'NAN' in column E
# seems to have choked in 34CPVCBareRawData2.xlsx



