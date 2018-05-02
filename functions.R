# functions.R
# R functions to help with pipe draw analysis

nSTART.END.TestFlags <- function(DT_data.3) {
  # function to view the number of START and END TestFlags 
  
  # TestFlag and timestamp only
  DT_TFt <- DT_data.3[TestFlag=="START" | TestFlag=="END", list(TestFlag,timestamp)]
  
  # add a variable identifying testnum
  DT_TFt[,testnum := cumsum(TestFlag=="START")]
  
  # now cast
  DT_tests <- dcast(DT_TFt, testnum ~ TestFlag, value.var = "timestamp")
  
  # remove DT_Tft, no longer needed
  rm(DT_TFt)
  
  # reset the column order
  setcolorder(DT_tests, c("testnum","START","END"))
  
  # look at it
  View(DT_tests)
  
}



pipe_gal <- function(fn.Rdata=f, DT=DT_test_info) {
  # function to get distance to TCs from start of pipe in gallons
  # returns a data.table of the distances for that filename
  
  # fn.Rdata     is the bare filename to look up data in DT_test_info
  # DT_test_info is the file with pipe distances for each spreadsheet
  
  # build the .xlsx filename
  xlsx.fname <- str_replace(fn.Rdata,".Rdata",".xlsx")
  
  # get the variable names TCnn_gal 
  TCn_gals <- grep("TC[0-9]+_gal",names(DT),value = TRUE)
  
  # get the values for TCnn_gal for that filename from DT_test_info
  DT_gal <- DT[fname==xlsx.fname, TCn_gals, with=FALSE]
  
  # convert to numeric
  name.cols <- names(DT_gal) # apply to all the columns
  DT_gal[, (names(DT_gal)) := lapply(.SD, as.numeric), .SDcols = names(DT_gal)]
  
  # which columns are zero
  # except for the first column, the start of the pipe 
  remove.col <- unlist(c(FALSE, DT_gal[1, lapply(.SD, function(x) x==0 ), .SDcols = -1]))
  
  # remove the columns with zero
  DT_gal[, which(remove.col) := NULL]
  
  # return the data.table DT_gal
  return(DT_gal)
  
}

