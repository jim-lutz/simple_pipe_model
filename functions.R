# functions.R
# R functions to help with shower clearing draw analysis

START.END.TestFlags <- function(DT_data.3) {
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

