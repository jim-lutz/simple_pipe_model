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
  DT_data.3[, `:=` (pipe.matl     = as.character(),
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

   

}  
  