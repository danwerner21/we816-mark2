.P816
;__ROMBIOS816_______________________________________________________________________________________
;
;	ROM BIOS FOR THE RBC 65c816 SBC - NATIVE MODE
;
;	WRITTEN BY: DAN WERNER -- 10/7/2017
;   Modified 8/10/2024 for WE816-MARK2
;
;__________________________________________________________________________________________________
;
; DATA CONSTANTS
;__________________________________________________________________________________________________

        .SEGMENT "ROM"

;__________________________________________________________________________________________________
; $8000-$8007 UART 16C550
;__________________________________________________________________________________________________
UART0           = $FE00         ;   DATA IN/OUT
UART1           = $FE01         ;   CHECK RX
UART2           = $FE02         ;   INTERRUPTS
UART3           = $FE03         ;   LINE CONTROL
UART4           = $FE04         ;   MODEM CONTROL
UART5           = $FE05         ;   LINE STATUS
UART6           = $FE06         ;   MODEM STATUS

RTCA            = $FE08         ;   RTC Address REGISTER.
RTC             = $FE09         ;   RTC Data REGISTER.

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


STACK           = $BFFF         ;   POINTER TO TOP OF STACK

;
KEYBUFF         = $0200         ; 256 BYTE KEYBOARD BUFFER
; NATIVE VECTORS
ICOPVECTOR      = $0300         ;COP handler indirect vector...
IBRKVECTOR      = $0302         ;BRK handler indirect vector...
IABTVECTOR      = $0304         ;ABT handler indirect vector...
INMIVECTOR      = $0306         ;NMI handler indirect vector...
IIRQVECTOR      = $0308         ;IRQ handler indirect vector...
; 6502 Emulation Vectors
IECOPVECTOR     = $030A         ;ECOP handler indirect vector...
IEABTVECTOR     = $030C         ;EABT handler indirect vector...
IENMIVECTOR     = $030E         ;ENMI handler indirect vector...
IEINTVECTOR     = $0310         ;EINT handler indirect vector...

;;; These are as yet unused
;------------------------------------------------------------------------------
IECDCF          = $0312         ; Serial output: deferred char flag
IECDC           = $0313         ; Serial deferred character
IECBCI          = $0314         ; Serial bit count/EOI flag
IECBTC          = $0315         ; Countdown, bit count
IECCYC          = $0316         ; Cycle count
IECSTW          = $0317         ; Status word
IECFNLN         = $0318         ; File Name Length
IECSECAD        = $0319         ; IEC Secondary Address
IECBUFFL        = $031A         ; low byte IEC buffer Pointer
IECBUFFH        = $031B         ; High byte IEC buffer Pointer
IECDEVN         = $031C         ; IEC Device Number
IECSTRTL        = $031D         ; low byte IEC Start Address Pointer
IECSTRTH        = $031E         ; High byte IEC Start Address Pointer
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
IECOPENF        = $0325         ; OPEN FILE COUNT
IECLFN          = $0326         ; IEC LOGICAL FILE NUMBER
IECIDN          = $0327         ; input device number
IECODN          = $0328         ; output device number
;------------------------------------------------------------------------------

; VIDEO/KEYBOARD PARAMETER AREA

CSRX            = $0330         ; CURRENT X POSITION
CSRY            = $0331         ; CURRENT Y POSITION
LEDS            = $0332
KeyLock         = $0333
ScannedKey      = $0334
ScrollCount     = $0335         ;
TEMP            = $0336         ; TEMP AREA

ConsoleDevice   = $0341         ; Current Console Device
                                ; $00 Serial, $01 On-Board 9918/KB
CSRCHAR         = $0342         ; Character under the Cursor
VIDEOWIDTH      = $0343         ; SCREEN WIDTH -- 32 or 40 (80 in the future)
DEFAULT_COLOR   = $0344         ; DEFAULT COLOR FOR PRINTING

; Tables
PTRLFT          = $03B0         ; .. to $03B9 logical file table
PTRDNT          = $03BA         ; .. to $03C3 device number table
PTRSAT          = $03C4         ; .. to $03CD secondary address table
LINEFLGS        = $03D0         ; 24 BYTES OF LINE POINTERS (3D0 - 3E9 , one extra for scrolling)


TRUE            = 1
FALSE           = 0

KBD_DELAY       = 64            ; keyboard delay in MS.   Set higher if keys bounce, set lower if keyboard feels slow

        .INCLUDE "macros.asm"

; CHOOSE ONE CONSOLE IO DEVICE

        .ORG    $C000

;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________
COLD_START:
        CLD                     ; VERIFY DECIMAL MODE IS OFF

        CLC                     ;
        XCE                     ; SET NATIVE MODE
        ACCUMULATORINDEX16
        LDA     #STACK          ; get the stack address
        TCS                     ; and set the stack to it

        LDA     #INTRETURN      ;
        STA     ICOPVECTOR
        STA     IBRKVECTOR
        STA     IABTVECTOR
        STA     INMIVECTOR
        STA     IIRQVECTOR
        STA     IECOPVECTOR
        STA     IEABTVECTOR
        STA     IENMIVECTOR
        STA     IEINTVECTOR

        ACCUMULATORINDEX8
        JSR     CONSOLE_INIT    ; Init UART
        JSR     INITIEC        ; Init IEC port
