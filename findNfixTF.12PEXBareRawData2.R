# findNfixTF.12PEXBareRawData2.R 
# this is code find and fix anomalies in TestFlag in DT_data.3 for 12PEXBareRawData2
# it is sourced by clean_data.3.R
# DT_data.4 should then pass all the subsequent tests in clean_data.3.R

# report if there are any duplicate timestamps
if( anyDuplicated(DT_data.3[,timestamp]) ) { 
  stop("duplicate timestamps in ", f,"\n") 
}

# timestamp, check attributes
# make sure it's POSIXct 
atimestamp <- attributes(DT_data.3[,timestamp]) 
if(atimestamp$class[1] != "POSIXct") {
  stop("a timestamp in ", f," is not POSIXct","\n") 
}
# make sure it's the right time zone
if(atimestamp$tzone!="America/Los_Angeles") {
  stop("a time zone in ", f," is not America/Los_Angeles","\n") 
}

# do start and end timestamps match those in DT_test_info spreadsheet
timestamp.data <- 
  DT_data.3[, list(start = min(timestamp),end = max(timestamp))]

timestamp.info <- # need to force the spreadsheet times to America/Los_Angeles
  DT_test_info[fname==paste0(bfname, ".xlsx"), 
               list(start = force_tz(start.ct, tzone = "America/Los_Angeles"), 
                    end = force_tz(end.ct, tzone = "America/Los_Angeles")
               )]
if( !identical(timestamp.data$start,timestamp.info$start) ) {
  stop("start and end times in ", f, " and DT_test_info do not match","\n") 
}

# change '.' at record 808382 TestFlag to be END
DT_data.3[record==808382, TestFlag:='END']
# this is a typo found by the following tests

# get the START and END TestFlags 
DT_SE_TestFlags <-
  DT_data.3[TestFlag=="START" | TestFlag=="END",  list(timestamp,TestFlag), 
            by=TestFlag][ ,list(n=length(timestamp)), by=TestFlag]

# report if the number of START and END TestFlags don't match
if(DT_SE_TestFlags[TestFlag=="START",n]!=DT_SE_TestFlags[TestFlag=="END",n]) {
  nSTART.END.TestFlags(DT_data.3)
  stop("different number of STARTs and ENDs in ", f, "\n") 
}

# find the missing END timestamp
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

# '.' at record 808382 TestFlag should be END
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
DT_data.3[TestFlag == 'UNIFORM TEMP.',TestFlag := 'UNIFORM TEMP' ]
DT_data.3[record == 805617 & TestFlag == '.' ,TestFlag := 'TEST 8' ]
DT_data.3[record == 806200 & TestFlag == '.' ,TestFlag := 'COOL DOWN' ] # confirm these really are COOL DOWN
DT_data.3[record == 808390 & TestFlag == '.' ,TestFlag := 'COOL DOWN' ]

# report if TestFlag contains '.'
if(nrow(DT_data.3[grepl("\\.",TestFlag), list(timestamp, record, TestFlag)])>0) {
  View(DT_data.3[grepl("\\.",TestFlag), list(timestamp, record, TestFlag)])
  cat("TestFlag with . in ", f, "\n") 
  stop("look them up in ", bfname, "\n")
}


# parse TestFlag into separate fields
# ===================================

# # edge {START|END}
# # ----------------
# DT_data.3[grepl("START",TestFlag), list(timestamp, record, TestFlag)]
# DT_data.3[grepl("START",TestFlag), edge:='START']
# DT_data.3[grepl("END",TestFlag), list(timestamp, record, TestFlag)]
# DT_data.3[grepl("END",TestFlag), edge:='END']
# DT_data.3[grepl("(END)|(START)",TestFlag), list(timestamp, record, TestFlag, edge)]


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

# get the number of pipe.nom.diam
n.pipe.nom.diam <- nrow(DT_data.3[!is.na(pipe.nom.diam), list(n=length(record)), by=pipe.nom.diam])

