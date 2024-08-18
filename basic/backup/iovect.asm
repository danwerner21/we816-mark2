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
LIECCLCH        = $00FD58    ; close input and output channels
LIECOUTC        = $00FD5C    ; open a channel for output
LIECINPC        = $00FD60    ; open a channel for input
LIECOPNLF       = $00FD64    ; open a logical file
LIECCLSLF       = $00FD68    ; close a specified logical file
LClearScrVec    = $00FD6C    ; clear the 9918 Screen
LLOADFONTVec    = $00FD70    ; load the 9918 font


CSRX            = $0330      ; CURRENT X POSITION
CSRY            = $0331      ; CURRENT Y POSITION
ConsoleDevice   = $0341      ; Current Console Device
VIDEOWIDTH      = $0343
SpriteAttrs     = $0344
SpritePatterns  = $0345
IECSTW          = $000317
IECMSGM         = $00031F    ; message mode flag,
; $C0 = both control and kernal messages,
; $80 = control messages only,
; $40 = kernal messages only,
; $00 = neither control or kernal messages
LOADBUFL        = $000322    ; IEC buffer Pointer
LOADBUFH        = LOADBUFL+1
LOADBANK        = LOADBUFL+2 ; BANK buffer Pointer
IECSTRTL        = $00031D    ; IEC Start Address Pointer
IECSTRTH        = IECSTRTL+1
LINEFLGS        = $03D0      ; 24 BYTES OF LINE POINTERS (3D0 - 3E9 , one extra for scrolling)

CMDP           = $FE0B      ; 	VDP COMMAND port
DATAP          = $FE0A      ; 	VDP Data port

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
        PHB
        PHD
        PHX
        LDX     #$00
        PHX
        PLB
        JSL     LINPVEC         ; INCHAR
        PLX
        PLD
        PLB
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
        PHB
        PHD
        PHX
        LDX     <VIDEOMODE
        CPX     #2
        BNE     V_OUTP1
        LDX     #$00
        PHX
        PLB
        JSL     LPRINTVEC       ; OUTCHAR
V_OUTP1:
        PLX
        PLD
        PLB
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
        LDA     #40
        STA     >VIDEOWIDTH
        LDA     #2
        STA     <VIDEOMODE
        LDA     >ConsoleDevice
        CMP     #$00
        BNE     TitleScreen_1
        LDA     #<LAB_SMSG1     ; point to sign-on message (low addr)
        LDY     #>LAB_SMSG1     ; point to sign-on message (high addr)
        JSR     LAB_18C3        ; print null terminated string from memory
        RTS
TitleScreen_1:
        LDX     #02
        JSR     V_SCREEN1
        PHB
        SETBANK 0
        LDA     #$F4
        JSL     LSetColorVEC
        LDX     #$00
        TXY
        JSL     LSetXYVEC
        PLB
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
        ACCUMULATORINDEX8
        PHB
        SETBANK 0
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
        BEQ     crsrrt
        PHA
        JSL     LPRINTVEC
        PLA
        CMP     #13
        BEQ     pexit
        JMP     ploop

crsrup:
        LDA     CSRY
        CMP     #00
        BEQ     ploop
        DEC     CSRY
        BRA     ploop
crsrdn:
        LDA     CSRY
        CMP     #23
        BEQ     crsrdn_1
        INC     CSRY
        BRA     ploop
crsrdn_1:
        LDA     CSRX
        PHA
        LDA     #40
        LDX     #0
        LDY     #23
        STX     CSRX
        STY     CSRY
        JSL     LSrlUpVEC
        PLA
        STA     CSRX
        BRA     ploop
crsrlt:
        LDA     CSRX
        CMP     #00
        BEQ     crsrlt_1
        DEC     CSRX
        JMP     ploop
crsrlt_1:
        LDA     CSRY
        CMP     #00
        BEQ     ploop
        LDA     #39
        STA     CSRX
        DEC     CSRY
        JMP     ploop
crsrrt:
        LDA     CSRX
        CMP     #39
        BEQ     crsrrt_1
        INC     CSRX
        JMP     ploop
crsrrt_1:
        LDA     #00
        STA     CSRX
        BRA     crsrdn
pexit:
        JSR     LdKbBuffer

        LDX     #81
        LDA     #$00
        STA     >LIbuffs,X
TERMLOOP:
        DEX
        LDA     >LIbuffs,X
        CMP     #32
        BEQ     TERMLOOP_B
        CMP     #00
        BEQ     TERMLOOP_C
        BRA     TERMLOOP_A
TERMLOOP_B:
        LDA     #00
        STA     >LIbuffs,X
TERMLOOP_C:
        CPX     #00
        BNE     TERMLOOP
TERMLOOP_A:

        PLB
        PLP
        PLY
        PLX
        PLA
        RTS


LdKbBuffer:
        LDA     CSRX
        PHA
        LDA     CSRY
        PHA
; clear input buffer
        LDX     #81
clloop:
        LDA     #00
        STA     >LIbuffs-1,X
        DEX
        BNE     clloop

; are we on the first line?  If so, we know it is not a continue
        LDY     CSRY
        DEY
        CPY     #$00
        BEQ     LdKbBuffer_1
; if prior line linked  set y-1
        TYX
        LDA     LINEFLGS,X
        CMP     #$00
        BEQ     LdKbBuffer_1
        DEY
        LDA     #81             ; get 80 chars
        BRA     LdKbBuffer_1b
; get chars; 40 if last line char=32, 80 if not

LdKbBuffer_1:
; is this the last line on the screen?
        CPY     #23
        BEQ     LdKbBuffer_1a
; if current line linked carries to the next set size to 80
        TYX
        LDA     LINEFLGS+1,X
        CMP     #$00
        BEQ     LdKbBuffer_1a
        PLA
        INC     A
        PHA
        LDA     #81             ; get 80 chars
        BRA     LdKbBuffer_1b
LdKbBuffer_1a:
        LDA     #41             ; get 40 chars
LdKbBuffer_1b:
        LDX     #0
        JSL     LSetXYVEC
        TAY
LdKbBuffer_2:
        JSR     DELAY9918
        LDA     DATAP
        STA     >LIbuffs-1,X
        INX
        DEY
        CPY     #00
        BNE     LdKbBuffer_2
        PLY
        STY     CSRY
        PLA
        STA     CSRX
        CPY     #24
        BNE     LdKbBuffer_3
        DEY
        STY     CSRY
        LDA     #40
        JSL     LSrlUpVEC
LdKbBuffer_3:
        RTS

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
        JML     $008000
