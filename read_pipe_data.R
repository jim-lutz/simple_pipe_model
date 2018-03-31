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