# test that there's only 1 nominal diameter
if(n.pipe.nom.diam>1) {
  stop("more than one nominal diameter in ", f,"\n") 
  } else { if(n.pipe.nom.diam<1) {
    stop("no nominal diameter in ", f,"\n") 
    }
  }

# get the pipe.nom.diam
p.nom.dm <- unique(DT_data.3[!is.na(pipe.nom.diam), list(pipe.nom.diam)])$pipe.nom.diam

# check that pipe.nom.diam from TestFlag matches fnom.pipe.diam from filename
if(p.nom.dm != fnom.pipe.diam) {
  stop("pipe.nom.diam does not match fnom.pipe.diam in ", f,"\n")
}

# fill in all the nominal diameters
DT_data.3[, pipe.nom.diam := p.nom.dm]


# pipe material, {PEX|CPVC|RigidCU}
# ---------------------------------
DT_data.3[grepl("PEX|CPVC|RigidCU",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("PEX|CPVC|RigidCU",TestFlag) & is.na(pipe.matl), 
          pipe.matl := str_match(TestFlag, "(PEX|CPVC|RigidCU)")[2]]
DT_data.3[, list(n=length(record)), by=pipe.matl]

# get the number of pipe.matl
n.pipe.matl <- nrow(DT_data.3[!is.na(pipe.matl), list(n=length(record)), by=pipe.matl])

# test that there's only 1 pipe material
if(n.pipe.matl>1) {
  stop("more than one pipe material in ", f,"\n") 
} else { if(n.pipe.matl<1) {
  stop("no pipe material in ", f,"\n") 
  }
}

# get the pipe.matl
p.mtl <- unique(DT_data.3[!is.na(pipe.matl), list(pipe.matl)])$pipe.matl

# check that pipe.matl from TestFlag matches fpipe.matl from filename
if(p.mtl != fpipe.matl) {
  stop("pipe.matl does not match fpipe.matl in ", f,"\n")
}

# fill in all the pipe.matl
DT_data.3[, pipe.matl := p.mtl]


# insulation level
# -------------
DT_data.3[grepl("BARE|R52|R47|R55",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[grepl("BARE|R52|R47|R55",TestFlag) & is.na(insul.level), 
          insul.level := str_match(TestFlag, "(BARE|R52|R47|R55)")[2]]
DT_data.3[, list(n=length(record)), by=insul.level]

# get the number of insulation levels
n.insul.level <- nrow(DT_data.3[!is.na(insul.level), list(n=length(record)), by=insul.level])

# test that there's only 1 insulation level
if(n.insul.level>1) {
  stop("more than one insulation level in ", f,"\n") 
} else { if(n.insul.level<1) {
  stop("no insulation level in ", f,"\n") 
  }
}

# get the insulation level
ins.lvl <- unique(DT_data.3[!is.na(insul.level), list(insul.level)])$insul.level

# check that insul.level from TestFlag matches finsul.level from filename
if(ins.lvl != toupper(finsul.level)) {
  stop("insul.level does not match finsul.level in ", f,"\n")
}

# fill in all the pipe.matl
DT_data.3[, insul.level := ins.lvl]


# COLD WARM
# -------------
DT_data.3[,cold.warm := NA]
DT_data.3[grepl("COLD|WARM",TestFlag), 
          list(n=length(record)), by=TestFlag]
DT_data.3[is.na(cold.warm) & grepl("COLD|WARM",TestFlag), 
          cold.warm := TestFlag ]
          # cold.warm := str_match_all(TestFlag, "(WARM|COLD)")[2]]
DT_data.3[grepl("COLD|WARM",TestFlag), list(n=length(record)), by=c("cold.warm", "TestFlag")]
# see if this matches with temperatures at start of tests


# check if record is in order
DT_data.3[, record.diff := shift(record, fill = 0, type = "lag")-record]
if (nrow(DT_data.3[record.diff>=0]) > 0) {
  stop("a 'record' not in sequential order in ", f,"\n") 
} else {DT_data.3[,record.diff:=NULL]}



names(DT_data.3)
str(DT_data.3)

# identify the records included in a test.segment
# where a test.segment is between START and END inclusive
#================================================

# sort DT_data.3 by record
setkey(DT_data.3, record)

# sequential numbering of START by start.num, segment is temporary variable
DT_data.3[grepl("START",TestFlag), start.num := seq_along(TestFlag)]
DT_data.3[, segment := cumsum(!is.na(start.num))]
DT_data.3[, start.num := start.num[1], by = "segment"] # fill start.num throughout segment
DT_data.3[, segment := NULL]

# reverse sort DT_data.3
setorder(DT_data.3, -record)

# sequential numbering of END by end.num, segment is temporary variable
DT_data.3[grepl("END",TestFlag), end.num := seq_along(TestFlag)]
DT_data.3[, segment := cumsum(!is.na(end.num))]
DT_data.3[, end.num := end.num[1], by = "segment"] # fill end.num throughout segment 

# reset sort order of DT_data.3
setorder(DT_data.3, record)

# set the test.segment 
# note this is not the same as test.num because 'TEST NN' is sometimes duplicate
# get the max & mins
m <- DT_data.3[, list(max.start.num = max(start.num, na.rm = TRUE),
                      min.end.num   = min(end.num, na.rm = TRUE))]

# number test.segments with the start.num inclusive of END
DT_data.3[(start.num + end.num)==(m$max.start.num+m$min.end.num),
          test.segment := start.num]

# look at results
DT_data.3[,list(n=length(record)
                ), by=c("start.num","test.segment")]
# seems OK, test this?

# extract test.segment for each 'TEST nn'
DT_TEST_nn <- unique(DT_data.3[grepl("TEST ",TestFlag), list(TestFlag, test.segment)])
setkey(DT_TEST_nn, test.segment)
str(DT_TEST_nn)

# now merge DT_TEST_nn onto DT_data.3
str(DT_data.3)
setkey(DT_data.3,record)
DT_data.4 <- merge(DT_data.3[],DT_TEST_nn[], by="test.segment", all.x = TRUE)

# clean up
names(DT_data.4)

# clean up variables
DT_data.4[, `:=` (test.num   = TestFlag.y,
                  start.num  = NULL,
                  end.num    = NULL,
                  TestFlag.y = NULL)
          ]
setnames(DT_data.4, 
         old = c("TestFlag.x" ),
         new = c("TestFlag" )
)


# cold.warm 
# ---------
# each test.segment should have a matched pair of cold.warm
n.c.w <-
  DT_data.4[cold.warm %in% c("WARM","COLD"), list(nrec=length(record)),
            by=c("test.segment","cold.warm")]$nrec
if( !all( n.c.w==rep(2,length(n.c.w)) ) ) {
  stop("number of COLD or WARM per test segment != 2 in ", f,"\n") 
}

DT_data.4[!is.na(cold.warm), list(u.c.w = unique(cold.warm)),by=test.segment ]




DT_data.4[cold.warm %in% c("WARM","COLD"),
         list( timestamp,
               record, test.segment, test.num,
               cold.warm) ]
         
# compare number test.segments
DT_data.4[, list(nrec = length(record)), by=c("test.segment","test.num")]
DT_data.4[, list(nrec = length(record)), by=c("test.segment","test.num")][order(-nrec)]

DT_data.4[!is.na(test.segment), 
          list(start.ts  = min(timestamp), 
               start.rec = min(record),
               nrec      = length(record),
               utest.num = unique(test.num),
               unom.GPM  = unique(nominal.GPM),
               unom.cw   = unique(cold.warm)
               ), by=test.segment][order(unom.GPM,unom.cw)]


# tests to build
# test.num == "TEST [1-9][0-9]*"






# # some typos?
# 2:              COOL DOWN    20
# 3: MAKE PIPE UNIFORM TEMP     2
# 4:     MAKE TEMPS UNIFORM    30
# 5:             COOLD DOWN     3
# 
# 
