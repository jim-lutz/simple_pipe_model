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
f = l_Rdata[1]  # 12PEXBareRawData2.Rdata

# data.table of distances in gallons along pipe to TCs
DT_gal <- pipe_gal(fn.Rdata=f, DT=DT_test_info) 

# load in the data.table DT_data.4
load(file = paste0(wd_data_in,f) )

# look at DT_data.4
DT_data.4

str(DT_data.4)

# look at the test.segments
DT_data.4[!is.na(test.segment), 
          list(start.rec = min(record),
               start.time = min(timestamp),
               nrec      = length(record),
               utest.num = unique(test.num),
               unom.GPM  = unique(nominal.GPM),
               u.cw      = unique(cold.warm)
          ), by=test.segment][order(unom.GPM,u.cw)]


# get the TC variable names
TCs <- grep("TC[0-9]+", names(DT_data.4[]), value = TRUE )

# list of variable names to keep
varnames <- c('test.segment', 'timestamp', 'record', TCs)

# sort DT_data.4 by record
setkey(DT_data.4, record)

# add distance along pipe to DT_data.4 timestamp and temperatures
DT_plot <- data.table( DT_data.4[, varnames, with=FALSE ], DT_gal)

# see if worked
str(DT_plot)
DT_plot[DT_plot[,.SD[1:3], by=test.segment], 
        list(timestamp, time.zero)]

# calculate time.zero from the start of each test.segment
DT_plot[!is.na(test.segment), time.zero := min(timestamp), by=test.segment]

# minutes since time.zero
DT_plot[, mins.zero := as.numeric(difftime(timestamp, time.zero, units = "mins"))]

# find the max mins.zero by test.segment
plot(
DT_plot[!is.na(test.segment), list(max.min = max(mins.zero),
               nmin    = (length(record)-1)/60),
        by=test.segment][order(nmin)]$nmin
)
# if it's below 10 mins it's likely an incomplete test.
# test.segment 49 loses temp along the pipe.

DT_plot[test.segment==49]
DT_data.4[test.segment==49]

# find last minute temp rise @ TC14
# drop the NA test.segments and keep TC14, last thermal couple
DT_test1 <- DT_data.4[!is.na(test.segment), 
                      list(TC14, nominal.GPM, nrec=length(record)), 
                      by=test.segment]

# select the last 19 rows in each test.segment
DT_test2 <- DT_test1[,.SD[(.N-19):.N],by=test.segment]

# check if temperature range is > ?
DT_test3 <-
DT_test2[ , list( temp.rise = max(TC14)-min(TC14),
                  nom.GPM   = unique(nominal.GPM),
                  nrec      = unique(nrec)              
                  ), 
          by=test.segment][order(temp.rise, nom.GPM)]

# quick look at distribution of last 2 minute temperature rise
plot(  DT_test3$temp.rise  )

# calc Tair.ave
DT_data.4[!is.na(test.segment), list(Tair.ave = (mean(TairNear)+mean(TairFar))/2),
          by=test.segment]

# calc Tpipe.start
DT_data.4[, ]


# 3-dimension, multiple TC traces
p <- plot_ly(data = DT_plot[test.segment==10], 
             type = "scatter3d", mode= "lines") %>%
  add_trace( x = ~TC1_gal,  y = ~mins.zero, z = ~TC1,  name = 'TC1' ) %>%
  add_trace( x = ~TC2_gal,  y = ~mins.zero, z = ~TC2,  name = 'TC2' ) %>%
  add_trace( x = ~TC3_gal,  y = ~mins.zero, z = ~TC3,  name = 'TC3' ) %>%
  add_trace( x = ~TC4_gal,  y = ~mins.zero, z = ~TC4,  name = 'TC4' ) %>%
  add_trace( x = ~TC5_gal,  y = ~mins.zero, z = ~TC5,  name = 'TC5' ) %>%
  add_trace( x = ~TC6_gal,  y = ~mins.zero, z = ~TC6,  name = 'TC6' ) %>%
  add_trace( x = ~TC13_gal, y = ~mins.zero, z = ~TC13, name = 'TC13' ) %>%
  add_trace( x = ~TC14_gal, y = ~mins.zero, z = ~TC14, name = 'TC14' ) %>%
  layout(title = "1/2 PEX, BARE, 1 GPM", 
         scene = list(xaxis = list(title = 'distance from start of pipe (gal)',
                                   range = c(0,1.25)),
                      yaxis = list(title = 'time from start of draw (min)',
                                   range = c(0,10.0)),
                      zaxis = list(title = 'temp (deg F)',
                                   range = c(50,140)),
                      camera = list( up = list(x = 0, y = 0, z = 1),
                                     eye = list(x = 1.25*1.5, y = -.75*1.5, z = .75*1.5))
                      )
         )
p  


# post the plot
rplot <- api_create(p, filename = "1_2 PEX BARE 1 GPM")

# rm(p)

