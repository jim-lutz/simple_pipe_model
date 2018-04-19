# 12PEXBareRawData2.findNfixTF.R 
# this is code find and fix anomalies in TestFlag in DT_data.3 for 12PEXBareRawData2
# it is sourced by clean_data.3.R
# DT_data.3 should then pass all the subsequent tests in clean_data.3.R

# find and fix the missing END timestamp
# ======================================

# look at the START and END timestamps
# nSTART.END.TestFlags(DT_data.3)

# missing an END between 2009-11-13 08:38:11 and 2009-11-13 09:15:03
before.tc <- force_tz(ymd_hms("2009-11-13 08:38:11"), tzone = "America/Los_Angeles")
after.tc  <- force_tz(ymd_hms("2009-11-13 09:15:03"), tzone = "America/Los_Angeles")

# # look at the timestamp, record and TestFlag in question
# View(
#   DT_data.3[ before.tc < timestamp & timestamp < after.tc & !is.na(TestFlag), 
#            list(timestamp, record, TestFlag)]
# )

# at record 808382 TestFlag should be END
DT_data.3[record==808382, TestFlag:='END']

# # look at the timestamp, record and TestFlag in question
# View(
#   DT_data.3[ before.tc < timestamp & timestamp < after.tc & !is.na(TestFlag), 
#              list(timestamp, record, TestFlag)]
# )

# look at the START and END timestamps
# nSTART.END.TestFlags(DT_data.3)


# find and remove comments with lowercase letters
# ===============================================
# DT_data.3[grepl("[a-z]",TestFlag), list(timestamp, record, TestFlag)]

DT_data.3[grepl("[a-z]",TestFlag), TestFlag := NA]



# what about 2009-11-13 08:53:04, 808390, . ?


