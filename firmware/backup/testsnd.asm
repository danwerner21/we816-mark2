.P816
.A8
.I8
;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	AY-3-8910 Sound Test Program                                        **
;**	Author: Rich Cini -- 11/26/2020	                                    **
;**                                                                         **
;**	Translation of similar test program by Wayne Warthen for the Z80    **
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
via1regb        = $FE10         ; Register
via1rega        = $FE11         ; Register
via1ddrb        = $FE12         ; Register
via1ddra        = $FE13         ; Register
via1t1cl        = $FE14         ; Register
via1t1ch        = $FE15         ; Register
via1t1ll        = $FE16         ; Register
via1t1lh        = $FE17         ; Register
via1t2cl        = $FE18         ; Register
via1t2ch        = $FE19         ; Register
via1sr          = $FE1A         ; Register
via1acr         = $FE1B         ; Register
via1pcr         = $FE1C         ; Register
via1ifr         = $FE1D         ; Register
via1ier         = $FE1E         ; Register
via1ora         = $FE1F         ; Register

;
; CPU speed for delay scaling
;
cpuspd          = 4             ; CPU speed in MHz
;
; BIOS JUMP TABLE
;
PRINTVEC        = $FF71
;
;=============================================================================
; Code Section
;=============================================================================
;
        .ORG    $0200

        .BYTE   "816"
;load address
;	.DB     $0B,$40,0,0
        .BYTE   <Start,>Start,0,0

;execute address
;	.DB     $0B,$40,0,0
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
        JSR     psginit
        JSR     tttpsg
        JSR     clrpsg
lp1:
        LDA     #$00            ; start with channel 0
        STA     chan            ; init channel number

chloop:
; Test each channel
        JSR     tstchan         ; test the current channel
        LDA     chan            ; get current channel
        INA                     ; bump to next
        STA     chan            ; save it
        CMP     #$03            ; end of channels?
        BMI     chloop          ; loop if not done
Exit:
        CLC                     ; SET THE CPU TO NATIVE MODE
        XCE
        BRK


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


tstchan:
        LDA     #$00
        STA     pitch
        STA     pitch+1

        LDA     #$07
        LDY     #$f8
        JSR     psgwr

        LDA     #$0D
        LDY     #$18
        JSR     psgwr

; Setup mixer register

mixloop:
        LDA     chan
        LDY     pitch
        JSR     psgwr
        LDA     chan
        INA
        LDY     pitch+1
        JSR     psgwr

        ACCUMULATOR16
        LDA     pitch
        INA
        STA     pitch
        CMP     #$1000
        BEQ     MIXOUT
        ACCUMULATOR8


        LDA     chan
        CLC
        ADC     #$08
        LDY     #$0f
        JSR     psgwr


; Delay
;	ld	b,cpuspd	; cpu speed scalar
        LDY     cpuspd
dlyloop:
;	call	dly64		; arbitrary delay
;	djnz	dlyloop		; loop based on cpu speed
        JSR     dly256
        DEY
        BNE     dlyloop

        BRA     mixloop
MIXOUT:

        JSR     clrpsg
        RTS


;
; Clear PSG registers to default
;
clrpsg:
        PHX
        PHY
        LDX     #00
        LDY     #00

clrpsg1:
        TXA
        JSR     psgwr           ; set register X to 0
        INX
        CPX     #17
        BNE     clrpsg1
        PLY
        PLX
        RTS

;
; Program PSG registers from list at HL
;
setpsg:
        PHX
        PHY
        JSR     psginit
        LDX     #$0
setpsg_lp:
;	ld	a,(hl)		; get psg reg number
;	inc	hl		; bump index
;	cp	$FF		; check for end
;	ret	z		; return if end marker $FF
;	out	(rsel),a	; select psg register
;	ld	a,(hl)		; get register value
;	inc	hl		; bump index
;	out	(rdat),a	; set register value
;	jr	setpsg		; loop till done
        LDA     regno,x
        CMP     #$FF
        BEQ     setpsg1
        PHA
        INX
        LDA     regno,x
        TAY
        INX
        PLA
        JSR     psgwr
        JMP     setpsg_lp
