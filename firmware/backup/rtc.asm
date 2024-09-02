        .A8
        .I8

;__RTC_____________________________________________________________________________________________
;
;	Real Time Clock DRIVER
;	Dan Werner -- 9/1/2024
;
;__________________________________________________________________________________________________

;__RTCREAD_________________________________________________________________________________________
;	Read Real Time Clock Register
;	Address - X
;       Data Returned in A
;__________________________________________________________________________________________________
RTCREAD:
        PHP
        ACCUMULATORINDEX8
        TXA
        STA     F:RTCA          ; Set Address
        NOP
        NOP
        NOP
        LDA     F:RTC           ; Get Data
        PLP
        RTS


;__RTCWRITE________________________________________________________________________________________
;	Write Real Time Clock Register
;	Address - X
;       Data - A
;__________________________________________________________________________________________________
RTCWRITE:
        PHP
        ACCUMULATORINDEX8
        PHA
        TXA
        STA     F:RTCA          ; Set Address
        NOP
        NOP
        NOP
        PLA
        STA     F:RTC           ; Put Data
        PLP
        RTS
