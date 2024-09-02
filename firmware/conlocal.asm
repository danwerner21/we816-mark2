;__CONLOCAL_______________________________________________________________________________________
;
;	LOCAL CONSOLE DRIVER FOR THE WE816-MARK2
;
;	WRITTEN BY: DAN WERNER -- 8/18/2024
;
;_________________________________________________________________________________________________

;       SETUPVIDEO
;       OutVideoCh
;       SetXYVEC:
;       CPYVVEC:
;        SrlUpVEC:
;       SetColorVEC:
;       ClearScrVec:
;
;       INITKEYBOARD
;       GetKey
;
;;;
;;;
;;; 	VRAM Memory Map
;;;	$1000-$177F	40/80 Text Page 1
;;;	$1800-$1F7F	40/80 Color Page 1
;;;	$2000-$277F	40/80 Text Page 2
;;;	$2800-$2F7F	40/80 Color Page 2
;;;	$2000-$5FFF	HIRES PAGE 1
;;;	$6000-$8FFF	HIRES PAGE 2
;;;	$2000-$BFFF	DOUBLE HIRES
; IO PORTS
; Address|Description                                   |Value          |Value
;--------|----------------------------------------------|---------------|--------
;$fe30   | Scan Line Emulation                          | on            | off
;$fe31   | Display Page                                 | page 0        | page 1
;$fe32   | character generator write offset             | write offset  |
;$fe33   | character generator write                    | Value         |
;$fe34   | device command                               | Command       |
;$fe35   | Text Mode                                    | on            | off
;$fe36   | Lores Mode                                   | on            | off
;$fe37   | Double Lores Mode (must be in lores first)   | on            | off
;$fe38   | Hires Mode                                   | on            | off
;$fe39   | Double Hires Mode (must be in hires first)   | on            | off
;$fe3A   | 80 Col Mode (must be in text mode)           | on            | off
;$fe3b   | Mixed Mode   (must be in lores/hires first)  | on            | off
;$fe3c   | Quad Hires  (must be in hires first)         | on            | off
;$fe3d   | Mono Hires  (must be in hires first)         | on            | off

VDP_PAGE        = $fe31
VDP_TEXT_MODE   = $fe35
VDP_80COL_MODE  = $fe3A




;__SETUPVIDEO____________________________________________________________________________
;   Setup Video registers
;________________________________________________________________________________________
SETUPVIDEO:
        PHY
        PHA
        PHP
        ACCUMULATORINDEX8

;	Setup Width Parm
        LDA     #40
        STA     F:VIDEOWIDTH

        LDA     #1
        STA     F:VDP_PAGE

        LDA     #1
        STA     F:VDP_TEXT_MODE

        LDA     #2
        STA     F:VDP_80COL_MODE

        LDA     #$0F
        STA     F:DEFAULT_COLOR

        JSR     ClearScreen

        PLP
        PLA
        PLY
        RTS


;__Cursor________________________________________________________________________________
;   Draw A cursor
;
;________________________________________________________________________________________
CURSOR:
        PHX
        PHY
        PHA
        PHP
        ACCUMULATOR8
        INDEX16
        JSR     GetVideoAddressOffset
        LDA     F:$1800,x
        CMP     #$00
        BNE     :+
        LDA     F:DEFAULT_COLOR
:
        ASL     a
        ASL     a
        ASL     a
        ASL     a
        AND     #$F0
        STA     F:CSRCHAR
        LDA     F:$1800,x
        LSR     a
        LSR     a
        LSR     a
        LSR     a
        AND     #$0f
        ORA     F:CSRCHAR
        STA     F:$1800,x
        LDA     F:$1000,x
        STA     F:CSRCHAR
        PLP
        PLA
        PLY
        PLX
        RTS

;__UnCursor______________________________________________________________________________
;   Remove the cursor
;
;________________________________________________________________________________________
UNCURSOR:
        BRA     CURSOR




