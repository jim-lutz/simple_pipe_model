# 12PEXBareRawData2.findNfixTF.R 
# this is code find and fix anomalies in TestFlag in DT_data.3 for 12PEXBareRawData2
# it is sourced by clean_data.3.R
# DT_data.3 should then pass all the subsequent tests in clean_data.3.R

# look at the START and END timestamps
# START.END.TestFlags(DT_data.3)

# missing an END between 2009-11-13 08:38:11 and 2009-11-13 09:15:03
before.tc <- force_tz(ymd_hms("2009-11-13 08:38:11"), tzone = "America/Los_Angeles")
after.tc  <- force_tz(ymd_hms("2009-11-13 09:15:03"), tzone = "America/Los_Angeles")
View(
  DT_data.3[ before.tc < timestamp & timestamp < after.tc & !is.na(TestFlag), 
           list(timestamp, record, TestFlag)]
)

# at record 808382 TestFlag should be END
DT_data.3[record==808382, TestFlag:='END']

# look at the START and END timestamps
# START.END.TestFlags(DT_data.3)


