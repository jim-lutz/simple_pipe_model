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
# start at 6:10

before.ts <- force_tz(ymd_hms("2009-11-17 06:10:00"), tzone = "America/Los_Angeles")
after.ts  <- force_tz(ymd_hms("2009-11-17 06:25:00"), tzone = "America/Los_Angeles")

DT_plot <-
  DT_data.4[before.ts <= timestamp & timestamp <= after.ts, 
            list(timestamp,
                 TC1, TC2, TC3, TC4, TC5, TC6, TC13, TC14
            )
            ]


# 1-dimension
# p <- plot_ly(data = DT_plot, x = ~TC14, type = "box")
# p

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

# add distance in gallons to the DT_plot
View(DT_test_info)

# build the filename
xlsx.fname <- str_replace(f,".Rdata",".xlsx")

# get the variable name TCnn_gal 
grep("_gal",names(DT_test_info),value = TRUE)

# get the values for TCnn_gal for that filename
DT_gal <-
DT_test_info[fname==xlsx.fname, 
           list(TC1_gal, TC2_gal, TC3_gal, TC4_gal, 
                TC5_gal, TC6_gal, TC13_gal, TC14_gal)]

# add TCnn_gal to DT_plot
DT_plot <- data.table( DT_plot, DT_gal)

# convert timestamp to minutes from start
DT_plot[1:21,list(timestamp, TC2)]

# set time.zero 2009-11-17 06:15:19, record just before TC2 starts to rise
time.zero <- force_tz(ymd_hms("2009-11-17 06:15:19"), tzone = "America/Los_Angeles")

# minutes since time.zero
DT_plot[, mins.zero := as.numeric(difftime(timestamp, time.zero, units = "mins"))]


# 3-dimension, multiple TC traces
p <- plot_ly(data = DT_plot,  
             x = ~TC1_gal,  y = ~mins.zero, z = ~TC1,  name = 'TC1',
             type = "scatter3d", mode= "lines") %>%
  add_trace( x = ~TC5_gal,  y = ~mins.zero, z = ~TC5,  name = 'TC5' ) %>%
  add_trace( x = ~TC14_gal, y = ~mins.zero, z = ~TC14, name = 'TC14' ) %>%
  layout(scene = list(xaxis = list(title = 'distance from start of pipe (gal)',
                                   range = c(0,1.25)),
                      yaxis = list(title = 'time from start of draw (min)',
                                   range = c(0,10.0)),
                      zaxis = list(title = 'temp (deg F)')
                      )
         )
p  

str(DT_plot$mins.zero)
DT_plot[,list(TC5_gal, mins.zero, TC5)]