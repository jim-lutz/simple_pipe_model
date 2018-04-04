# read_pipe_data.R
# script to read pipe data from 
# /home/jiml/HotWaterResearch/projects/How Low/Carl's data/*.xlsx
# saves output to .Rdata file
# Jim Lutz "Fri Mar 30 17:32:36 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
# source("functions.R")
# nothing here yet

# set up wd_pipe_data
wd_pipe_data <- "/home/jiml/HotWaterResearch/projects/How Low/Carl's data"

# get a list of all the *.xlsx files in the pipe data directory
l_xlxs_fns <-
  list.files(path = wd_pipe_data, 
             pattern = "*.xlsx$", 
             recursive = TRUE, 
             full.names = TRUE)
l_xlxs_fns[1]
# [1] "/home/jiml/HotWaterResearch/projects/How Low/Carl's data/12PEXBareRawData2.xlsx"

# turn this into a data.table
# to add metadata to before trying to read the test data itself
DT_tests <- data.table(file=l_xlxs_fns)

# just the file names
DT_tests[, fname:= str_extract(file,"a/((.+).xlsx)")]
DT_tests[, fname:= str_remove(fname, "a/")]

# loop through all the file names
# (this is going to be really ugly)
for(i in 1:nrow(DT_tests)) {
  # read in the header info as a tibble
  tb_header <- read_xlsx(path = DT_tests[i]$file,
                      sheet = "Sheet1",
                      range = "A1:G16",
                      col_names = FALSE)
  
  # put elements in DT_tests
  DT_tests[i, `:=` (title    = pluck(tb_header,1,1),
                    ODin     = pluck(tb_header,2,2),
                    IDin     = pluck(tb_header,2,3), # pluck is column first
                    gal_pls  = pluck(tb_header,7,2), # gallons per pulse
                    ft_gal   = pluck(tb_header,2,4)
                    )
           ]
  
  # adjust subsequent rows for CPVC files
  first.TC.row = ifelse(grepl("CPVC", DT_tests[i]$file),7,6)
  
  # # get the TC location in gallons
  DT_tests[i, `:=` (TC1_gal  = pluck(tb_header,3,first.TC.row  ),
                    TC2_gal  = pluck(tb_header,3,first.TC.row+1),
                    TC3_gal  = pluck(tb_header,3,first.TC.row+2),
                    TC4_gal  = pluck(tb_header,3,first.TC.row+3),
                    TC5_gal  = pluck(tb_header,3,first.TC.row+4),
                    TC6_gal  = pluck(tb_header,3,first.TC.row+5),
                    TC13_gal = pluck(tb_header,3,first.TC.row+6),
                    TC14_gal = pluck(tb_header,3,first.TC.row+7),
                    TC22_gal = pluck(tb_header,3,first.TC.row+8),
                    TC23_gal = pluck(tb_header,3,first.TC.row+9))
           ]
  

}
             

# save the header data as a csv file
write.csv(DT_tests, file= paste0(wd_data,"DT_tests.csv"), row.names = FALSE)