;__OutVideoCh_____________________________________________________________________________
;   Output char to screen
;
; Char in A
;________________________________________________________________________________________
OutVideoCh:
        PHX
        PHY
        PHA
        PHP
        ACCUMULATORINDEX8
        PHA
        LDA     F:CSRX
        TAX
        LDA     F:CSRY
        TAY
        PLA
        CMP     #10
        BEQ     OutVideoCh_Exit
        CMP     #13
        BEQ     OutVideoCh_CR
        CMP     #8
        LBEQ    OutVideoCh_BS
        JSR     GetVideoAddressOffset
        STA     F:$1000,X
        LDA     F:DEFAULT_COLOR
        STA     F:$1800,X
        INDEX8
        LDA     F:CSRX
        TAX
        INX
        TXA
        CMP     F:VIDEOWIDTH
        BNE     OutVideoCh_Exit
        INY
        LDX     #0
        CPY     #24
        BNE     OutVideoCh_Exit
OutVideoCh_CR1:
        LDX     #0
        TXA
        STA     F:CSRX
        LDY     #23
        TYA
        STA     F:CSRY
        LDA     F:VIDEOWIDTH
        JSR     ScrollUp

OutVideoCh_Exit:
        TXA
        STA     F:CSRX
        TYA
        STA     F:CSRY
        PLP
        PLA
        PLY
        PLX
        RTS
OutVideoCh_CR:
        INY
        CPY     #24
        BEQ     OutVideoCh_CR1
        LDX     #0
        BRA     OutVideoCh_Exit
OutVideoCh_BS:
        CPX     #0
        BEQ     OutVideoCh_BS1
        DEX
        BRA     OutVideoCh_Exit
OutVideoCh_BS1:
        CPY     #0
        BEQ     OutVideoCh_Exit
        DEY
        LDA     F:VIDEOWIDTH
        DEC     A
        TAX
        BRA     OutVideoCh_Exit

GetVideoAddressOffset:
        PHA
        LDA     F:CSRY
        ACCUMULATORINDEX16
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
; if 80 columns double it.
        ACCUMULATOR8
        LDA     F:VIDEOWIDTH
        CMP     #40
        BEQ     :+
        ACCUMULATOR16
        LDA     F:TEMP
        ASL     A
        STA     F:TEMP
:
        ACCUMULATOR16
        LDA     F:CSRX
        AND     #$00FF
        CLC
        ADC     F:TEMP
        TAX
        ACCUMULATOR8
        PLA
        RTS




;__SetColor______________________________________________________________________________
;   Setup 9918 Color
;
; Color in A - High 4 bits background, Low 4 bits Foreground
;________________________________________________________________________________________
SetColor:
        PHP
        ACCUMULATORINDEX8
        STA     F:DEFAULT_COLOR
        PLP
        RTS

;__SetXY_________________________________________________________________________________
;   Setup 9918 Cursor Position
;
; Screen Coords in X,Y
;________________________________________________________________________________________
SetXY:
        PHA
        PHP
        ACCUMULATORINDEX8
        TYA
        STA     F:CSRY
        TXA
        STA     F:CSRX
        PLP
        PLA
        RTS

;__ScrollUp______________________________________________________________________________
;   Scroll the screen up one line
;
; number of positions in line in A

;________________________________________________________________________________________
ScrollUp:
        PHA
        PHX
        PHY
        PHP
        PHB
        SETBANK 0
; if 80 columns double it.
        ACCUMULATOR8
        LDA     F:VIDEOWIDTH
        CMP     #40
        BEQ     ScrollUp_40

        ACCUMULATORINDEX16
        LDA     #$0729          ; SCROLL SCREEN MEMORY
        LDX     #$1050
        LDY     #$1000
        MVN     #$00,#$00

        LDA     #$0729          ; SCROLL COLOR MEMORY
        LDX     #$1850
        LDY     #$1800
        MVN     #$00,#$00

        ACCUMULATORINDEX8
        LDX     #$00            ; CLEAR BOTTOM LINE