;       JSR     BATEST         ; Perform Basic Assurance Test

;       JML     $FF1000         ; START BASIC
        JMP     mon


RCOPVECTOR:
        JMP     (ICOPVECTOR)
RBRKVECTOR:
        JMP     (IBRKVECTOR)
RABTVECTOR:
        JMP     (IABTVECTOR)
RNMIVECTOR:
        JMP     (INMIVECTOR)
RIRQVECTOR:
        JMP     (IIRQVECTOR)
RECOPVECTOR:
        JMP     (IECOPVECTOR)
REABTVECTOR:
        JMP     (IEABTVECTOR)
RENMIVECTOR:
        JMP     (IENMIVECTOR)
REINTVECTOR:
        JMP     (IEINTVECTOR)

        .INCLUDE "supermon816.asm"

;__INTRETURN____________________________________________________
;
; Handle Interrupts
;
;_______________________________________________________________
;
INTRETURN:
        RTI                     ;

;__BATEST_______________________________________________________
;
; Perform Basic Hardware Assurance Test
;
;_______________________________________________________________
;
BATEST:
        RTS



;__CONSOLE_INIT_________________________________________________
;
; Initialize Attached Console Devices
;
;_______________________________________________________________
;
CONSOLE_INIT:
        PHP
        ACCUMULATORINDEX8

        JSR     SERIAL_CONSOLE_INIT
        JSR     SETUPVIDEO
        LDA     #$0F
        JSR     SetColor
        JSR     ClearScreen
        LDA     #$00
        STA     ConsoleDevice
        JSR     INITKEYBOARD

        PLP
        RTS


;__OUTCH_______________________________________________________
;
; OUTPUT CHAR IN LOW BYTE OF ACC TO CONSOLE
;
; Current Console Device stored in ConsoleDevice
;
; 0=Serial
; 1=On Board 9918/KB
;______________________________________________________________
OUTCH:
        PHX
        PHY
        PHP
        ACCUMULATORINDEX8
        TAX
        LDA     F:ConsoleDevice
        CMP     #$01
        BNE     OUTCH2
        TXA
        JSR     OutVideoCh
        PLP
        PLY
        PLX
        RTS

; Default (serial)
OUTCH2:
        TXA
        JSR     SERIAL_OUTCH
        PLP
        PLY
        PLX
        RTS


;__INCHW_______________________________________________________
;
; INPUT CHAR FROM CONSOLE TO ACC  (WAIT FOR CHAR)
;
;______________________________________________________________
INCHW:
        PHX
        PHY
        PHP
        ACCUMULATORINDEX8

        LDA     F:ConsoleDevice
        CMP     #$01
        BNE     INCHW2
        JSR     GetKey
        PLP
        PLY
        PLX
        RTS

; Default (serial)
INCHW2:
        JSR     SERIAL_INCHW
        PLP
        PLY
        PLX
        RTS


;__INCH________________________________________________________
;
; INPUT CHAR FROM CONSOLE TO ACC
;
;______________________________________________________________
INCH:
        PHX
        PHY
        PHP
        ACCUMULATORINDEX8

        LDA     F:ConsoleDevice
        CMP     #$01
        BNE     INCH2

        JSR     ScanKeyboard
        CMP     #$FF
        BEQ     INCH2S
        JSR     GetKey
        BRA     INCH2C

; Default (serial)
INCH2:
        JSR     SERIAL_INCH
        BCS     INCH2S


INCH2C:
        PLP
        PLY
        PLX
        CLC
        RTS
INCH2S:
        PLP
        PLY
        PLX
        SEC
        RTS

DONOOP:
nothere:
        RTS


;__Device_Driver_Code___________________________________________
;
        .INCLUDE "conserial.asm"
        .INCLUDE "conlocal.asm"
        .INCLUDE "iec.asm"
        .INCLUDE "rtc.asm"
;______________________________________________________________


        .BYTE   00,00,00

        .SEGMENT "NJUMP"
; BIOS JUMP TABLE (NATIVE)
        .ORG    $FD00
LPRINTVEC:
        JSR     OUTCH
        RTL
LINPVEC:
        JSR     INCH
        RTL
LINPWVEC:
        JSR     INCHW
        RTL
LSetXYVEC:
        JSR     SetXY
        RTL
LCPYVVEC:
        JSR     DONOOP
        RTL
LSrlUpVEC:
        JSR     ScrollUp
        RTL
LSetColorVEC:
        JSR     SetColor
        RTL
LCURSORVEC:
        JSR     CURSOR
        RTL
LUNCURSORVEC:
        JSR     UNCURSOR
        RTL
LWRITERTC:
        JSR     RTCWRITE
        RTL
LREADRTC:
        JSR     RTCREAD
        RTL
LIECIN:
        JSR     LAB_EF19        ;. Read byte from serial bus. (Must call TALK and TALKSA beforehands.)
        RTL
