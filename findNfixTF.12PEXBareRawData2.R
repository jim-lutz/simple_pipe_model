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
DT_data.3[grepl("BARE|R52|R47|R55",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("BARE|R52|R47|R55",TestFlag) & is.na(insul.level), 
          insul.level := str_match(TestFlag, "(BARE|R52|R47|R55)")[2]]
DT_data.3[, list(n=length(record)), by=insul.level]

# COLD WARM
# -------------
DT_data.3[grepl("COLD|WARM",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("COLD|WARM",TestFlag) & is.na(cold.warm), 
          cold.warm := str_match(TestFlag, "(COLD|WARM)")[2]]
DT_data.3[, list(n=length(record)), by=cold.warm]


# check if record is in order
DT_data.3[, record.diff := shift(record, fill = 0, type = "lag")-record]
if (nrow(DT_data.3[record.diff>=0]) > 0) {
  cat("a 'record' not in sequential order in ", f,"\n") 
} else {DT_data.3[,record.diff:=NULL]}

names(DT_data.3)
str(DT_data.3)

# sort DT_data.3 by record
setkey(DT_data.3, record)

# sequential numbering of START by start.num, segment is temporary variable
DT_data.3[grepl("START",TestFlag), start.num := seq_along(TestFlag)]
DT_data.3[, segment := cumsum(!is.na(start.num))]
DT_data.3[, start.num := start.num[1], by = "segment"]
DT_data.3[, segment := NULL]

# reverse sort DT_data.3
setorder(DT_data.3, -record)

# sequential numbering of END by end.num, segment is temporary variable
DT_data.3[grepl("END",TestFlag), end.num := seq_along(TestFlag)]
DT_data.3[, segment := cumsum(!is.na(end.num))]
DT_data.3[, end.num := end.num[1], by = "segment"]
DT_data.3[, segment := NULL]

# reset sort DT_data.3
setorder(DT_data.3, record)

# set the test.segment 
# note this is not the same as test.num because 'TEST NN' can be duplicated
# get the max & mins
m <- DT_data.3[, list(max.start.num = max(start.num, na.rm = TRUE),
                      min.end.num   = min(end.num, na.rm = TRUE))]

# number test.segments with the start.num inclusive of END
DT_data.3[(start.num + end.num)==(m$max.start.num+m$min.end.num),
          test.segment := start.num]

# look at results
DT_data.3[,list(n=length(record)
                ), by=c("start.num","test.segment")]
# seems OK, test?


# extract just the 'TEST nn'
DT_TEST_nn <- unique(DT_data.3[grepl("TEST ",TestFlag), list(TestFlag, test.segment)])
setkey(DT_TEST_nn, test.segment)
str(DT_TEST_nn)

# now merge it onto DT_data.3
str(DT_data.3)
setkey(DT_data.3,record)
merge(DT_data.3[],DT_TEST_nn[], by=test.segment)




# set start.num
DT_data.3[grepl("TEST",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("TEST",TestFlag) & is.na(test.num), 
          test.num := TestFlag]
DT_data.3[, list(n=length(record)), by=test.num]

# fill in test.num between START and END
View(DT_data.3)
DT_data.3[grepl("TEST 1|START|END", TestFlag), 
          list(timestamp, record, TestFlag, edge, test.num )]
(str(DT_data.3))

DT_data.3[grepl("TEST 1$", TestFlag), 
          list(timestamp, record, nominal.GPM, test.type, TestFlag, edge, test.num )]

# set flag when between START and END
names(DT_data.3)

# sequential numbering by ENDs, segment is temporary variable
DT_data.3[grepl("END",TestFlag), end.num := seq_along(TestFlag)]
DT_data.3[, segment := cumsum(!is.na(end.num))]
DT_data.3[, end.num := end.num[1], by = "segment"]
DT_data.3[, segment := NULL]


DT_data.3[grepl("TEST 1$", TestFlag), 
          list(timestamp, record, edge, test.num, start.num, end.num )]

DT_data.3[start.num==end.num, 
          list(timestamp, record, edge, test.num, start.num, end.num )]


DT_data.3[grepl("START",TestFlag),list(TestFlag,start.num,segment)]

# # some typos?
# 2:              COOL DOWN    20
# 3: MAKE PIPE UNIFORM TEMP     2
# 4:     MAKE TEMPS UNIFORM    30
# 5:             COOLD DOWN     3
# 
# 
