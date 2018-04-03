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


# try readxl
if(!require(readxl)){install.packages("readxl")}
library(readxl)

# this is going to be really ugly
for(i in 1:nrow(DT_tests)) {
  # read in the header info as a tibble
  tb_header <- read_xlsx(path = DT_tests[i]$file,
                      sheet = "Sheet1",
                      range = "A1:G16",
                      col_names = FALSE)
  
  # convert to data.frame to extract specific elements
  DF_header <- as.data.frame(tb_header)

  # put elements in DT_tests
  DT_tests[i, `:=` (title    = DF_header[1,1],
                    ODin     = DF_header[2,2],
                    IDin     = DF_header[3,2],
                    gal_pls  = DF_header[2,7], # gallons per pulse
                    ft_gal   = DF_header[4,2])
           ]
  
  # CPVC files
  DT_tests[grep("CPVC",fname), 
           `:=` (TC1_gal  = DF_header[7,3],
                 TC2_gal  = DF_header[8,3],
                 TC3_gal  = DF_header[9,3],
                 TC4_gal  = DF_header[10,3],
                 TC5_gal  = DF_header[11,3],
                 TC6_gal  = DF_header[12,3],
                 TC13_gal = DF_header[13,3],
                 TC14_gal = DF_header[14,3],
                 TC22_gal = DF_header[15,3],
                 TC23_gal = DF_header[16,3])
           ]

  # non-CPVC files
  DT_tests[grep("CPVC",fname, invert = TRUE), 
           `:=` (TC1_gal  = DF_header[6,3],
                 TC2_gal  = DF_header[7,3],
                 TC3_gal  = DF_header[8,3],
                 TC4_gal  = DF_header[9,3],
                 TC5_gal  = DF_header[10,3],
                 TC6_gal  = DF_header[11,3],
                 TC13_gal = DF_header[12,3],
                 TC14_gal = DF_header[13,3],
                 TC22_gal = DF_header[14,3],
                 TC23_gal = DF_header[15,3])
           ]
  
}
             
 

str(DT_tests)
DT_tests[,2:17]

# save the header data as a csv file
write.csv(DT_tests, file= paste0(wd_data,"DT_tests.csv"), row.names = FALSE)



# put this in setup.R when it's working
# try the tidyverse readxl
install.packages("readxl")
library(readxl)

# try it out
tb_xlsx <-
read_xlsx(path = l_xlxs_fns[1],
          sheet = 1)

tb_xlsx[20:30]
# read something, needs lots of cleaning up.
