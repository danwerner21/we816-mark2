;__________________________________________________________
;
; BIOS JUMP TABLE (NATIVE)
;__________________________________________________________
LPRINTVEC       = $00FD00
LINPVEC         = $00FD04
LINPWVEC        = $00FD08
LSetXYVEC       = $00FD0C
LCPYVVEC        = $00FD10
LSrlUpVEC       = $00FD14
LSetColorVEC    = $00FD18
LCURSORVEC      = $00FD1C
LUNCURSORVEC    = $00FD20
LWRITERTC       = $00FD24
LREADRTC        = $00FD28
LIECIN          = $00FD2C
LIECOUT         = $00FD30
LUNTALK         = $00FD34
LUNLSTN         = $00FD38
LLISTEN         = $00FD3C
LTALK           = $00FD40
LSETLFS         = $00FD44
LSETNAM         = $00FD48
LLOAD           = $00FD4C
LSAVE           = $00FD50
LIECINIT        = $00FD54
LIECCLCH        = $00FD58       ; close input and output channels
LIECOUTC        = $00FD5C       ; open a channel for output
LIECINPC        = $00FD60       ; open a channel for input
LIECOPNLF       = $00FD64       ; open a logical file
LIECCLSLF       = $00FD68       ; close a specified logical file
LClearScrVec    = $00FD6C       ; clear the  Screen

CSRX            = $0330         ; CURRENT X POSITION
CSRY            = $0331         ; CURRENT Y POSITION
ConsoleDevice   = $0341         ; Current Console Device
CSRCHAR         = $0342         ; Character under the Cursor
VIDEOWIDTH      = $0343
DEFAULT_COLOR   = $0344         ; DEFAULT COLOR FOR PRINTING
TEMP            = $0345
TEMPOFFSET      = $0347

IECSTW          = $000317
IECMSGM         = $00031F       ; message mode flag,
; $C0 = both control and kernal messages,
; $80 = control messages only,
; $40 = kernal messages only,
; $00 = neither control or kernal messages
LOADBUFL        = $000322       ; IEC buffer Pointer
LOADBUFH        = LOADBUFL+1
LOADBANK        = LOADBUFL+2    ; BANK buffer Pointer
IECSTRTL        = $00031D       ; IEC Start Address Pointer
IECSTRTH        = IECSTRTL+1

VideoDisplayPage = $fe31
VideoCharGenOffset = $FE32
VideoCharGenData = $fe33
VideoTextMode   = $fe35
VideoLoresMode  = $fe36
VideoDoubleLores = $fe37
VideoHiresMode  = $fe38
VideoDoubleHires = $fe39
Video80col      = $fe3A
VideoMixedMode  = $fe3b
VideoQuadHires  = $fe3c
VideoMonoHires  = $fe3d


;__________________________________________________________




;___V_INPT_________________________________________________
;
; MAKE A BIOS CALL TO GET NON-BLOCKING CHARACTER INPUT
; THIS COULD BE SERIAL OR KEYBOARD DEPENDING ON BIOS SETTING
; RETURNS
;   A: CHARACTER
;      CARRY SET IF NO CHARACTER
;
;
;   NOTE THAT BIOS IS IN BANK 0, SO A LONG BRANCH IS REQUIRED
;__________________________________________________________
V_INPT:
        JSL     LINPVEC         ; INCHAR
        RTS

;___V_OUTP_________________________________________________
;
; MAKE A BIOS CALL TO SEND CHARACTER TO OUTPUT
; THIS COULD BE SERIAL OR TMS9918 CHARACTER DISPLAY
;
;   A: CHARACTER
;
;
;   NOTE THAT BIOS IS IN BANK 0, SO A LONG BRANCH IS REQUIRED
;__________________________________________________________

V_OUTP: ; send byte to output device
;        PHX
;        LDX     <VIDEOMODE
;        CPX     #0
;        BNE     V_OUTP1
        JSL     LPRINTVEC       ; OUTCHAR
;V_OUTP1:
;        PLX
        RTS


        .INCLUDE "diskcmds.asm"
        .INCLUDE "screencmds.asm"
        .INCLUDE "ay38910.asm"



;___TitleScreen_____________________________________________
;
; Basic Title Screen
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
TitleScreen:
        JSR     psginit

        LDA     #0
        STA     <VIDEOMODE

        LDA     f:ConsoleDevice
        CMP     #$00
        BNE     TitleScreen_1
        LDA     #<LAB_SMSG1     ; point to sign-on message (low addr)
        LDY     #>LAB_SMSG1     ; point to sign-on message (high addr)
        JSR     LAB_18C3        ; print null terminated string from memory
        RTS
TitleScreen_1:
        LDA     #$9E
        JSL     LSetColorVEC
        JSL     LClearScrVec
        LDA     #<LAB_CONMSG    ; point to sign-on message (low addr)
        LDY     #>LAB_CONMSG    ; point to sign-on message (high addr)
        JSR     LAB_18C3        ; print null terminated string from memory
        RTS

;___ScreenEditor____________________________________________
;
; Basic Screen editor code
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
ScreenEditor:
        PHA
        PHX
        PHY
        PHP
        PHB
        ACCUMULATORINDEX8
; allow prepopulate of screen
ploop:
        JSL     LCURSORVEC
        JSL     LINPWVEC
        CMP     #$FF
        BEQ     ploop
        JSL     LUNCURSORVEC
        CMP     #01
        BEQ     crsrup
        CMP     #02
        BEQ     crsrdn
        CMP     #$1f
        BEQ     crsrlt
        CMP     #$04
        LBEQ    crsrrt
        CMP     #$0A
        BEQ     ploop
        CMP     #13
        LBEQ    pexit

        JSL     LPRINTVEC
        JMP     ploop

