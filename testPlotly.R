# testPlotly.R
# script to try out Plotly on DT_data.4 from 12PEXBareRawData2.Rdata
# Jim Lutz "Thu Apr 26 08:58:10 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
source("functions.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# current working directories
wd_data_in    = paste0(wd_data, "4/")

# get all the ./data/*.4.Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*.Rdata")

# this is for testing on just one *.Rdata data.table
f = l_Rdata[1]

# load in a data.table DT_data.4
load(file = paste0(wd_data_in,f) )

# look at DT_data.4
DT_data.4

# try plotly
# https://plot.ly/r/getting-started/#getting-started-with-plotly-for-r
if(!require(plotly)){install.packages("plotly")}
library(plotly)

# test
p <- plot_ly(midwest, x = ~percollege, color = ~state, type = "box")
p
str(p)

packageVersion('plotly')
# [1] ‘4.7.1’

# figure out what to plot
names(DT_data.4)
DT_data.4[!is.na(test.segment) & nominal.GPM==1, 
          list(start.rec = min(record),
               start.time = min(timestamp),
               nrec      = length(record),
               utest.num = unique(test.num),
               unom.GPM  = unique(nominal.GPM),
               u.cw      = unique(cold.warm)
          ), by=test.segment][order(unom.GPM,u.cw)]

# try test.segment 18
# for starters x=timestamp, z=TC14
DT_plot <-
  DT_data.4[test.segment==18, 
            list(timestamp,
                 TC1, TC2, TC3, TC4, TC5, TC6, TC13, TC14
            )
            ]
# start at 6:15

before.ts <- force_tz(ymd_hms("2009-11-17 06:10:00"), tzone = "America/Los_Angeles")
after.ts  <- force_tz(ymd_hms("2009-11-17 06:25:00"), tzone = "America/Los_Angeles")

DT_plot <-
  DT_data.4[before.ts <= timestamp & timestamp <= after.ts, 
            list(timestamp,
                 TC1, TC2, TC3, TC4, TC5, TC6, TC13, TC14
            )
            ]


# 1-dimension
p <- plot_ly(data = DT_plot, x = ~TC14, type = "box")
p

# 2-dimension, 1 TC
p <- plot_ly(data = DT_plot, x = ~timestamp, y = ~TC14, 
             type = "scatter", mode =  "lines" )
p

# 2-dimension, 3 TC traces
p <- plot_ly(data = DT_plot, x = ~timestamp, y= ~TC2,
             type = "scatter", mode =  "lines" ) %>%
    add_trace( y = ~TC5) %>%
    add_trace( y = ~TC14) 
p
