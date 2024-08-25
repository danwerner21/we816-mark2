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
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        PHX
        JSR     LAB_1C01        ; (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X (DEVICE)
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
        JSR     LAB_GTBY        ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        TXA
        AND     #$0F
        PHA
        JSR     LAB_1C01        ; (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X (DEVICE)
        TXA
        AND     #$0F
        CLC
        ASL
        ASL
        ASL
        ASL
        STA     <TMPFLG
        PLA
        ORA     <TMPFLG
        PHB
        SETBANK 0
        JSL     LSetColorVEC
        PLB
        RTS

;___V_SPEEK()______________________________________________
;
; GET VALUE FROM SCREEN MEMORY
;
;  TAKES ONE PARAMETER (ADDRESS), RETURNS VALUE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPEEK:
        JSR     LAB_F2FX        ; save integer part of FAC1 in temporary integer

        PHB
        SETBANK 0
        LDA     Itempl
        PLB
        TAY                     ; copy byte to Y
        JMP     LAB_1FD0        ; convert Y to byte in FAC1 and return


;___V_SPOKE_________________________________________________
;
; PUT VALUE IN SCREEN MEMORY
;
;  TAKES TWO PARAMETERS ADDRESS,VALUE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPOKE:
        JSR     LAB_GADB        ; get two parameters for POKE or WAIT
        PHB
        SETBANK 0
        STX     Itempl
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
;  1=MONO HIRES
;  HIRES MODE THIRD PARAMETER
;  0=MIXED MODE
;  1=FULL SCREEN MODE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SCREEN:
        RTS
;;;;; SOME OF THESE ARE OK IN DIRECT MODE -- WILL WANT THIS LATER THOUGH        JSR     LAB_CKRN        ; check not Direct, back here if ok
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

SETUPMODE0:
        LDA     #$01
        STA     F:VideoTextMode
        LDA     #$02
        STA     F:VideoLoresMode
        STA     F:VideoHiresMode
        JSR     LAB_1C01        ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR     LAB_GTBY        ; GET THE SECOND PARAMETER, RETURN IN X (PATTERN)
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

SETUPMODE1:
SETUPMODE2:
        RTS

;___V_SPRITE________________________________________________
;
;  SET SPRITE PARAMETERS
;
;  TAKES SIX PARAMETERS
;       SPRITE NUM (0-32)
;       SPRITE PATTERN (0-255)
;       X CORD (0-255)
;       Y CORD (0-255)
;       COLOR  (0-15)
;       LEFT SHIFT BIT (0/1)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPRITE:
        RTS


;___V_SPRDEF________________________________________________
;
;  DEFINE SPRITE PATTERN
;
;  TAKES 9 OR 17 PARAMETERS
;       SPRITE NUM (0-32)
;       SPRITE PATTERN DATA (8 BYTES OR 16 BYTES)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPRDEF:
        RTS


;___LAB_VIDST_______________________________________________
;
; RETURN VIDEO STATUS BYTE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_VIDST:
LAB_PVIDST:
        RTS


;___SPRSIZE_________________________________________________
;
; SET SPRITE SIZE AND MAGNIFICATION
;
;  TAKES ONE PARAMETER
;
; 0= 8X8 SPRITES, 1x DISPLAY
; 1= 8X8 SPRITES, 2X DISPLAY
; 2= 16X16 SPRITES, 1X DISPLAY
; 3= 16X16 SPRITES, 2X DISPLAY
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPRSIZE:
        RTS



;___V_PLOT__________________________________________________
;
;  PLOT ON SCREEN
;         VM= 1     TAKES THREE PARAMETERS,  X,Y,COLOR
;         VM= 4     TAKES FOUR PARAMETERS,  X,Y,PRIORITY,COLOR
;         VM= 0 AND 3     TAKES THREE PARAMETERS,  X,Y,PATTERN
;
;  0=GRAPHICS MODE (32X24)
;  1=MULTICOLOR MODE (64X48 BLOCKS)
;  2=TEXT MODE (40X24)
;  3=GRAPHICS MODE 0, WITH MODE 2 COLOR (32X24 MULTICOLOR)
;  4=GRAPHICS MODE 2 (32X24 MULTICOLOR)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PLOT:
        RTS


;___V_PATTERN________________________________________________
;
;  DEFINE GGRAPHICS PATTERN
;
;  TAKES 10 PARAMETERS
;       PATTERN NUM (0-255)
;       COLOR NUM (0-255)
;       PATTERN DATA (8 BYTES)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PATTERN:
        RTS
