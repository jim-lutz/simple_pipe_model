# clean_data.5.R
# script to build test segments data.table from ./data/5/*.Rdata
# saves it to ./data/5/*.test.segments.Rdata
# also some diagnostic plots of all test.segments by test suite 
# Jim Lutz "Mon May 14 08:51:41 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
source("functions.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
names(DT_test_info)
# this is information extracted from the spreadsheets

# current working directories
wd_data_in    = paste0(wd_data, "5/")
wd_data_out   = paste0(wd_data, "5/")

# get all the ./data/5/*Data[12].Rdata files
l_Rdata <- list.files(path = wd_data_in, pattern = "*Data[12].Rdata")

# loop through all the data files
for(f in l_Rdata) {
  
  # this is for testing on just one *.Rdata data.table
  # f = l_Rdata[1]   # 12PEXBareRawData2.Rdata
  # f = l_Rdata[2]   # 34PEXR47RawData2.Rdata
  
  # bare filename w/o extension
  bfname = str_remove(f,".Rdata")
  
  # load a data.table DT_data.5
  load(file = paste0(wd_data_in,f) )
  
  # look at DT_data.5  
  DT_data.5
  str(DT_data.5)
  names(DT_data.5)
  
  # look at DT_test_info
  DT_test_info
  str(DT_test_info)
  names(DT_test_info)
  
  # get the gallons per pulse 
  gal_pls <- DT_test_info[,mean(as.numeric(gal_pls))]
  
  # collect the test.segment data
  DT_test.segments <-
    DT_data.5[ !is.na(test.segment), 
                list(record.start  = min(record),
                    record.end    = max(record),
                    timestamp.start = min(timestamp), # same as time.zero
                    timestamp.end   = max(timestamp),
                    time.zero       = unique(time.zero),
                    nominal.GPM     = unique(nominal.GPM),
                    flow.ave        = gal_pls*60*(mean(pulse1)+mean(pulse2))/2,
                    Tair.ave        = unique(Tair.ave),
                    Tpipe.start     = unique(Tpipe.start),
                    cold.warm       = unique(cold.warm)
                    
                    ),
                    
               by=test.segment]
  
  # update theme to center the titles on all the plots
  theme_update(plot.title = element_text(hjust = 0.5))
  
  # look at the flow.ave vs nominal.GPM
  ggplot(data=DT_test.segments, aes(x=flow.ave, y= nominal.GPM))+
    geom_jitter(size = 3, shape = 1, height = 0.01, alpha = .5)+
    ggtitle( paste0('nominal vs calculated flow by test.segment in ', bfname) )+
    scale_x_continuous(name = "calculated flow (GPM)", limits = c(0,5))+ 
    scale_y_continuous(name = "nominal flow (GPM)",limits = c(0,5))+
    geom_abline(slope = 1, intercept = 0)
  
  ggsave(filename = paste0(bfname,"flow.png"), path=wd_charts)
  
  # find the flow.ave < 0.5
  DT_test.segments[flow.ave<0.5]
  # there were some NA test.segments
  
  # look at the Tpipe.start vs cold.warm
  ggplot(data=DT_test.segments, aes(x=Tpipe.start))+
    geom_histogram(binwidth = 1, center = .5)+
    ggtitle( paste0("pipe start temperature by test.segment in ",bfname) ) +
    ylab("count of test.segments") +
    facet_wrap(~cold.warm, scales = "free_x")
  
  ggsave(filename = paste0(bfname,"Tpipe.start.png"), path=wd_charts)
  
  # save DT_test.segments as .Rdata
  save(DT_test.segments, file = paste0(wd_data_out, bfname, ".test.segment.Rdata"))
  
} # end of loop through data files