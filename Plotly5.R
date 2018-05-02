# Plotly5.R
# script to make some Plotly plots on DT_data.5 from 12PEXBareRawData2.Rdata
# Jim Lutz "Wed May  2 12:26:24 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
source("functions.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# current working directories
wd_data_in    = paste0(wd_data, "5/")

# get all the ./data/*.5.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*.Rdata")

# this is for testing on just one *.Rdata data.table
f = l_Rdata[1]  # 12PEXBareRawData2.Rdata

# load in the data.table DT_data.5
load(file = paste0(wd_data_in,f) )

# look at DT_data.5
DT_data.5
str(DT_data.5)
names(DT_data.5)

# look at the test.segments
DT_data.5[!is.na(test.segment), 
          list(start.rec = min(record),
               start.time = min(timestamp),
               nrec      = length(record),
               utest.num = unique(test.num),
               unom.GPM  = unique(nominal.GPM),
               u.cw      = unique(cold.warm),
               plotOK    = unique(plot.OK)
          ), by=test.segment][order(unom.GPM,u.cw)]


# get the TC variable names
TCs <- grep("TC[0-9]+", names(DT_data.4[]), value = TRUE )

# test.segment selection 
ts = 10

# labels
pipe.nom.diam = DT_data.5[test.segment==ts,unique(pipe.nom.diam)]
pipe.matl     = DT_data.5[test.segment==ts,unique(pipe.matl)]
insul.level   = DT_data.5[test.segment==ts,unique(insul.level)]
nominal.GPM   = DT_data.5[test.segment==ts,unique(nominal.GPM)]
Tpipe.start   = DT_data.5[test.segment==ts,unique(Tpipe.start)]

# title for chart
ftitle  = sprintf("%s %s %s, %d GPM, Tstart = %2.1f",
                  pipe.nom.diam, pipe.matl, insul.level, nominal.GPM, Tpipe.start)
ftitle

# name for file
fname = str_replace(ftitle,"/","")
fname = str_replace(fname,"Tstart = ","")
fname = str_remove(fname,"\\.\\d")
fname = str_replace_all(fname,",","")
fname = str_replace_all(fname," ","_")
fname

# 3-dimension, multiple TC traces
p <- plot_ly(data = DT_data.5[test.segment==ts], 
             type = "scatter3d", mode= "lines") %>%
  add_trace( x = ~TC1_gal,  y = ~mins.zero, z = ~TC1,  name = 'TC1' ) %>%
  add_trace( x = ~TC2_gal,  y = ~mins.zero, z = ~TC2,  name = 'TC2' ) %>%
  add_trace( x = ~TC3_gal,  y = ~mins.zero, z = ~TC3,  name = 'TC3' ) %>%
  add_trace( x = ~TC4_gal,  y = ~mins.zero, z = ~TC4,  name = 'TC4' ) %>%
  add_trace( x = ~TC5_gal,  y = ~mins.zero, z = ~TC5,  name = 'TC5' ) %>%
  add_trace( x = ~TC6_gal,  y = ~mins.zero, z = ~TC6,  name = 'TC6' ) %>%
  add_trace( x = ~TC13_gal, y = ~mins.zero, z = ~TC13, name = 'TC13' ) %>%
  add_trace( x = ~TC14_gal, y = ~mins.zero, z = ~TC14, name = 'TC14' ) %>%
  layout(title = ftitle, 
         scene = list(xaxis = list(title = 'distance from start of pipe (gal)',
                                   range = c(0,1.25)),
                      yaxis = list(title = 'time from start of draw (min)',
                                   range = c(0,10.0)),
                      zaxis = list(title = 'temp (deg F)',
                                   range = c(45,140)),
                      camera = list( up = list(x = 0, y = 0, z = 1),
                                     eye = list(x = 1.875, y = -1.125, z = 1.125))
                      )
         )
p  



# post the plot
rplot <- api_create(p, filename = "1_2 PEX BARE 1 GPM")

# rm(p)