ScrollUpLoop80:
        LDA     #32
        STA     F:$1730,X
        LDA     F:DEFAULT_COLOR
        STA     F:$1F30,X
        INX
        CPX     #80
        BNE     ScrollUpLoop80
        JMP     ScrollUpEnd

ScrollUp_40:
        ACCUMULATORINDEX16

        LDA     #$0397          ; SCROLL SCREEN MEMORY
        LDX     #$1028
        LDY     #$1000
        MVN     #$00,#$00

        LDA     #$0397          ; SCROLL COLOR MEMORY
        LDX     #$1828
        LDY     #$1800
        MVN     #$00,#$00

        ACCUMULATORINDEX8
        LDX     #$00            ; CLEAR BOTTOM LINE
ScrollUpLoop40:
        LDA     #32
        STA     F:$1398,X
        LDA     F:DEFAULT_COLOR
        STA     F:$1B98,X
        INX
        CPX     #40
        BNE     ScrollUpLoop40
ScrollUpEnd:
        LDX     #0
        LDY     #23
        JSR     SetXY
        PLB
        PLP
        PLY
        PLX
        PLA
        RTS


;__ClearScreen___________________________________________________________________________
;  clear Screen
;________________________________________________________________________________________
ClearScreen:
        PHY
        PHA
        PHP
        INDEX16
        ACCUMULATOR8


; Now let's clear
        LDA     F:VIDEOWIDTH
        CMP     #80
        BEQ     :+
        LDX     #$03C1
        BRA     :++
:
        LDX     #$0780
:
        LDA     #32
ClearScreen1:
        DEX
        STA     F:$1000,X
        BNE     ClearScreen1

        LDA     F:VIDEOWIDTH
        CMP     #80
        BEQ     :+
        LDX     #$03C1
        BRA     :++
:
        LDX     #$0780
:
        LDA     F:DEFAULT_COLOR
ClearScreen2:
        DEX
        STA     F:$1800,X
        BNE     ClearScreen2


        INDEX8
        LDX     #0
        TXY
        JSR     SetXY
        PLP
        PLA
        PLY
        RTS




;___________________________________________________________________________________________________
; Initialize Keyboard
;___________________________________________________________________________________________________

INITKEYBOARD:
        PHP
        ACCUMULATORINDEX8
        PHA
        LDA     #$F0
        STA     F:LEDS
        LDA     #00
        STA     KeyLock
        JSR     CapsLockOn
        PLA
        PLP
        RTS

;___________________________________________________________________________________________________
; Get a key from Keyboard
;
; Returns Key in A
;___________________________________________________________________________________________________

GetKey:
        PHP
        ACCUMULATORINDEX8
        PHX
        PHY

GetKey_Loop:
        JSR     kbdDelay
        JSR     ScanKeyboard
        CMP     #$FF
        BEQ     GetKey_Loop
        STA     F:TEMP+1
        JSR     ModifierKeyCheck
        STA     F:ScannedKey
GetKey_loop1:
        JSR     kbdDelay
        JSR     ScanKeyboard
        CMP     F:TEMP+1
        BEQ     GetKey_loop1

        LDA     F:ScannedKey
        JSR     DecodeKeyboard

        CMP     #$FF
        BEQ     GetKey_Loop
        CMP     #$00
        BEQ     GetKey_Loop
        PLY
        PLX
        PLP
        RTS


;___________________________________________________________________________________________________
; Scan Keyboard
;
; Returns Scancode in A
;
;___________________________________________________________________________________________________
ScanKeyboard:
        PHP
        ACCUMULATORINDEX8
        PHX
        PHY
        LDA     #$ff            ; SET OUTPUT DIRECTION
        STA     F:via2ddrb      ; write value
        LDA     #$00            ; SET INPUT DIRECTION
        STA     F:via2ddra      ; write value

        LDY     #$00            ; SET ROW AND LEDS
