.P816

;___LAB_SECOND______________________________________________
;
; RETURN SYSTEM SECONDS
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_SECOND:
        ACCUMULATORINDEX8
        LDA     F:RTCSECONDS
        JSR     BCD_TO_HEX
        TAY
        LDA     #0              ; Get high byte
        JSR     LAB_AYFC
        RTS
LAB_PSECOND:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS
;___LAB_MINUTE______________________________________________
;
; RETURN SYSTEM MINUTE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_MINUTE:
        ACCUMULATORINDEX8
        LDA     F:RTCMINUTES
        JSR     BCD_TO_HEX
        TAY
        LDA     #0              ; Get high byte
        JSR     LAB_AYFC
        RTS
LAB_PMINUTE:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS
;___LAB_HOUR_________________________________________________
;
; RETURN SYSTEM HOUR
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_HOUR:
        ACCUMULATORINDEX8
        LDA     F:RTCHOUR
        JSR     BCD_TO_HEX
        TAY
        LDA     #0              ; Get high byte
        JSR     LAB_AYFC
        RTS
LAB_PHOUR:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS
;___LAB_DOW_________________________________________________
;
; RETURN SYSTEM DAY OF WEEK
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_WEEKD:
        ACCUMULATORINDEX8
        LDA     F:RTCDAYOWEEK
        JSR     BCD_TO_HEX
        TAY
        LDA     #0              ; Get high byte
        JSR     LAB_AYFC
        RTS
LAB_PWEEKD:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS
;___LAB_DAY______________________________________________
;
; RETURN SYSTEM DAY OF MONTH
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_DAY:
        ACCUMULATORINDEX8
        LDA     F:RTCDATE
        JSR     BCD_TO_HEX
        TAY
        LDA     #0              ; Get high byte
        JSR     LAB_AYFC
        RTS
LAB_PDAY:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS
;___LAB_MONTH______________________________________________
;
; RETURN SYSTEM MONTH
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_MONTH:
        ACCUMULATORINDEX8
        LDA     F:RTCMONTH
        JSR     BCD_TO_HEX
        TAY
        LDA     #0              ; Get high byte
        JSR     LAB_AYFC
        RTS
LAB_PMONTH:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS
;___LAB_YEAR________________________________________________
;
; RETURN SYSTEM YEAR
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_YEAR:
        ACCUMULATORINDEX8
        LDA     F:RTCCENTURY
        JSR     BCD_TO_HEX
        STA nums_1
        ACCUMULATOR16
        LDA nums_1-1
        AND     #$FF00
        ASL     A               ; THIS IS THE NUMBER * 512
        STA nums_1              ; PARK IT
        LSR     a               ; THIS IS THE NUMBER / 256
        PHA
        CLC                     ; ADD IT TO STORED QUANTITY
        ADC nums_1
        STA nums_1              ; PARK IT (NOW NUM*768)
        PLA
        LSR     a               ; THIS IS THE NUMBER / 128
        PHA
        CLC                     ; ADD IT TO STORED QUANTITY
        ADC nums_1
        STA nums_1              ; PARK IT (NOW NUM*896)
        PLA
        LSR     a               ; THIS IS THE NUMBER / 64
        PHA
        CLC                     ; ADD IT TO STORED QUANTITY
        ADC nums_1
        STA nums_1              ; PARK IT (NOW NUM*960)
        PLA
        LSR     a               ; THIS IS THE NUMBER / 32
        PHA
        CLC                     ; ADD IT TO STORED QUANTITY
        ADC nums_1
        STA nums_1              ; PARK IT (NOW NUM*992)
        PLA
        LSR     a               ; THIS IS THE NUMBER / 16
        LSR     a               ; THIS IS THE NUMBER / 8
        CLC                     ; ADD IT TO STORED QUANTITY
        ADC nums_1
        STA nums_1              ; PARK IT (NOW NUM*1000)
        ACCUMULATOR8
        LDA     F:RTCYEAR
        STA  Temp_2
        LDA     #$00
        STA  Temp_2+1
        ACCUMULATOR16
        LDA Temp_2
        CLC
        ADC nums_1
        STA nums_1
        ACCUMULATOR8
        LDA nums_1
        TAY
        LDA nums_1+1
        JSR     LAB_AYFC
        RTS
LAB_PYEAR:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS


BCD_TO_HEX:
        STA nums_2      ; Store in TEMP2
        AND #$F0
        LSR A           ; (shift 1 times to /2)
        STA nums_1      ; Store the /2 into TEMP
        LSR A           ;
        LSR A           ; Shift two more times to /8
        CLC
        ADC nums_1      ; add /8 + /2 to get /10
        STA nums_1      ; Store tens digit into TEMP
        LDA nums_2      ; Get Ones
        AND #$0F
        CLC
        ADC nums_1
        RTS             ; Return from subroutine