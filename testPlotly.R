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

STOP

# load in the data.table DT_data.4
load(file = paste0(wd_data_in,f) )

# look at DT_data.4
DT_data.4

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
after.ts  <- force_tz(ymd_hms("2009-11-17 06:22:00"), tzone = "America/Los_Angeles")

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
# p <- plot_ly(data = DT_plot, x = ~timestamp, y = ~TC14, 
#              type = "scatter", mode =  "lines" )
# p

# 2-dimension, 3 TC traces
# p <- plot_ly(data = DT_plot, x = ~timestamp, y= ~TC2,
#              type = "scatter", mode =  "lines" ) %>%
#     add_trace( y = ~TC5) %>%
#     add_trace( y = ~TC14) 
# p

# View(DT_test_info)


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

# # my plotly user account
# usr <- Sys.getenv("plotly_username", NA)
# if (!is.na(usr)) {
#   # your account info https://api.plot.ly/v2/#users
#   api(sprintf("users/%s", usr))
#   # your folders/files https://api.plot.ly/v2/folders#user
#   api(sprintf("folders/home?user=%s", usr))
# }



# post the plot
rplot <- api_create(p, filename = "1_2 PEX BARE 1 GPM")

# rm(p)

# convert 1 trace per second?
str(DT_plot)

# convert TCn_gal to numeric
DT_plot[, `:=` (TC1_gal =  as.numeric(TC1_gal),
                TC2_gal =  as.numeric(TC2_gal),
                TC3_gal =  as.numeric(TC3_gal),
                TC4_gal =  as.numeric(TC4_gal),
                TC5_gal =  as.numeric(TC5_gal),
                TC6_gal =  as.numeric(TC6_gal),
                TC13_gal = as.numeric(TC13_gal),
                TC14_gal = as.numeric(TC14_gal))
                ]

# mins.zero to seconds
DT_plot[, secs.zero := round(mins.zero * 60)]

# remove timestamp and mins.zero
DT_plot[, `:=` (timestamp = NULL,
                mins.zero = NULL)
        ]

# remove first 4 records
DT_plot <- DT_plot[5:nrow(DT_plot)]

names(DT_plot)
DT_plot[1:10, list(TC1,TC2,secs.zero)]

# rename TC and TC _gal variables
setnames(DT_plot, old = c("TC1", "TC2", "TC3", "TC4", "TC5", "TC6", "TC13", "TC14",
                          "TC1_gal", "TC2_gal", "TC3_gal", "TC4_gal", "TC5_gal", "TC6_gal", "TC13_gal", "TC14_gal",
                          "secs.zero"),
         new = c("temp1", "temp2", "temp3", "temp4", "temp5", "temp6", "temp7", "temp8",
                 "dist1", "dist2", "dist3", "dist4", "dist5", "dist6", "dist7", "dist8",
                 "secs.zero")
)

DT_plot[1:10, ]
str(DT_plot)
dcast(DT_plot,  ~ ...)

# 3-dimension, multiple pipe traces
p1 <- plot_ly(data = DT_plot,
             x = ~mins.zero, y = ~TC1_gal,  z = ~TC1,  name = 'TC1',
             type = "scatter3d", mode= "lines") %>%
  add_trace( y = ~TC2_gal,  x = ~mins.zero, z = ~TC2,  name = 'TC2' ) %>%
  add_trace( y = ~TC3_gal,  x = ~mins.zero, z = ~TC3,  name = 'TC3' ) %>%
  add_trace( y = ~TC4_gal,  x = ~mins.zero, z = ~TC4,  name = 'TC4' ) %>%
  add_trace( y = ~TC5_gal,  x = ~mins.zero, z = ~TC5,  name = 'TC5' ) %>%
  add_trace( y = ~TC6_gal,  x = ~mins.zero, z = ~TC6,  name = 'TC6' ) %>%
  add_trace( y = ~TC13_gal, x = ~mins.zero, z = ~TC13, name = 'TC13' ) %>%
  add_trace( y = ~TC14_gal, x = ~mins.zero, z = ~TC14, name = 'TC14' ) %>%
  layout(title = "1/2 PEX, BARE, 1 GPM", 
         scene = list(yaxis = list(title = 'distance from start of pipe (gal)',
                                   range = c(0,1.25)),
                      xaxis = list(title = 'time from start of draw (min)',
                                   range = c(0,6.0)),
                      zaxis = list(title = 'temp (deg F)',
                                   range = c(50,140)),
                      camera = list( up = list(x = 0, y = 0, z = 1),
                                     eye = list(x = 1.25*1.5, y = -.75*1.5, z = .75*1.5))
         )
  )
p1  




str(DT_plot$mins.zero)
DT_plot[,list(TC5_gal, mins.zero, TC5)]
