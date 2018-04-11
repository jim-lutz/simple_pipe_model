# clean_data.1.R
# script to do initial cleaning on  ./data/1/*.xlsx.1.Rdata files
# renaming columns to keep and dropping others
# saves data.tables as ./data/2/*.Rdata
# Jim Lutz "Thu Apr  5 17:19:21 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the test info
load(file = paste0(wd_data, "DT_test_info.Rdata"))

# look at DT_test_info
View(DT_test_info)

# set up data/2/ directory
dir.create(paste0(wd_data,"2/"))

# loop through all the .1.Rdata files
for(i in 1:nrow(DT_test_info)) {
  
  # this is for testing on just one *.xlsx.1.Rdata spreadsheet
  # i = 5
  
  # for ease of coding
  this.fname.xlsx  <- DT_test_info[i]$fname
  this.fname       <- str_remove(this.fname.xlsx, ".xlsx")
  this.matl        <- DT_test_info[i]$matl
  this.nom.diam    <- DT_test_info[i]$nom.diam
  
  
  # load a data.table DT_data.1
  load(file = paste0(wd_data, "1/",this.fname.xlsx,".1.Rdata")) 
  
  # fix the names in DT_data.1
  # these are consistent over all the data sets
  setnames(DT_data.1, 
           old = c("X__1", "X__2", "X__3", "X__4"),
           new = c("timestamp", "record", "pulse1", "pulse2")
           )

  # these are consistent over all the data sets
  setnames(DT_data.1, 
           old = c("X__5", "X__6", "X__7", "X__8", "X__9", "X__10"),
           new = c("TC1", "TC2", "TC3", "TC4", "TC5", "TC6")
  )

  # for TairNear and TairFar
  # 1/2 PEX TC7 & TC8
  # 1/2 PEX TC7 & TC8
  # 3/4 CPVC TC13 & TC14
  # 3/4 CPVC TC13 & TC14
  # 3/4 PEX TC13 & TC14
  # 3/4 PEX TC13 & TC14
  # 3/4 RIGID CU TC7 & TC8
  # 3/4 RIGID CU TC7 & TC8
  # 3/8 PEX TC7 & TC8
  # 3/8 PEX TC7 & TC8
  # 3/4 RIGID CU TC7 & TC8
  if(this.nom.diam==3/4 & (this.matl=="CPVC" | this.matl=="PEX")) {
    setnames(DT_data.1, 
           old = c("X__17", "X__18"),
           new = c("TairNear", "TairFar")
           )
  } else {
    setnames(DT_data.1, 
             old = c("X__11", "X__12"),
             new = c("TairNear", "TairFar")
    )
    
  }

  # for additional water temps
  # 1/2 PEX TC13 & TC14
  # 1/2 PEX TC13 & TC14
  # 3/4 CPVC
  # 3/4 CPVC
  # 3/4 PEX
  # 3/4 PEX
  # 3/4 RIGID CU TC13 TC14 TC22 & TC23
  # 3/4 RIGID CU TC13 TC14 TC22 & TC23
  # 3/8 PEX TC13 & TC14
  # 3/8 PEX TC13 & TC14
  # 3/4 RIGID CU TC13 TC14 TC22 & TC23
  if( (this.nom.diam!=3/4) & this.matl=="PEX" ) {
    setnames(DT_data.1, 
             old = c("X__17", "X__18"),
             new = c("TC13", "TC14")
             )
  } else { 
    if( this.nom.diam==3/4 & this.matl=="Cu") {
      setnames(DT_data.1, 
               old = c("X__17", "X__18", "X__26", "X__27"),
               new = c("TC13", "TC14", "TC22",  "TC23")
               )
      }
  } 
  
  # TestFlag
  setnames(DT_data.1, 
           old = c("X__31"),
           new = c("TestFlag")
           )

  # get rid of any columns that weren't renamed
  drop.names <- grep( "X__", names(DT_data.1), value = TRUE, invert = FALSE )
  set(DT_data.1, j = drop.names, value = NULL)

  # find start and end timestamps
  DT_span <-
  DT_data.1[grepl("[0-9]{5}",timestamp),
            list(start = min(timestamp),
                 end   = max(timestamp))]
  
  # add start and end to DT_test_info, at this point these are chr of Excel serial numbers
  DT_test_info[fname==this.fname.xlsx, `:=` (start = DT_span[,start],
                                             end   = DT_span[,end])]
  
  # rename DT_data.1 for later tracking
  DT_data.2 <- DT_data.1
  
  # save in .Rdata
  save(DT_data.2, file = paste0(wd_data,"2/", this.fname, ".Rdata"))
  
}
  
# and now save DT_test_info
# save the test info data as a csv file
write.csv(DT_test_info, file= paste0(wd_data,"DT_test_info.csv"), row.names = FALSE)

# save the test info data as an .Rdata file
save(DT_test_info, file = paste0(wd_data,"DT_test_info.Rdata"))

