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

# data.table of distances in gallons along pipe to TCs
DT_gal <- pipe_gal(fn.Rdata=f, DT=DT_test_info) 

# load in the data.table DT_data.4
load(file = paste0(wd_data_in,f) )

# look at DT_data.4
DT_data.4

# look at the test.segments
DT_data.4[!is.na(test.segment), 
          list(start.rec = min(record),
               start.time = min(timestamp),
               nrec      = length(record),
               utest.num = unique(test.num),
               unom.GPM  = unique(nominal.GPM),
               u.cw      = unique(cold.warm)
          ), by=test.segment][order(unom.GPM,u.cw)]


# get the temp variable names
TCs <- grep("TC[0-9]+", names(DT_data.4[]), value = TRUE )

# list of variable names to keep
varnames <- c('test.segment', 'timestamp', TCs)

# add distance along pipe to DT_data.4 timestamp and temperatures
DT_plot <- data.table( DT_data.4[, varnames, with=FALSE ], DT_gal)

# sort DT_data.4 by record
setkey(DT_data.4, record)

# add the change in TC2
DT_data.4[, deltaTC2 := shift(TC2, type = "lead")- TC2 ]

str(DT_data.4)

# get the first and last record number for each test.segment
DT_fstrec <- 
  DT_data.4[!is.na(test.segment), 
            list(fstrec = min(record),
                 lstrec = max(record)), 
            by=test.segment]

# look for biggest jump in deltaTC for start of each test.segment
# find record number +- 10 around fstrec
DT_fstrec[,  `:=` (ten.before = fstrec-10,
                   ten.after  = fstrec+10)]

# initialize a blank data.table to build time.zero in
DT_tz <- data.table()

# look at all the test.segments
for(ts in unique(DT_data.4[!is.na(test.segment),]$test.segment) ) {
  
  # testing only
  # ts=1
  cat(ts,"\r")
  
  # find +-10 records around the first of each test.segment
  ten.before <- DT_fstrec[test.segment==ts, ten.before]
  ten.after  <- DT_fstrec[test.segment==ts, ten.after]

  # build a data.table to add to DT_tz
  DT_tz <- rbind(DT_tz,
                 DT_data.4[ten.before <= record & record <= ten.after,
                           list(timestamp, 
                                record, 
                                test.segment, TC1, 
                                TC2, 
                                deltaTC2, 
                                ts=ts)
                           ]
                 )
  
}

# look at the max deltaTC2 by ts
DT_tz[ , list(maxdt2=max(deltaTC2)), by=ts ][order(maxdt2)]

# look at the ts with lowest maxdt2
DT_tz[ts==26,]


View(DT_test_info)


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
                                   range = c(0,6.0)),
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