crsrup:
        LDA     F:CSRY
        CMP     #00
        BEQ     ploop
        LDA     F:CSRY
        DEC     A
        STA     F:CSRY
        BRA     ploop
crsrdn:
        LDA     F:CSRY
        CMP     #23
        BEQ     crsrdn_1
        LDA     F:CSRY
        INC     A
        STA     F:CSRY
        BRA     ploop
crsrdn_1:
        LDA     F:CSRX
        PHA
        LDA     F:VIDEOWIDTH
        JSL     LSrlUpVEC
        PLA
        STA     F:CSRX
        BRA     ploop
crsrlt:
        LDA     F:CSRX
        CMP     #00
        BEQ     crsrlt_1
        LDA     F:CSRX
        DEC     A
        STA     F:CSRX
        JMP     ploop
crsrlt_1:
        LDA     F:CSRY
        CMP     #00
        LBEQ    ploop
        LDA     F:VIDEOWIDTH
        DEC     A
        STA     F:CSRX
        LDA     F:CSRY
        DEC     A
        STA     F:CSRY
        JMP     ploop
crsrrt:
        LDA     F:VIDEOWIDTH
        DEC     A
        CMP     F:CSRX
        BEQ     crsrrt_1
        LDA     F:CSRX
        INC     A
        STA     F:CSRX
        JMP     ploop
crsrrt_1:
        LDA     #00
        STA     F:CSRX
        BRA     crsrdn
pexit:
        JSR     LdKbBuffer
        LDX     #80
        LDA     #$00
        STA     f:LIbuffs,X
TERMLOOP:
        DEX
        LDA     f:LIbuffs,X
        CMP     #32
        BEQ     TERMLOOP_B
        CMP     #00
        BEQ     TERMLOOP_C
        BRA     TERMLOOP_A
TERMLOOP_B:
        LDA     #00
        STA     f:LIbuffs,X
TERMLOOP_C:
        CPX     #00
        BNE     TERMLOOP
TERMLOOP_A:
        LDA     #13
        JSL     LPRINTVEC
        PLB
        PLP
        PLY
        PLX
        PLA
        RTS


LdKbBuffer:
; clear input buffer
        LDX     #81
:
        LDA     #00
        STA     f:LIbuffs-1,X
        DEX
        BNE     :-

; Let's calculate the screen memory offset and store it
        JSR     GetVideoAddressOffset

        LDA     F:VIDEOWIDTH
        CMP     #40
        BEQ     :+
        JMP     LdKbBuffer_1c
:
; are we on the first line?  If so, we know it is not continued from the previous line
        LDA     F:CSRY
        TAY
        CPY     #$00
        BEQ     LdKbBuffer_1
; if prior line linked  set y-1
        ACCUMULATORINDEX16
        LDA     f:TEMPOFFSET
        TAX
        ACCUMULATOR8
        LDA     F:$0FFF,X
        INDEX8
        CMP     #$20
        BEQ     LdKbBuffer_1
        ACCUMULATOR16
        LDA     f:TEMPOFFSET
        SEC
        SBC     #40
        STA     f:TEMPOFFSET
        ACCUMULATOR8
        LDA     #81             ; get 80 chars
        BRA     LdKbBuffer_1b
; get chars; 40 if last line char=32, 80 if not

LdKbBuffer_1:
; is this the last line on the screen?
        CPY     #23
        BEQ     LdKbBuffer_1a
; if current line linked carries to the next set size to 80
        ACCUMULATORINDEX16
        LDA     f:TEMPOFFSET
        TAX
        ACCUMULATOR8
        LDA     F:$1027,X
        INDEX8
        CMP     #$20
        BEQ     LdKbBuffer_1a
LdKbBuffer_1c:
        LDA     #81             ; get 80 chars
        BRA     LdKbBuffer_1b
LdKbBuffer_1a:
        LDA     #41             ; get 40 chars
LdKbBuffer_1b:
        ACCUMULATORINDEX16
        AND     #$00FF
        TAY
        LDA     f:TEMPOFFSET
        TAX
        LDA     #$0000
        STA     <LOCALWORK
        ACCUMULATOR8
LdKbBuffer_2:
        LDA     f:$1000,X
        PHX
        LDX     <LOCALWORK
        STA     f:LIbuffs,X
        INX
        STX     <LOCALWORK
        PLX
        INX
        DEY
        CPY     #0000
        BNE     LdKbBuffer_2
        ACCUMULATORINDEX8
        RTS

.I8
.A8
GetVideoAddressOffset:
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
        STA     F:TEMPOFFSET
; if 80 columns double it.
        ACCUMULATOR8
        LDA     F:VIDEOWIDTH
        CMP     #40
        BEQ     :+
        ACCUMULATOR16
        LDA     F:TEMPOFFSET
        ASL     A
        STA     F:TEMPOFFSET
:
        ACCUMULATORINDEX8
        RTS



.I8
.A8
;___LAB_MONITOR_____________________________________________
;
; UTILIZE BIOS TO GO TO MONITOR
;
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_MONITOR:
        CLD                     ; VERIFY DECIMAL MODE IS OFF
        CLC                     ;
        XCE                     ; SET NATIVE MODE
        SETBANK 0
        ACCUMULATORINDEX16
        LDA     #STACK          ; get the stack address
        TCS                     ; and set the stack to it
        JML     $00E000
