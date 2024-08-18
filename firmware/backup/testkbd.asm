.P816
.A8
.I8
;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	HC2 Keyboard Test Program                                               **
;**	Author: Dan Werner -- 3/24/2021	                                        **
;**                                                                         **
;**                                                                         **
;*****************************************************************************
;*****************************************************************************
;
;=============================================================================
; Constants Section
;=============================================================================
        .SEGMENT "MAINMEM"
        .INCLUDE "macros.asm"

;
; Hardware port addresses. SBC65816 uses the $FExx block for ECB hardware.
;
via2regb        = $FE20         ; Register
via2rega        = $FE21         ; Register
via2ddrb        = $FE22         ; Register
via2ddra        = $FE23         ; Register
via2t1cl        = $FE24         ; Register
via2t1ch        = $FE25         ; Register
via2t1ll        = $FE26         ; Register
via2t1lh        = $FE27         ; Register
via2t2cl        = $FE28         ; Register
via2t2ch        = $FE29         ; Register
via2sr          = $FE2A         ; Register
via2acr         = $FE2B         ; Register
via2pcr         = $FE2C         ; Register
via2ifr         = $FE2D         ; Register
via2ier         = $FE2E         ; Register
via2ora         = $FE2F         ; Register

KBD_DELAY       = 64            ; keyboard delay in MS.   Set higher if keys bounce, set lower if keyboard feels slow
LEDS            = $e2
KeyLock         = $e3
ScannedKey      = $e4
TEMP            = $e5           ; TEMP AREA
;
; BIOS JUMP TABLE
;
PRINTVEC        = $FF71
;INPVEC      =    $FF74
;INPWVEC     =    $FF77
;INITDISK    =    $FF7A
;READDISK    =    $FF7D
;WRITEDISK   =    $FF80
;RTC_WRITE   =    $FF83
;RTC_READ    =    $FF86
;
; Zero Page Work Vars
;
;
;=============================================================================
; Code Section
;=============================================================================
;
        .ORG    $0200

        .BYTE   "816"
;load address
;	.BYTE     $0B,$40,0,0
        .BYTE   <Start,>Start,0,0

;execute address
;	.BYTE     $0B,$40,0,0
        .BYTE   <Start,>Start,0,0

Start:
;   ensure CPU Context is in a known state
; LONG* are for the assembler context; the REP/SEP is for the code
;	$20=A  $10=I  $30=both
;	REP is ON; SEP is OFF
;

        CLD                     ; VERIFY DECIMAL MODE IS OFF
        CLC
        XCE                     ; SET NATIVE MODE
        SEP     #$30            ; 8 bit REGISTERS
        PHA                     ; Set Direct Register to 0
        PHA
        PLD
        PHA                     ; set DBR to 0
        PLB

        JSR     INITMESSAGE     ; let's say hello
        JSR     INITKEYBOARD

; allow prepopulate of screen
ploop:
        JSR     GetKey
        CMP     #$FF
        BEQ     ploop
        PHA
        JSR     PRINTVEC
        PLA
        CMP     #13
        BEQ     pexit

        JMP     ploop



pexit:

        CLC                     ; SET THE CPU TO NATIVE MODE
        XCE
        JMP     $8000
        BRK

;___________________________________________________________________________________________________
; Initialize Keyboard
;___________________________________________________________________________________________________

INITKEYBOARD:
        PHP
        SEP     #$30            ; NEED 8 bit ACCUMULATOR & INDEX
        .A8                     ;
        .I8                     ;
        PHA
        LDA     #$F0
        STA     LEDS
        LDA     #00
        STA     KeyLock
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
        SEP     #$30            ; NEED 8 bit ACCUMULATOR & INDEX
        .A8                     ;
        .I8                     ;
        PHX
        PHY

GetKey_Loop:
        JSR     kbdDelay
        JSR     ScanKeyboard
        CMP     #$FF
        BEQ     GetKey_Loop
        STA     TEMP+1
        JSR     ModifierKeyCheck
        STA     ScannedKey
GetKey_loop1:
        JSR     kbdDelay
        JSR     ScanKeyboard
        CMP     TEMP+1
        BEQ     GetKey_loop1

        LDA     ScannedKey
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
        SEP     #$30            ; NEED 8 bit ACCUMULATOR & INDEX
        .A8                     ;
        .I8                     ;
        PHX
        PHY
        LDA     #$ff            ; SET OUTPUT DIRECTION
        STA     via2ddrb        ; write value
        LDA     #$00            ; SET INPUT DIRECTION
        STA     via2ddra        ; write value

        LDY     #$00            ; SET ROW AND LEDS
outerScanLoop:
        CPY     #09
        BEQ     KeyNotFound
        STY     TEMP
        LDA     LEDS
        ORA     TEMP
        STA     via2regb        ; write value
