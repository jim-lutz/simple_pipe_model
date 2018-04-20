# findNfixTF.12PEXBareRawData2.R 
# this is code find and fix anomalies in TestFlag in DT_data.3 for 12PEXBareRawData2
# it is sourced by clean_data.3.R
# DT_data.3 should then pass all the subsequent tests in clean_data.3.R

# find and fix the missing END timestamp
# ======================================

# look at the START and END timestamps
# nSTART.END.TestFlags(DT_data.3)

# missing an END between 2009-11-13 08:38:11 and 2009-11-13 09:15:03
# before.tc <- force_tz(ymd_hms("2009-11-13 08:38:11"), tzone = "America/Los_Angeles")
# after.tc  <- force_tz(ymd_hms("2009-11-13 09:15:03"), tzone = "America/Los_Angeles")

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


# find and remove TestFlag with lowercase letters
# ===============================================
# DT_data.3[grepl("[a-z]",TestFlag), list(timestamp, record, TestFlag)]

DT_data.3[grepl("[a-z]",TestFlag), TestFlag := NA]



# find and fix TestFlag with . 
# =============================
# DT_data.3[grepl("\\.",TestFlag), list(timestamp, record, TestFlag)]
#              timestamp record      TestFlag
# 1: 2009-11-13 04:36:19 799754 UNIFORM TEMP.  <- just remove the .
# 2: 2009-11-13 06:53:41 805617             .  <- should be 'TEST 8'
# 3: 2009-11-13 07:03:24 806200             .  <- may be 'COOL DOWN'? but only to 84F?
# 4: 2009-11-13 08:53:04 808390             .  <- may be 'COOL DOWN'? but only to 93.2	109.8

DT_data.3[TestFlag == 'UNIFORM TEMP.',TestFlag := 'UNIFORM TEMP' ]
DT_data.3[record == 805617 & TestFlag == '.' ,TestFlag := 'TEST 8' ]
DT_data.3[record == 806200 & TestFlag == '.' ,TestFlag := 'COOL DOWN' ] # confirm these really are COOL DOWN
DT_data.3[record == 808390 & TestFlag == '.' ,TestFlag := 'COOL DOWN' ]


# parse comments into separate fields
# ===================================

# edge {START|END}
# ----------------
DT_data.3[grepl("START",TestFlag), list(timestamp, record, TestFlag)]
DT_data.3[grepl("START",TestFlag), edge:='START']
DT_data.3[grepl("END",TestFlag), list(timestamp, record, TestFlag)]
DT_data.3[grepl("END",TestFlag), edge:='END']
DT_data.3[grepl("(END)|(START)",TestFlag), list(timestamp, record, TestFlag, edge)]

# nominal pipe diameter
# --------------------
DT_data.3[grepl("[1-9]/[1-9]",TestFlag),
          list(timestamp, record, TestFlag)]
DT_data.3[grepl("[1-9]/[1-9]",TestFlag), 
          pipe.nom.diam := str_extract(TestFlag, "[1-9]/[1-9]")
          ]
DT_data.3[grepl("[1-9]/[1-9]",TestFlag),
          list(timestamp, record, TestFlag, pipe.nom.diam)]
DT_data.3[!is.na(pipe.nom.diam), list(n=length(record)), by=pipe.nom.diam]

# pipe material, {PEX|CPVC|RigidCU}
# -------------
DT_data.3[grepl("PEX|CPVC|RigidCU",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("PEX|CPVC|RigidCU",TestFlag) & is.na(pipe.matl), 
          pipe.matl := str_match(TestFlag, "(PEX|CPVC|RigidCU)")[2]]
DT_data.3[, list(n=length(record)), by=pipe.matl]

# insulation level
# -------------
DT_data.3[!is.na(TestFlag), list(n=length(record)), by=TestFlag]
DT_data.3[grepl("BARE|R52|R47|R55",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("BARE|R52|R47|R55",TestFlag) & is.na(insul.level), 
          insul.level := str_match(TestFlag, "(BARE|R52|R47|R55)")[2]]
DT_data.3[!is.na(pipe.matl), list(n=length(record)), by=pipe.matl]








# # some typos?
# 2:              COOL DOWN    20
# 3: MAKE PIPE UNIFORM TEMP     2
# 4:     MAKE TEMPS UNIFORM    30
# 5:             COOLD DOWN     3
# 
# 