outerScanLoop:
        CPY     #09
        BEQ     KeyNotFound
        TYA
        STA     F:TEMP
        LDA     F:LEDS
        ORA     F:TEMP
        STA     F:via2regb      ; write value
innerScanLoop:
        LDA     F:via2rega      ; read value
        LDX     #$00
        CMP     #$FF            ;NO KEY PRESSED
        BEQ     exitInnerScanLoop
        CMP     #$FE            ; COL 1 key Pressed
        BEQ     keyFound
        INX
        CMP     #$FD            ; COL 2 key Pressed
        BEQ     keyFound
        INX
        CMP     #$FB            ; COL 3 key Pressed
        BEQ     keyFound
        INX
        CMP     #$F7            ; COL 4 key Pressed
        BEQ     keyFound
        INX
        CMP     #$EF            ; COL 5 key Pressed
        BEQ     keyFound
        INX
        CMP     #$DF            ; COL 6 key Pressed
        BEQ     keyFound
        INX
        CMP     #$BF            ; COL 7 key Pressed
        BEQ     keyFound
        INX
        CMP     #$7F            ; COL 8 key Pressed
        BEQ     keyFound
exitInnerScanLoop:
        INY
        JMP     outerScanLoop
KeyNotFound:
        LDA     #$FF
        PLY
        PLX
        PLP
        RTS
keyFound:
        TXA
        STA     F:TEMP
        TYA
        CLC
        ASL
        ASL
        ASL
        CLC
        ADC     F:TEMP
        CMP     #48
        BEQ     KeyNotFound
        CMP     #49
        BEQ     KeyNotFound
        CMP     #50
        BEQ     KeyNotFound
        PLY
        PLX
        PLP
        RTS

;___________________________________________________________________________________________________
; Check for Modifier keys (Shift, Control, Graph/Alt)
; Requires Scancode in A
; Returns modified Scancode in A
;
;___________________________________________________________________________________________________
ModifierKeyCheck:
        PHP
        ACCUMULATORINDEX8
        PHA
; Check for Modifiers
        LDA     F:LEDS
        ORA     #06
        STA     F:via2regb      ; write value
        LDA     F:via2rega      ; read value
        CMP     #$FF            ;NO KEY PRESSED
        BEQ     exit_Scan
        CMP     #$FE            ; COL 1 key Pressed
        BNE     check_Ctrl
        PLA
        CLC
        ADC     #72
        PLP
        RTS
check_Ctrl:
        CMP     #$FD            ; COL 2 key Pressed
        BNE     check_Graph
        PLA
        CMP     #48
        BCS     skip_Ctrl
        CLC
        ADC     #144
skip_Ctrl:
        PLP
        RTS
check_Graph:
        CMP     #$FB            ; COL 3 key Pressed
        BNE     exit_Scan
check_Graph1:
        PLA
        CMP     #48
        BCS     skip_Ctrl
        CLC
        ADC     #192
        PLP
        RTS
exit_Scan:
        PLA
        PLP
        RTS


;___________________________________________________________________________________________________
; Decode Keyboard
;
; Scancode in A
; Returns Decoded Ascii in A
;
;___________________________________________________________________________________________________
DecodeKeyboard:
        PHP
        ACCUMULATORINDEX8
        PHX
        CMP     #51             ; is CapsLock
        BEQ     is_CapsLock
        CMP     #52             ; is graphLock?
        BEQ     is_GraphLock
        CMP     #48
        BCS     skip_Lock
        CMP     #22
        BCC     skip_Lock
        CLC
        ADC     F:KeyLock
skip_Lock:
        TAX
        LDA     F:DecodeTable,X
        PLX
        PLP
        RTS
