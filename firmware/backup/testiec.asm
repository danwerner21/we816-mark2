.P816
.A8
.I8
;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	HC2 IEC Test Program                                               **
;**	Author: Dan Werner -- 4/9/2021	                                        **
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



; BIOS JUMP TABLE
;
PRINTVEC        = $FF71
OUTCH           = $FF71
outch           = $FF71
INPVEC          = $FF74
INPWVEC         = $FF77
;INITDISK    =    $FF7A
;READDISK    =    $FF7D
;WRITEDISK   =    $FF80
;RTC_WRITE   =    $FF83
;RTC_READ    =    $FF86
SETLFS          = $FFA4
SETNAM          = $FFA7
LOAD            = $FFAA
SAVE            = $FFAD
IECINIT         = $FFB0

IECCLCH         = $FFB3         ; close input and output channels
IECOUTC         = $FFB6         ; open a channel for output
IECINPC         = $FFB9         ; open a channel for input
IECOPNLF        = $FFBC         ; open a logical file
IECCLSLF        = $FFBF         ; close a specified logical file
IECREAD         = $FF92         ; READ AN IEC BUS BYTE
IECWRITE        = $FF95         ; WRITE AN IEC BUS BYTE

IECSTW          = $0317         ; Status word
IECMSGM         = $031F         ; message mode flag,
; $C0 = both control and kernal messages,
; $80 = control messages only,
; $40 = kernal messages only,
; $00 = neither control or kernal messages
IECFNPL         = $0320         ; File Name Pointer Low,
IECFNPH         = $0321         ; File Name Pointer High,
LOADBUFL        = $0322         ; low byte IEC buffer Pointer
LOADBUFH        = $0323         ; High byte IEC buffer Pointer
LOADBANK        = $0324         ; BANK buffer Pointer
; ADDED
IECOPENF        = $0325         ; OPEN FILE COUNT
IECLFN          = $0326         ; IEC LOGICAL FILE NUMBER
IECIDN          = $0327         ; input device number
IECODN          = $0328         ; output device number

PTRLFT          = $03B0         ; .. to LAB_0262 logical file table
PTRDNT          = $03BA         ; .. to LAB_026C device number table
PTRSAT          = $03C4         ; .. to LAB_0276 secondary address table
FREESPC         = $03CE
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
        ACCUMULATORINDEX8
        JSR     IECINIT
        LDA     #$C0
        STA     IECMSGM


;; this will generate an error
        LDX#8                   ; Device Number
        LDY#1                   ; secondary address
        JSR     SETLFS          ;setlfs
        LDA#1                   ; fn length
        LDX#<FNPOINTER
        LDY#>FNPOINTER
        JSR     SETNAM          ; setnam
        LDA#$50
        STA     LOADBUFH
        LDA#$00
        STA     LOADBUFL
        LDA#02
        STA     LOADBANK
        JSR     LOAD

        LDA     #8
        JSR     GETIECSTATUS

        LDA     #8
        JSR     GETIECDIRECTORY




;     ldx#8           ; Device Number
;     ldy#1           ; secondary address
;     jsr     LAB_FE50 ;setlfs
;     lda#4           ; fn length
;     ldx#<FNPOINTER1
;     ldy#>FNPOINTER1
;     jsr     LAB_FE49 ; setnam
;     lda#$50
;     sta IECSTRTH
;     lda#$0
;     sta IECSTRTL
;     lda#$55
;     sta LOADBUFH
;     lda#$00
;     sta LOADBUFL
;     lda#02
;     sta LOADBANK
;     jsr     IECSAVERAM


;    ldx#8           ; Device Number
;    ldy#1           ; secondary address
;    jsr     LAB_FE50 ;setlfs
;    lda#1           ; fn length
;    ldx#<FNPOINTER
;    ldy#>FNPOINTER
;    jsr     LAB_FE49 ; setnam
;    lda#$60
;    sta LOADBUFH
;    lda#$00
;    sta LOADBUFL
;    lda#02
;    sta LOADBANK
;    jsr     LOADTORAM


Exit:
        CLC                     ; SET THE CPU TO NATIVE MODE
        XCE
        JMP     $8000
        BRK


GETIECSTATUS:
        PHA
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH

        LDA     #0              ; fn length
        LDX     #0
        LDY     #0
        JSR     SETNAM          ; setnam
        PLA
        TAX                     ; Device Number
        LDY     #15             ; secondary address
        LDA     #15             ; LFN NUMBER
        JSR     SETLFS          ;setlfs
        JSR     IECOPNLF
        LDX     #15
        JSR     IECINPC
GETIECSTATUS_1:
        JSR     IECREAD         ; input a byte from the serial bus
        JSR     OUTCH
        LDA     IECSTW          ; get serial status byte
        LSR                     ; shift time out read ..
        LSR                     ; .. into carry bit
        BCC     GETIECSTATUS_1  ; all ok, do another
        JSR     IECCLCH         ; close input and output channels
        LDA     #15
        JSR     IECCLSLF        ; close a specified logical file
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH
        RTS

GETIECDIRECTORY:
        PHA
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH

        LDA     #1              ; fn length
        LDX     #<FNPOINTER
        LDY     #>FNPOINTER
        JSR     SETNAM          ; setnam
        PLA
        TAX                     ; Device Number
        LDY     #0              ; secondary address
        LDA     #15             ; LFN NUMBER
        JSR     SETLFS          ;setlfs
        JSR     IECOPNLF
        LDX     #15
        JSR     IECINPC
;        Index16
;        LDY     #$6000
;        STY     $50F0
;        Index8
GETIECDIRECTORY_1:
        JSR     IECREAD         ; input a byte from the serial bus
        JSR     binhex
        JSR     space
        JSR     IECREAD         ; input a byte from the serial bus
        JSR     binhex
        JSR     space
        JSR     IECREAD         ; input a byte from the serial bus
        JSR     binhex
        JSR     space
        JSR     IECREAD         ; input a byte from the serial bus
        JSR     binhex
        JSR     space

        JSR     IECREAD         ; input SIZE LOW byte from the serial bus
        JSR     binhex
        JSR     space
        JSR     IECREAD         ; input SIZE HIGH byte from the serial bus
        JSR     binhex
        JSR     space

GETIECDIRECTORY_2:
        JSR     IECREAD         ; input ENTRY TEXT byte from the serial bus
        JSR     OUTCH
        CMP     #$00
        BEQ     GETIECDIRECTORY_3; END ENTRY
;       Index16
;       LDY     $50F0
;       STA     0,Y
;       INY
;       STY     $50F0
;       Index8
        LDA     IECSTW          ; get serial status byte
        LSR                     ; shift time out read ..
        LSR                     ; .. into carry bit
        BCC     GETIECDIRECTORY_2; all ok, do another
        JSR     IECCLCH         ; close input and output channels
        LDA     #15
        JSR     IECCLSLF        ; close a specified logical file
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH
        RTS
GETIECDIRECTORY_3:
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH
        JMP     GETIECDIRECTORY_1


space:
        LDA     #' '
        JSR     OUTCH
        RTS

FNPOINTER:
        .BYTE   '$'
FNPOINTER1:
        .BYTE   "notTEST"

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
        .BYTE   "Begin IEC Test Program"
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
        JSR     outch
        RESTORECONTEXT
        TXA
        JSR     outch
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

TMPPOINTER:
        .BYTE   0
        .END