setpsg1:
        PLY
        PLX
        RTS



;
; test PSG registers to default
;
tttpsg:
        LDX     #00

tttpsg1:
        TXA
        TXY
        JSR     psgwr           ; set register X to 0
        INX
        CPX     #17
        BNE     tttpsg1

        LDX     #00
tttpsg2:
        TXA
        JSR     psgrd           ; set register X to 0
        TYA
        JSR     binhex
        LDA     #' '
        JSR     PRINTVEC
        INX
        CPX     #17
        BNE     tttpsg2
        RTS



;
; Short delay functions.  No clock speed compensation, so they
; will run longer on slower systems.  The number indicates the
; number of call/ret invocations.  A single call/ret is
; 27 t-states on a z80, 25 t-states on a z180
;
dly256:
        JSR     dly128
dly128:
        JSR     dly64
dly64:
        JSR     dly32
dly32:
        JSR     dly16
dly16:
        JSR     dly8
dly8:
        JSR     dly4
dly4:
        JSR     dly2
dly2:
        JSR     dly1
dly1:
        RTS


psginit:
        PHA
        LDA     #%00011100
        STA     via1ddra
        LDA     #%00010000
        STA     via1rega
        LDA     #$FF
        STA     via1ddrb
        LDA     #$00
        STA     via1regb
        PLA
        RTS

psgrd:
        STA     via1regb        ; select register
        PHA
        LDA     #%00011100      ; latch address
        STA     via1rega

        STA     via1rega
        STA     via1rega
        STA     via1rega
        STA     via1rega

        LDA     #%00010000      ; inact
        STA     via1rega

        STA     via1rega
        STA     via1rega

        LDA     #$00
        STA     via1ddrb
        LDA     #%00011000      ; latch data
        STA     via1rega

        STA     via1rega
        STA     via1rega
        STA     via1rega
        STA     via1rega

        LDY     via1regb        ; get data
        LDA     #$FF
        STA     via1ddrb
        LDA     #%00010000      ; inact
        STA     via1rega
        PLA
        RTS


psgwr:
        STA     via1regb        ; select register
        PHA
        LDA     #%00011100      ; latch address
        STA     via1rega

        STA     via1rega
        STA     via1rega
        STA     via1rega
        STA     via1rega

        LDA     #%00010000      ; inact
        STA     via1rega

        STA     via1rega
        STA     via1rega
        STA     via1rega
        STA     via1rega

        STY     via1regb        ; store data

        STY     via1regb        ; store data
        STY     via1regb        ; store data
        STY     via1regb        ; store data
        STY     via1regb        ; store data

        LDA     #%00010100      ; latch data
        STA     via1rega

        STA     via1rega
        STA     via1rega
        STA     via1rega
        STA     via1rega

        LDA     #%00010000      ; inact
        STA     via1rega
        PLA
        RTS


;_Text Strings and Data____________________________________________________________________________________________________
;
HELLO:
        .BYTE   $0A, $0D        ; line feed and carriage return
        .BYTE   $0A, $0D        ; line feed and carriage return
        .BYTE   "Begin SCG Test Program"
        .BYTE   $0A, $0D, 00    ; line feed and carriage return

chan:
        .BYTE   0               ; active audio channel
pitch:
        .WORD   0               ; current pitch
regno:
        .BYTE   0               ; register number
lasta           = regno+1
;_________________________________________________________________________________________________________________________


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
        PHA
        PHX
        PHY
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
        PHA
        PHX
        PHY
        JSR     PRINTVEC
        PLY
        PLX
        PLA
        TXA
        JSR     PRINTVEC
        PLY
        PLX
        PLA
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