is_CapsLock:
; check for toggle and set LEDs
        LDA     F:LEDS
        AND     #$10
        CMP     #$00
        BEQ     Cap_off
CapsLockOn:
        LDA     F:LEDS
        AND     #$C0
        ORA     #$20
        STA     F:LEDS
        STA     F:via2regb      ; write value
        LDA     #72
        STA     F:KeyLock
        LDA     #$FF
        PLX
        PLP
        RTS
Cap_off:
        LDA     F:LEDS
        AND     #$C0
        ORA     #$30
        STA     F:LEDS
        STA     F:via2regb      ; write value
        LDA     #0
        STA     F:KeyLock
        LDA     #$FF
        PLX
        PLP
        RTS
is_GraphLock:
; check for toggle and set LEDs
        LDA     F:LEDS
        AND     #$20
        CMP     #$00
        BEQ     Cap_off
        LDA     F:LEDS
        AND     #$C0
        ORA     #$10
        STA     F:LEDS
        STA     F:via2regb      ; write value
        LDA     #192
        STA     F:KeyLock
        LDA     #$FF
        PLX
        PLP
        RTS

DecodeTable:
        .BYTE   '0','1','2','3','4','5','6','7'; 0
        .BYTE   '8','9','-','=','\','[',']',';'; 8
        .BYTE   39,'~',',','.','/',00,'a','b'; 16
        .BYTE   'c','d','e','f','g','h','i','j'; 24
        .BYTE   'k','l','m','n','o','p','q','r'; 32
        .BYTE   's','t','u','v','w','x','y','z'; 40
        .BYTE   $FF,$FF,$FF,$FF,$FF,11,12,14; 48
        .BYTE   15,16,27,09,03,08,17,13; 56
        .BYTE   32,28,29,30,31,01,02,04; 64

        .BYTE   ')','!','@','#','$','%','^','&'; 72  ; Shift
        .BYTE   '*','(','_','+','|','{','}',':'; 80
        .BYTE   34,'~','<','>','?',00,'A','B'; 88
        .BYTE   'C','D','E','F','G','H','I','J'; 96
        .BYTE   'K','L','M','N','O','P','Q','R'; 104
        .BYTE   'S','T','U','V','W','X','Y','Z'; 112
        .BYTE   $FF,$FF,$FF,$FF,$FF,18,19,20; 120
        .BYTE   21,22,27,09,03,08,23,13; 128
        .BYTE   32,28,29,30,31,01,02,04; 136

        .BYTE   '0','1','2','3','4','5','6','7'; 144 ; Control
        .BYTE   '8','9',234,225,224,248,249,000; 152
        .BYTE   250,251,254,176,177,00,01,02; 160
        .BYTE   03,04,05,06,07,08,09,10; 168
        .BYTE   11,12,13,14,15,16,17,18; 176
        .BYTE   19,20,21,22,23,24,25,26; 184

        .BYTE   000,178,179,180,181,182,183,184; 192 ; Graph
        .BYTE   185,186,187,188,189,190,191,192; 200
        .BYTE   193,194,195,196,197,198,199,200; 208
        .BYTE   201,202,203,204,205,206,207,208; 216
        .BYTE   209,210,211,212,213,214,215,216; 224
        .BYTE   217,218,219,220,221,222,223,167; 232




;***********************************************************************************;
;
;  delay
kbdDelay:
        PHP
        ACCUMULATORINDEX8
        PHA
        PHX
        LDX     #KBD_DELAY
        LDA     #$40            ; set for 1024 cycles (MHZ)
        STA     F:via2t2ch      ; set VIA 2 T2C_h
kbdDelay_a:
        LDA     F:via2ifr       ; get VIA 2 IFR
        AND     #$20            ; mask T2 interrupt
        BEQ     kbdDelay_a      ; loop until T2 interrupt
        DEX
        BNE     kbdDelay_a
        PLX
        PLA
        PLP
        RTS
;________________________________________________________________________________________