innerScanLoop:
        LDA     via2rega        ; read value
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
        STX     TEMP
        TYA
        CLC
        ASL
        ASL
        ASL
        CLC
        ADC     TEMP
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
        SEP     #$30            ; NEED 8 bit ACCUMULATOR & INDEX
        .A8                     ;
        .I8                     ;
        PHA
; Check for Modifiers
        LDA     LEDS
        ORA     #06
        STA     via2regb        ; write value
        LDA     via2rega        ; read value
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
        SEP     #$30            ; NEED 8 bit ACCUMULATOR & INDEX
        .A8                     ;
        .I8                     ;
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
        ADC     KeyLock
skip_Lock:
        TAX
        LDA     DecodeTable,X
        PLX
        PLP
        RTS
is_CapsLock:
; check for toggle and set LEDs
        LDA     LEDS
        AND     #$10
        CMP     #$00
        BEQ     Cap_off
        LDA     LEDS
        AND     #$C0
        ORA     #$20
        STA     LEDS
        STA     via2regb        ; write value
        LDA     #72
        STA     KeyLock
        LDA     #$FF
        PLX
        PLP
        RTS
Cap_off:
        LDA     LEDS
        AND     #$C0
        ORA     #$30
        STA     LEDS
        STA     via2regb        ; write value
        LDA     #0
        STA     KeyLock
        LDA     #$FF
        PLX
        PLP
        RTS
is_GraphLock:
; check for toggle and set LEDs
        LDA     LEDS
        AND     #$20
        CMP     #$00
        BEQ     Cap_off
        LDA     LEDS
        AND     #$C0
        ORA     #$10
        STA     LEDS
        STA     via2regb        ; write value
        LDA     #192
        STA     KeyLock
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
        SEP     #$30            ; NEED 8 bit ACCUMULATOR & INDEX
        .A8                     ;
        .I8                     ;
        PHA
        PHX
        LDX     #KBD_DELAY
        LDA     #$40            ; set for 1024 cycles (MHZ)
        STA     via2t2ch        ; set VIA 2 T2C_h
kbdDelay_a:
        LDA     via2ifr         ; get VIA 2 IFR
        AND     #$20            ; mask T2 interrupt
        BEQ     kbdDelay_a      ; loop until T2 interrupt
        DEX
        BNE     kbdDelay_a
        PLX
        PLA
        PLP
        RTS
;________________________________________________________________________________________


;
;__INITMESSAGE______________________________________________________________________________________
;
;   PRINT INIT MESSAGE
;___________________________________________________________________________________________________
INITMESSAGE:
        LDY     #$00            ; LOAD $00 INTO Y
OUTSTRLP:
        LDA     HELLO,Y         ; LOAD NEXT CHAR FROM STRING INTO ACC
        CMP     #$00            ; IS NULL?
        BEQ     ENDOUTSTR       ; YES, END PRINT OUT
        JSR     PRINTVEC        ; PRINT CHAR IN ACC

        INY                     ; Y=Y+1 (BUMP INDEX)
        JMP     OUTSTRLP        ; DO NEXT CHAR
ENDOUTSTR:
        RTS


;_Text Strings and Data____________________________________________________________________________________________________
;
HELLO:
        .BYTE   $0A, $0D        ; line feed and carriage return
        .BYTE   $0A, $0D        ; line feed and carriage return
        .BYTE   "Begin Keyboard Test Program"
        .BYTE   $0A, $0D, 00    ; line feed and carriage return

;_________________________________________________________________________________________________________________________

;================================================================================
;
;binhex: CONVERT BINARY BYTE TO HEX ASCII CHARS
;
;   ————————————————————————————————————
;   Preparatory Ops: .A: byte to convert
;
;   Returned Values: .A: MSN ASCII char
;                    .X: LSN ASCII char
;                    .Y: entry value
;   ————————————————————————————————————
;
binhex:
        STORECONTEXT
        PHA                     ;save byte
        AND     #%00001111      ;extract LSN
        TAX                     ;save it
        PLA                     ;recover byte
        LSR                     ;extract...
        LSR                     ;MSN
        LSR
        LSR
        PHA                     ;save MSN
        TXA                     ;LSN
        JSR     _0000010        ;generate ASCII
        TAX                     ;save
        PLA                     ;get MSN & fall thru
        JSR     _0000010        ;generate ASCII
        STORECONTEXT
        JSR     PRINTVEC
        RESTORECONTEXT
        TXA
        JSR     PRINTVEC
        RESTORECONTEXT
        RTS
;
;
;   convert nybble to hex ASCII equivalent...
;
_0000010:
        CMP     #$0a
        BCC     _0000020        ;in decimal range
;
        ADC     #$66            ;hex compensate
;
_0000020:
        EOR     #%00110000      ;finalize nybble


        RTS                     ;done
;

        .END
