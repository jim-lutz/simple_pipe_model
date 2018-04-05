# test_read_largexlsx.R
# script to read data values from large xlsx sheet

install.packages("reprex")
library(reprex)

# work with tidyverse
# http://tidyverse.org/
if(!require(tidyverse)){install.packages("tidyverse")}
library(tidyverse)

# read in the data as a tibble
tb_data <- read_excel(path = "large_sheet.xlsx",
                     sheet = "Sheet1",
                     range = "A24:R115758", 
                     col_names = FALSE)

# Error: Cell references aren't uniformly A1 or R1C1 format:
# A24:R115758
# In addition: Warning message:
# Cell reference follows neither the A1 nor R1C1 format. Example:
# R115758
# NAs generated. 

# read in part of the data as a tibble
tb_data <- read_excel(path = "large_sheet.xlsx",
                     sheet = "Sheet1",
                     range = "A24:R95758", 
                     col_names = FALSE)

tb_data
# # A tibble: 95,735 x 18
#   X__1          X__2  X__3  X__4  X__5  X__6  X__7  X__8  X__9 X__10 X__11 X__12 X__13
#   <chr>        <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <lgl> <lgl> <lgl>
#   1 NOMINAL 0…     NA    NA    NA    NA   NA    NA    NA    NA    NA   NA    NA    NA   
# 2 40024.158… 543660.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 3 40024.158… 543661.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 4 40024.158… 543662.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 5 40024.158… 543663.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 6 40024.158… 543664.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 7 40024.158… 543665.    0.    1.  135.  70.0  70.2  70.2  71.0  70.4 NA    NA    NA   
# 8 40024.158… 543666.    4.    4.  135. 133.   71.0  70.2  71.3  70.7 NA    NA    NA   
# 9 40024.158… 543667.    1.    0.  135. 131.   71.0  70.5  71.4  70.8 NA    NA    NA   
# 10 40024.158… 543668.    0.    1.  135. 133.   71.0  70.6  71.3  71.0 NA    NA    NA   
# # ... with 95,725 more rows, and 5 more variables: X__14 <lgl>, X__15 <lgl>,
# #   X__16 <lgl>, X__17 <dbl>, X__18 <dbl>


# read in using unbounded rectangle, rows 24+ , columns 1:18
tb_data <- read_excel(path = "large_sheet.xlsx",
                      sheet = "Sheet1",
                      range = cell_limits(c(24, 1), c(NA, 18)),
                      col_names = FALSE)
# A tibble: 115,735 x 18
#   X__1          X__2  X__3  X__4  X__5  X__6  X__7  X__8  X__9 X__10 X__11 X__12 X__13
#   <chr>        <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <lgl> <lgl> <lgl>
#   1 NOMINAL 0…     NA    NA    NA    NA   NA    NA    NA    NA    NA   NA    NA    NA   
# 2 40024.158… 543660.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 3 40024.158… 543661.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 4 40024.158… 543662.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 5 40024.158… 543663.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 6 40024.158… 543664.    1.    1.  135.  70.0  70.2  70.2  71.0  70.3 NA    NA    NA   
# 7 40024.158… 543665.    0.    1.  135.  70.0  70.2  70.2  71.0  70.4 NA    NA    NA   
# 8 40024.158… 543666.    4.    4.  135. 133.   71.0  70.2  71.3  70.7 NA    NA    NA   
# 9 40024.158… 543667.    1.    0.  135. 131.   71.0  70.5  71.4  70.8 NA    NA    NA   
# 10 40024.158… 543668.    0.    1.  135. 133.   71.0  70.6  71.3  71.0 NA    NA    NA   
# ... with 115,725 more rows, and 5 more variables: X__14 <lgl>, X__15 <lgl>,
#   X__16 <lgl>, X__17 <dbl>, X__18 <dbl>


