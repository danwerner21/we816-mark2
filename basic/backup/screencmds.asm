;___SCNCLR_________________________________________________
;
; UTILIZE BIOS TO CLEAR SCREEN
;
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SCNCLR:
        PHB
        SETBANK 0
        JSL     LClearScrVec
        PLB
        RTS


;___LOCATE_________________________________________________
;
; UTILIZE BIOS TO LOCATE CURSOR
;
;  TAKES TWO PARAMETERS X,Y
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_LOCATE:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X
        PHX
        JSR     LAB_1C01        ; (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X
        PLY
        PHB
        SETBANK 0
        JSL     LSetXYVEC
        PLB
        RTS

;___COLOR_________________________________________________
;
; UTILIZE BIOS TO SET COLORS
;
;  TAKES TWO PARAMETERS BACKGROUND,FOREGROUND
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_COLOR:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X
        TXA
        AND     #$0F
        PHA
        JSR     LAB_1C01        ; (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X
        TXA
        AND     #$0F
        STA     <TMPFLG
        PLA
        CLC
        ASL
        ASL
        ASL
        ASL
        ORA     <TMPFLG
        PHB
        SETBANK 0
        JSL     LSetColorVEC
        PLB
        RTS

;___V_SCREEN_________________________________________________
;
;  SET SCREEN MODE
;
;  TAKES UP TO THREE PARAMETERS
;  FIRST PARAMETER SCREEN MODE
;  0=TEXT MODE
;  1=LORES MODE
;  2=HIRES MODE
;
;  TEXT MODE PARAMETERS
;  0=40 COLUMNS
;  1=80 COLUMNS
;
;  LORES MODE SECOND PARAMETER
;  0=SINGLE LORES
;  1=DOUBLE LORES
;  LORES MODE THIRD PARAMETER
;  0=MIXED MODE
;  1=FULL SCREEN MODE
;
;  HIRES MODE SECOND PARAMETER
;  0=SINGLE HIRES
;  1=DOUBLE HIRES
;  2=QUAD HIRES
;  3=MONO HIRES
;  HIRES MODE THIRD PARAMETER
;  0=MIXED MODE
;  1=FULL SCREEN MODE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SCREEN:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X (MODE)
V_SCREEN1:
        STX     <VIDEOMODE
        CPX     #00
        BNE     *+5
        JMP     SETUPMODE0
        CPX     #01
        BNE     *+5
        JMP     SETUPMODE1
        CPX     #02
        BNE     *+5
        JMP     SETUPMODE2

        LDX     #$02            ; SYNTAX ERROR
        JSR     LAB_XERR
        JMP     LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
        RTS

SETUPMODE0:                     ; TEXT MODE
        LDA     #$01
        STA     F:VideoTextMode
        LDA     #$02
        STA     F:VideoLoresMode
        STA     F:VideoHiresMode
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X
        CPX     #$00
        BNE     SETUPMODE0_80
        LDA     #$02
        STA     F:Video80col
        LDA     #40
        STA     F:VIDEOWIDTH
        BRA     SETUPMODE0_CLEAR
SETUPMODE0_80:
        LDA     #$01
        STA     F:Video80col
        LDA     #80
        STA     F:VIDEOWIDTH
SETUPMODE0_CLEAR:
        JMP     V_SCNCLR
        RTS

SETUPMODE1:                     ; LORES MODE
        LDA     #$01
        STA     F:VideoLoresMode
        LDA     #$02
        STA     F:VideoTextMode
        STA     F:VideoHiresMode
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X

        CPX     #$00
        BNE     SETUPMODE1_DOUBLE
        LDA     #$02
        STA     F:VideoDoubleLores
        BRA     SETUPMODE1_CLEAR
SETUPMODE1_DOUBLE:
        LDA     #$01
        STA     F:VideoDoubleLores
        LDA     #$11
        STA     <VIDEOMODE
SETUPMODE1_CLEAR:
        PHP                     ; Clear Lores RAM
        PHB
        SETBANK 0
        INDEX16
        LDA     #$00
        LDX     #$0000
:
        STA     $2000,X
        INX
        CPX     #$0800
        BNE     :-
        INDEX8
        PLB
        PLP
        JSR     LAB_1C01        ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE THIRD PARAMETER, RETURN IN X
        CPX     #$00
        BNE     SETUPMODE1_MIXED
        LDA     #$02
        STA     F:VideoMixedMode
        RTS
SETUPMODE1_MIXED:
        LDA     #$01
        STA     F:VideoMixedMode
        LDA     <VIDEOMODE
        ORA     #$80
        STA     <VIDEOMODE
        RTS


SETUPMODE2:                     ; HIRES MODE
        LDA     #$01
        STA     F:VideoHiresMode
        LDA     #$02
        STA     F:VideoTextMode
        STA     F:VideoLoresMode
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X

        CPX     #$00
        BNE     SETUPMODE2_DOUBLE
        LDA     #$02
        STA     F:VideoDoubleHires
        STA     F:VideoQuadHires
        STA     F:VideoMonoHires
        BRA     SETUPMODE2_CLEAR
SETUPMODE2_DOUBLE:
        CPX     #$01
        BNE     SETUPMODE2_QUAD
        LDA     #$01
        STA     F:VideoDoubleHires
        LDA     #$02
        STA     F:VideoQuadHires
        STA     F:VideoMonoHires
        LDA     #$12
        STA     <VIDEOMODE
        BRA     SETUPMODE2_CLEAR
SETUPMODE2_QUAD:
        CPX     #$02
        BNE     SETUPMODE2_MONO
        LDA     #$01
        STA     F:VideoQuadHires
        LDA     #$02
        STA     F:VideoDoubleHires
        STA     F:VideoMonoHires
        LDA     #$22
        STA     <VIDEOMODE
        BRA     SETUPMODE2_CLEAR
SETUPMODE2_MONO:
        LDA     #$01
        STA     F:VideoMonoHires
        LDA     #$02
        STA     F:VideoDoubleHires
        STA     F:VideoQuadHires
        LDA     #$32
        STA     <VIDEOMODE

SETUPMODE2_CLEAR:
        PHP                     ; Clear Hires RAM
        PHB
        SETBANK 0
        INDEX16
        LDA     #$00
        LDX     #$0000
:
        STA     $2000,X
        INX
        CPX     #$8000
        BNE     :-
        INDEX8
        PLB
        PLP
        JSR     LAB_1C01        ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE THIRD PARAMETER, RETURN IN X
        CPX     #$00
        BNE     SETUPMODE2_MIXED
        LDA     #$02
        STA     F:VideoMixedMode
        RTS
SETUPMODE2_MIXED:
        LDA     #$01
        STA     F:VideoMixedMode
        LDA     <VIDEOMODE
        ORA     #$80
        STA     <VIDEOMODE
        RTS


;___V_PLOT__________________________________________________
;
;  PLOT ON SCREEN
;         TAKES THREE PARAMETERS,  X,Y,COLOR
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PLOT:
        LDA     <VIDEOMODE
        AND     #$0F
        CMP     #$01
        BEQ     V_PLOT_LORES
        LDA     <VIDEOMODE
        AND     #$2F
        CMP     #$02
        LBEQ    V_PLOT_HIRES_COLOR
        CMP     #$22
        LBEQ    V_PLOT_HIRES_MONO
        RTS
        V_PLOT_LORES:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X
        TXA
        STA     F:TEMPOFFSET    ; STORE X COORD IN OFFSET ADDRESS
        LDA     #00
        STA     F:TEMPOFFSET+1
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X
                                ; FIGURE THE BUFFER OFFSET
        TXA                     ; GET Y COORD
        PHA                     ; STORE FOR LATER
        LSR     A               ; THERE ARE TWO ROWS PER BYTE
        ACCUMULATORINDEX16      ; MULTIPLY Y COORD BY 40 OR 80 (SINGLE OR DOUBLE LORES)
        AND     #$00FF
        STA     F:TEMP
        CLC
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        PHA
        LDA     F:TEMP
        CLC
        ASL     A
        ASL     A
        ASL     A
        STA     F:TEMP
        PLA
        CLC
        ADC     F:TEMP
        STA     F:TEMP
; if double lores columns double it.
        ACCUMULATOR8
        LDA     <VIDEOMODE
        AND     #$10
        CMP     #00
        BEQ     :+
        ACCUMULATOR16
        LDA     F:TEMP
        ASL     A
        STA     F:TEMP
:
        ACCUMULATOR16
        LDA     F:TEMPOFFSET
        CLC
        ADC     F:TEMP
        STA     F:TEMPOFFSET    ; AT THIS POINT WE SHOULD HAVE THE BUFFER OFFSET CALCULATED
        ACCUMULATORINDEX8
        JSR     LAB_1C01        ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE THIRD PARAMETER, RETURN IN X (PATTERN)
        TXA
        AND     #$0F
        STA     F:TEMP          ; SAVE COLOR IN TEMP
        PLA
        LSR     A               ; TOP OR BOTTOM PIXEL?
        BCC     :+
                                ; TOP PIXEL
        ACCUMULATORINDEX16
        LDA     F:TEMPOFFSET
        TAX
        ACCUMULATOR8
        LDA     F:$2000,X
        AND     #$0F
        PHA
        LDA     F:TEMP
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        STA     F:TEMP
        PLA
        ORA     F:TEMP
        STA     F:$2000,X
        ACCUMULATORINDEX8
        RTS
:
; BOTTOM PIXEL
        ACCUMULATORINDEX16
        LDA     F:TEMPOFFSET
        TAX
        ACCUMULATOR8
        LDA     F:$2000,X
        AND     #$F0
        ORA     F:TEMP
        STA     F:$2000,X
        ACCUMULATORINDEX8
        RTS
V_PLOT_HIRES_COLOR:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X
        TXA
        PHA
        LSR     A               ; 2 PIXEL PER BYTE
        STA     F:TEMPOFFSET    ; STORE X COORD IN OFFSET ADDRESS
        LDA     #00
        STA     F:TEMPOFFSET+1
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X
                                ; FIGURE THE BUFFER OFFSET
        TXA                     ; GET Y COORD
        ACCUMULATORINDEX16      ; MULTIPLY Y COORD BY 70 OR 140 (SINGLE OR DOUBLE HIRES)
        AND     #$00FF
        STA     F:TEMP
        CLC
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        PHA
        LDA     F:TEMP
        CLC
        ASL     A
        ASL     A
        PHA
        LDA     F:TEMP
        CLC
        ASL     A
        STA     F:TEMP
        PLA
        CLC
        ADC     F:TEMP
        STA     F:TEMP
        PLA
        CLC
        ADC     F:TEMP
        STA     F:TEMP
; if double hires double it.
        ACCUMULATOR8
        LDA     <VIDEOMODE
        AND     #$10
        CMP     #00
        BEQ     :+
        ACCUMULATOR16
        LDA     F:TEMP
        ASL     A
        STA     F:TEMP
:
        ACCUMULATOR16
        LDA     F:TEMPOFFSET
        CLC
        ADC     F:TEMP
        STA     F:TEMPOFFSET    ; AT THIS POINT WE SHOULD HAVE THE BUFFER OFFSET CALCULATED
        ACCUMULATORINDEX8
        JSR     LAB_1C01        ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE THIRD PARAMETER, RETURN IN X (PATTERN)
        TXA
        AND     #$0F
        STA     F:TEMP          ; SAVE COLOR IN TEMP
        PLA
        LSR     A               ; LEFT OR RIGHT PIXEL?
        BCC     :+
                                ; LEFT PIXEL
        ACCUMULATORINDEX16
        LDA     F:TEMPOFFSET
        TAX
        ACCUMULATOR8
        LDA     F:$2000,X
        AND     #$0F
        PHA
        LDA     F:TEMP
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        STA     F:TEMP
        PLA
        ORA     F:TEMP
        STA     F:$2000,X
        ACCUMULATORINDEX8
        RTS
:
; RIGHT PIXEL
        ACCUMULATORINDEX16
        LDA     F:TEMPOFFSET
        TAX
        ACCUMULATOR8
        LDA     F:$2000,X
        AND     #$F0
        ORA     F:TEMP
        STA     F:$2000,X
        ACCUMULATORINDEX8
        RTS

V_PLOT_HIRES_MONO:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X
        TXA
        PHA
        LSR     A               ; 8 PIXEL PER BYTE
        LSR     A
        LSR     A

        STA     F:TEMPOFFSET    ; STORE X COORD IN OFFSET ADDRESS
        LDA     #00
        STA     F:TEMPOFFSET+1
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X
                                ; FIGURE THE BUFFER OFFSET
        TXA                     ; GET Y COORD
        ACCUMULATORINDEX16      ; MULTIPLY Y COORD BY 35 OR 70 (MONO OR QUAD HIRES)
        AND     #$00FF
        STA     F:TEMP
        CLC
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        PHA
        LDA     F:TEMP
        CLC
        ASL     A
        CLC
        ADC     F:TEMP
        STA     F:TEMP
        PLA
        CLC
        ADC     F:TEMP
        STA     F:TEMP
; if quad hires double it.
        ACCUMULATOR8
        LDA     <VIDEOMODE
        AND     #$10
        CMP     #00
        BNE     :+
        ACCUMULATOR16
        LDA     F:TEMP
        ASL     A
        STA     F:TEMP
:
        ACCUMULATOR16
        LDA     F:TEMPOFFSET
        CLC
        ADC     F:TEMP
        STA     F:TEMPOFFSET    ; AT THIS POINT WE SHOULD HAVE THE BUFFER OFFSET CALCULATED
        ACCUMULATORINDEX8
        JSR     LAB_1C01        ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE THIRD PARAMETER, RETURN IN X (PATTERN)
        TXA
        AND     #$01
        STA     F:TEMP          ; SAVE COLOR IN TEMP
        PLA
        AND     #$07            ; WHICH BIT?
        TAX
        LDA     F:TEMP
        CMP     #$01
        BNE     :+
        LDA     F:HIRES_BIT_LOOKUP_SET,X
        PHA
        ACCUMULATORINDEX16
        LDA     F:TEMPOFFSET
        TAX
        ACCUMULATOR8
        PLA
        ORA     F:$2000,X
        STA     F:$2000,X
        INDEX8
        RTS
:
        LDA     F:HIRES_BIT_LOOKUP_RESET,X
        PHA
        ACCUMULATORINDEX16
        LDA     F:TEMPOFFSET
        TAX
        ACCUMULATOR8
        PLA
        AND     F:$2000,X
        STA     F:$2000,X
        INDEX8
        RTS
HIRES_BIT_LOOKUP_S:
        .BYTE   %10000000,%01000000,%00100000,%00010000,%00001000,%00000100,%00000010,%00000001
HIRES_BIT_LOOKUP_R:
        .BYTE   %01111111,%10111111,%11011111,%11101111,%11110111,%11111011,%11111101,%11111110
HIRES_BIT_LOOKUP_SET=
        (PROGRAMBANK*$10000)+HIRES_BIT_LOOKUP_S
HIRES_BIT_LOOKUP_RESET=
        (PROGRAMBANK*$10000)+HIRES_BIT_LOOKUP_R

;___V_PATTERN________________________________________________
;
;  DEFINE GRAPHICS PATTERN
;
;  TAKES 10 PARAMETERS
;       PATTERN NUM (0-255)
;       PATTERN DATA (8 BYTES)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PATTERN:
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X
        TXA
        STA     f:VideoCharGenOffset
        LDY     #8
:
        JSR     LAB_1C01        ; GET THE NEXT PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE NEXT PARAMETER, RETURN IN X
        TXA
        STA     f:VideoCharGenData
        DEY
        CPY     #$00
        BNE     :-
        RTS
