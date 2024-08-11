.P816
;__SCRM816_________________________________________________________________________________________
;
;	SCREAM FOR THE WE816 MARK2
;
;	WRITTEN BY: DAN WERNER -- 8/9/2024
;
;__________________________________________________________________________________________________
;
; DATA CONSTANTS
;__________________________________________________________________________________________________

;        CHIP    65816           ; SET CHIP
;        LONGA   OFF             ; ASSUME EMULATION MODE
;        LONGI   OFF             ;
;        PW      128
;        PL      60
;        INCLIST ON

        .SEGMENT "ROM"

IO_AREA         = $FE00
;__________________________________________________________________________________________________
; $8000-$8007 UART 16C550
;__________________________________________________________________________________________________
UART0           = IO_AREA+$00   ;   DATA IN/OUT
UART1           = IO_AREA+$01   ;   CHECK RX
UART2           = IO_AREA+$02   ;   INTERRUPTS
UART3           = IO_AREA+$03   ;   LINE CONTROL
UART4           = IO_AREA+$04   ;   MODEM CONTROL
UART5           = IO_AREA+$05   ;   LINE STATUS
UART6           = IO_AREA+$06   ;   MODEM STATUS
UART7           = IO_AREA+$07   ;   SCRATCH REG.



        .SEGMENT "ROM"
        .ORG    $E000

;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________
COLD_START:
        SEI                     ;  Disable Interrupts
        CLD                     ;  VERIFY DECIMAL MODE IS OFF

        LDA     #$80            ;
        STA     UART3           ; SET DLAB FLAG
        LDA     #12             ; SET TO 12 = 9600 BAUD
        STA     UART0           ;
        LDA     #00             ;
        STA     UART1           ;
        LDA     #03             ;
        STA     UART3           ; SET 8 BIT DATA, 1 STOPBIT
        STA     UART4           ; SET 8 BIT DATA, 1 STOPBIT


        LDX     #$00
TX:
        LDA     UART5           ; READ LINE STATUS REGISTER
        AND     #$20            ; TEST IF UART IS READY TO SEND (BIT 5)
        CMP     #$00
        BEQ     TX              ; IF NOT REPEAT

;        LDA     #'A'
        TXA
        STA     $0100
        LDA     $0100
        STA     UART0           ; THEN WRITE THE CHAR TO UART
        INX
        JMP     TX

        BRK                     ; PERFORM BRK (START MONITOR)


        .SEGMENT "VECTORS"
; 65c816 Native Vectors
        .ORG    $FFE4
COPVECTOR:
        .WORD   COLD_START
BRKVECTOR:
        .WORD   COLD_START
ABTVECTOR:
        .WORD   COLD_START
NMIVECTOR:
        .WORD   COLD_START
resv1:
        .WORD   COLD_START
IRQVECTOR:
        .WORD   COLD_START


        .WORD   $0000,$0000


; 6502 Emulation Vectors
        .ORG    $FFF4
ECOPVECTOR:
        .WORD   COLD_START
resv2:
        .WORD   COLD_START
EABTVECTOR:
        .WORD   COLD_START
ENMIVECTOR:
        .WORD   COLD_START
RSTVECTOR:
        .WORD   COLD_START      ;
EINTVECTOR:
        .WORD   COLD_START

        .END