LIECOUT:
        JSR     LAB_EEE4        ;. Write byte to serial bus. (Must call LISTEN and LSTNSA beforehands.)
        RTL
LUNTALK:
        JSR     LAB_EEF6        ;. Send UNTALK command to serial bus.
        RTL
LUNLSTN:
        JSR     LAB_EF04        ;. Send UNLISTEN command to serial bus.
        RTL
LLISTEN:
        JSR     LAB_EE17        ;. Send LISTEN command to serial bus.
        RTL
LTALK:
        JSR     LAB_EE14        ;. Send TALK command to serial bus.
        RTL
LSETLFS:
        JSR     LAB_FE50        ;. Set file parameters.
        RTL
LSETNAM:
        JSR     LAB_FE49        ;. Set file name parameters.
        RTL
LLOAD:
        JSR     LOADTORAM       ;. Load or verify file. (Must call SETLFS and SETNAM beforehands.)
        RTL
LSAVE:
        JSR     IECSAVERAM      ;. Save file. (Must call SETLFS and SETNAM beforehands.)
        RTL
LIECINIT:
        JSR     INITIEC         ; INIT IEC
        RTL
LIECCLCH:
        JSR     LAB_F3F3        ; close input and output channels
        RTL
LIECOUTC:
        JSR     LAB_F309        ; open a channel for output
        RTL
LIECINPC:
        JSR     LAB_F2C7        ; open a channel for input
        RTL
LIECOPNLF:
        JSR     LAB_F40A        ; open a logical file
        RTL
LIECCLSLF:
        JSR     LAB_F34A        ; close a specified logical file
        RTL
LClearScrVec:
        JSR     ClearScreen     ; clear the 9918 Screen
        RTL
LLOADFONTVec:
        JSR     DONOOP          ; LOAD THE FONT
        RTL

        .SEGMENT "EJUMP"
; BIOS JUMP TABLE (Emulation)
        .ORG    $FF71
PRINTVEC:
        JMP     OUTCH
INPVEC:
        JMP     INCH
INPWVEC:
        JMP     INCHW
SetXYVEC:
        JMP     SetXY
CPYVVEC:
        JMP     DONOOP
SrlUpVEC:
        JMP     ScrollUp
SetColorVEC:
        JMP     SetColor
CURSORVEC:
        JMP     CURSOR
UNCURSORVEC:
        JMP     UNCURSOR
WRITERTC:
        JMP     RTCWRITE
READRTC:
        JMP     RTCREAD
IECIN:
        JMP     LAB_EF19        ; Read byte from serial bus. (Must call TALK and TALKSA beforehands.)
IECOUT:
        JMP     LAB_EEE4        ; Write byte to serial bus. (Must call LISTEN and LSTNSA beforehands.)
UNTALK:
        JMP     LAB_EEF6        ; Send UNTALK command to serial bus.
UNLSTN:
        JMP     LAB_EF04        ; Send UNLISTEN command to serial bus.
LISTEN:
        JMP     LAB_EE17        ; Send LISTEN command to serial bus.
TALK:
        JMP     LAB_EE14        ; Send TALK command to serial bus.
SETLFS:
        JMP     LAB_FE50        ; Set file parameters.
SETNAM:
        JMP     LAB_FE49        ; Set file name parameters.
LOAD:
        JMP     LOADTORAM       ; Load or verify file. (Must call SETLFS and SETNAM beforehands.)
SAVE:
        JMP     IECSAVERAM      ; Save file. (Must call SETLFS and SETNAM beforehands.)
IECINIT:
        JMP     INITIEC         ; INIT IEC
IECCLCH:
        JMP     LAB_F3F3        ; close input and output channels
IECOUTC:
        JMP     LAB_F309        ; open a channel for output
IECINPC:
        JMP     LAB_F2C7        ; open a channel for input
IECOPNLF:
        JMP     LAB_F40A        ; open a logical file
IECCLSLF:
        JMP     LAB_F34A        ; close a specified logical file
ClearScrVec:
        JMP     ClearScreen     ; clear the 9918 Screen
LOADFONTVec:
        JMP     DONOOP          ; LOAD THE FONT

        .SEGMENT "VECTORS"
; 65c816 Native Vectors
        .ORG    $FFE4
COPVECTOR:
        .WORD   RCOPVECTOR
BRKVECTOR:
        .WORD   RBRKVECTOR
ABTVECTOR:
        .WORD   RABTVECTOR
NMIVECTOR:
        .WORD   RNMIVECTOR
resv1:
        .WORD   $0000           ;
IRQVECTOR:
        .WORD   RIRQVECTOR      ; ROM VECTOR FOR IRQ

        .WORD   $0000           ;
        .WORD   $0000           ;

; 6502 Emulation Vectors
        .ORG    $FFF4
ECOPVECTOR:
        .WORD   RECOPVECTOR
resv2:
        .WORD   $0000
EABTVECTOR:
        .WORD   REABTVECTOR
ENMIVECTOR:
        .WORD   RENMIVECTOR
RSTVECTOR:
        .WORD   COLD_START      ;
EINTVECTOR:
        .WORD   REINTVECTOR     ; ROM VECTOR FOR IRQ

        .END
