10 OPEN 3,8,4,"TFI2,SEQ,W"
20 IECOUTPUT 3
30 PUT#3,"OUT"+CHR$(13)
31 PUT#3,"OUT1"+CHR$(13)+CHR$(5)
32 PUT#3,"OUT2"+CHR$(13)+CHR$(10)+CHR$(5)
40 CLOSE 3
70 OPEN 4,8,8,"TFI2,SEQ,R"
80 IECINPUT 4
90 GET#4,A
100 PRINT A, IECST
101 IF IECST=0 THEN GOTO 90
110 CLOSE 4


10 OPEN 1,8,15,"N0:TESTDISK"
20 PRINT#1,"N0:TESTDISK,21"
30 CLOSE 1