;____________________________________________________________________________________________
;
; ZERO PAGE DEFINITIONS
;____________________________________________________________________________________________

LAB_WARM        = $00        ; BASIC warm start entry point
Wrmjpl          = LAB_WARM+1 ; BASIC warm start vector jump low byte
Wrmjph          = LAB_WARM+2 ; BASIC warm start vector jump high byte
TMPFLG          = $04
VIDEOMODE       = $06
LOCALWORK       = $07        ; word (2 bytes)
Usrjmp          = $0A        ; USR function JMP address
Usrjpl          = <Usrjmp+1  ; USR function JMP vector low byte
Usrjph          = <Usrjmp+2  ; USR function JMP vector high byte
Nullct          = $0D        ; nulls output after each line
TPos            = $0E        ; BASIC terminal position byte
TWidth          = $0F        ; BASIC terminal width byte
Iclim           = $10        ; input column limit
Itempl          = $11        ; temporary integer low byte
Itemph          = <Itempl+1  ; temporary integer high byte

nums_1          = <Itempl    ; number to bin/hex string convert MSB
nums_2          = <nums_1+1  ; number to bin/hex string convert
nums_3          = <nums_1+2  ; number to bin/hex string convert LSB

Srchc           = $5B        ; search character
Temp3           = <Srchc     ; temp byte used in number routines
Scnquo          = $5C        ; scan-between-quotes flag
Asrch           = <Scnquo    ; alt search character

XOAw_l          = <Srchc     ; eXclusive OR, OR and AND word low byte
XOAw_h          = <Scnquo    ; eXclusive OR, OR and AND word high byte

Ibptr           = $5D        ; input buffer pointer
Dimcnt          = <Ibptr     ; # of dimensions
Tindx           = <Ibptr     ; token index

Defdim          = $5E        ; default DIM flag
Dtypef          = $5F        ; data type flag, $FF=string, $00=numeric
Oquote          = $60        ; open quote flag (b7) (Flag: DATA scan; LIST quote; memory)
Gclctd          = $60        ; garbage collected flag
Sufnxf          = $61        ; subscript/FNX flag, 1xxx xxx = FN(0xxx xxx)
Imode           = $62        ; input mode flag, $00=INPUT, $80=READ
Cflag           = $63        ; comparison evaluation flag

TabSiz          = $64        ; TAB step size (was input flag)

next_s          = $65        ; next descriptor stack address
; these two bytes form a word pointer to the item
; currently on top of the descriptor stack
last_sl         = $66        ; last descriptor stack address low byte
last_sh         = $67        ; last descriptor stack address high byte (always $00)

des_sk          = $68        ; descriptor stack start address (temp strings)

;			= $70		; End of descriptor stack

ut1_pl          = $71        ; utility pointer 1 low byte
ut1_ph          = <ut1_pl+1  ; utility pointer 1 high byte
ut2_pl          = $73        ; utility pointer 2 low byte
ut2_ph          = <ut2_pl+1  ; utility pointer 2 high byte

Temp_2          = <ut1_pl    ; temp byte for block move

FACt_1          = $75        ; FAC temp mantissa1
FACt_2          = <FACt_1+1  ; FAC temp mantissa2
FACt_3          = <FACt_2+1  ; FAC temp mantissa3

dims_l          = <FACt_2    ; array dimension size low byte
dims_h          = <FACt_3    ; array dimension size high byte

TempB           = $78        ; temp page 0 byte

Smeml           = $79        ; start of mem low byte		(Start-of-Basic)
Smemh           = <Smeml+1   ; start of mem high byte	(Start-of-Basic)
Svarl           = $7B        ; start of vars low byte	(Start-of-Variables)
Svarh           = <Svarl+1   ; start of vars high byte	(Start-of-Variables)
Sarryl          = $7D        ; var mem end low byte		(Start-of-Arrays)
Sarryh          = <Sarryl+1  ; var mem end high byte		(Start-of-Arrays)
Earryl          = $7F        ; array mem end low byte	(End-of-Arrays)
Earryh          = <Earryl+1  ; array mem end high byte	(End-of-Arrays)
Sstorl          = $81        ; string storage low byte	(String storage (moving down))
Sstorh          = <Sstorl+1  ; string storage high byte	(String storage (moving down))
Sutill          = $83        ; string utility ptr low byte
Sutilh          = <Sutill+1  ; string utility ptr high byte
Ememl           = $85        ; end of mem low byte		(Limit-of-memory)
Ememh           = <Ememl+1   ; end of mem high byte		(Limit-of-memory)

Clinel          = $87        ; current line low byte		(Basic line number)
Clineh          = <Clinel+1  ; current line high byte	(Basic line number)
Blinel          = $89        ; break line low byte		(Previous Basic line number)
Blineh          = <Blinel+1  ; break line high byte		(Previous Basic line number)

Cpntrl          = $8B        ; continue pointer low byte
Cpntrh          = <Cpntrl+1  ; continue pointer high byte

Dlinel          = $8D        ; current DATA line low byte
Dlineh          = <Dlinel+1  ; current DATA line high byte

Dptrl           = $8F        ; DATA pointer low byte
Dptrh           = <Dptrl+1   ; DATA pointer high byte

Rdptrl          = $91        ; read pointer low byte
Rdptrh          = <Rdptrl+1  ; read pointer high byte

Varnm1          = $93        ; current var name 1st byte
Varnm2          = <Varnm1+1  ; current var name 2nd byte

Cvaral          = $95        ; current var address low byte
Cvarah          = <Cvaral+1  ; current var address high byte

Frnxtl          = $97        ; var pointer for FOR/NEXT low byte
Frnxth          = <Frnxtl+1  ; var pointer for FOR/NEXT high byte

Tidx1           = <Frnxtl    ; temp line index

Lvarpl          = <Frnxtl    ; let var pointer low byte
Lvarph          = <Frnxth    ; let var pointer high byte

prstk           = $99        ; precedence stacked flag

comp_f          = $9B        ; compare function flag, bits 0,1 and 2 used
; bit 2 set if >
; bit 1 set if =
; bit 0 set if <

func_l          = $9C        ; function pointer low byte
func_h          = <func_l+1  ; function pointer high byte

garb_l          = <func_l    ; garbage collection working pointer low byte
garb_h          = <func_h    ; garbage collection working pointer high byte

des_2l          = $9E        ; string descriptor_2 pointer low byte
des_2h          = <des_2l+1  ; string descriptor_2 pointer high byte

g_step          = $A0        ; garbage collect step size

Fnxjmp          = $A1        ; jump vector for functions
Fnxjpl          = <Fnxjmp+1  ; functions jump vector low byte
Fnxjph          = <Fnxjmp+2  ; functions jump vector high byte

g_indx          = <Fnxjpl    ; garbage collect temp index

FAC2_r          = $A3        ; FAC2 rounding byte

Adatal          = $A4        ; array data pointer low byte
Adatah          = <Adatal+1  ; array data pointer high  byte

Nbendl          = <Adatal    ; new block end pointer low byte
Nbendh          = <Adatah    ; new block end pointer high  byte

Obendl          = $A6        ; old block end pointer low byte
Obendh          = <Obendl+1  ; old block end pointer high  byte

numexp          = $A8        ; string to float number exponent count
expcnt          = $A9        ; string to float exponent count

numbit          = <numexp    ; bit count for array element calculations

numdpf          = $AA        ; string to float decimal point flag
expneg          = $AB        ; string to float eval exponent -ve flag

Astrtl          = <numdpf    ; array start pointer low byte
Astrth          = <expneg    ; array start pointer high  byte

Histrl          = <numdpf    ; highest string low byte
Histrh          = <expneg    ; highest string high  byte

Baslnl          = <numdpf    ; BASIC search line pointer low byte
Baslnh          = <expneg    ; BASIC search line pointer high  byte

Fvar_l          = <numdpf    ; find/found variable pointer low byte
Fvar_h          = <expneg    ; find/found variable pointer high  byte

Ostrtl          = <numdpf    ; old block start pointer low byte
Ostrth          = <expneg    ; old block start pointer high  byte

Vrschl          = <numdpf    ; variable search pointer low byte
Vrschh          = <expneg    ; variable search pointer high  byte

FAC1_e          = $AC        ; FAC1 exponent
FAC1_1          = <FAC1_e+1  ; FAC1 mantissa1
FAC1_2          = <FAC1_e+2  ; FAC1 mantissa2
FAC1_3          = <FAC1_e+3  ; FAC1 mantissa3
FAC1_s          = <FAC1_e+4  ; FAC1 sign (b7)

str_ln          = <FAC1_e    ; string length
str_pl          = <FAC1_1    ; string pointer low byte
str_ph          = <FAC1_2    ; string pointer high byte

des_pl          = <FAC1_2    ; string descriptor pointer low byte
des_ph          = <FAC1_3    ; string descriptor pointer high byte

mids_l          = <FAC1_3    ; MID$ string temp length byte

negnum          = $B1        ; string to float eval -ve flag
numcon          = $B1        ; series evaluation constant count

FAC1_o          = $B2        ; FAC1 overflow byte

FAC2_e          = $B3        ; FAC2 exponent
FAC2_1          = <FAC2_e+1  ; FAC2 mantissa1
FAC2_2          = <FAC2_e+2  ; FAC2 mantissa2
FAC2_3          = <FAC2_e+3  ; FAC2 mantissa3
FAC2_s          = <FAC2_e+4  ; FAC2 sign (b7)

FAC_sc          = $B8        ; FAC sign comparison, Acc#1 vs #2
FAC1_r          = $B9        ; FAC1 rounding byte

ssptr_l         = <FAC_sc    ; string start pointer low byte
ssptr_h         = <FAC1_r    ; string start pointer high byte

sdescr          = <FAC_sc    ; string descriptor pointer

csidx           = $BA        ; line crunch save index
Asptl           = <csidx     ; array size/pointer low byte
Aspth           = $BB        ; array size/pointer high byte

Btmpl           = <Asptl     ; BASIC pointer temp low byte
Btmph           = <Aspth     ; BASIC pointer temp low byte

Cptrl           = <Asptl     ; BASIC pointer temp low byte
Cptrh           = <Aspth     ; BASIC pointer temp low byte

Sendl           = <Asptl     ; BASIC pointer temp low byte
Sendh           = <Aspth     ; BASIC pointer temp low byte

LAB_IGBY        = $BC        ; get next BASIC byte subroutine

LAB_GBYT        = $C2        ; get current BASIC byte subroutine
Bpntrl          = $C3        ; BASIC execute (get byte) pointer low byte
Bpntrh          = <Bpntrl+1  ; BASIC execute (get byte) pointer high byte
Bpntrp          = <Bpntrl+2  ; BASIC execute (get byte) pointer PAGE byte

;			= $E0		; end of get BASIC char subroutine

Rbyte4          = $E1        ; extra PRNG byte
Rbyte1          = <Rbyte4+1  ; most significant PRNG byte
Rbyte2          = <Rbyte4+2  ; middle PRNG byte
Rbyte3          = <Rbyte4+3  ; least significant PRNG byte

NmiBase         = $E5        ; NMI handler enabled/setup/triggered flags
; bit	function
; ===	========
; 7	interrupt enabled
; 6	interrupt setup
; 5	interrupt happened
;			= $E6		; NMI handler addr low byte
;			= $E7		; NMI handler addr high byte
IrqBase         = $E8        ; IRQ handler enabled/setup/triggered flags
;			= $E9		; IRQ handler addr low byte
;			= $EA		; IRQ handler addr high byte
FCBPTR          = $EB        ; POINTER TO FCB FOR FILE OPS

Decss           = $EF        ; number to decimal string start
Decssp1         = Decss+1    ; number to decimal string start

TEMPW           = $FD
;			= $FF		; decimal string end


;____________________________________________________________________________________________
;
; character get subroutine for zero page

; For a 1.8432MHz 6502 including the JSR and RTS
; fastest (>=":")	=  29 cycles =  15.7uS
; slowest (<":")	=  40 cycles =  21.7uS
; space skip	= +21 cycles = +11.4uS
; inc across page	=  +4 cycles =  +2.2uS

; the target address for the LDA at LAB_2CF4 becomes the BASIC execute pointer once the
; block is copied to it's destination, any non zero page address will do at assembly
; time, to assemble a three byte instruction.

; page 0 initialisation table from $BC
; increment and scan memory
;____________________________________________________________________________________________

LAB_2CEE:
        INC     <Bpntrl         ; increment BASIC execute pointer low byte
        BNE     LAB_2CF4        ; branch if no carry
; else
        INC     <Bpntrh         ; increment BASIC execute pointer high byte

; page 0 initialisation table from $C2
; scan memory
LAB_2CF4:
        LDA     $FFFFFF         ; get byte to scan (addr set by call routine)
        CMP     #TK_ELSE        ; compare with the token for ELSE
        BEQ     LAB_2D05        ; exit if ELSE, not numeric, carry set

        CMP     #':'            ; compare with ":"
        BCS     LAB_2D05        ; exit if >= ":", not numeric, carry set

        CMP     #' '            ; compare with " "
        BEQ     LAB_2CEE        ; if " " go do next

        SEC                     ; set carry for SBC
        SBC     #'0'            ; subtract "0"
        SEC                     ; set carry for SBC
        SBC     #$D0            ; subtract -"0"
; clear carry if byte = "0"-"9"
LAB_2D05:
        RTL
LAB_2CEE_END:
;____________________________________________________________________________________________
;
; page zero initialisation table $00-$12 inclusive
;____________________________________________________________________________________________

StrTab:
        .BYTE   $4C             ; JMP opcode
        .WORD   LAB_COLD        ; initial warm start vector (cold start)

        .BYTE   $00             ; these bytes are not used by BASIC
        .WORD   $0000           ;
        .WORD   $0000           ;
        .WORD   $0000           ;

        .BYTE   $4C             ; JMP opcode
        .WORD   LAB_FCER        ; initial user function vector ("Function call" error)
        .BYTE   $00             ; default NULL count
        .BYTE   $00             ; clear terminal position
        .BYTE   $00             ; default terminal width byte
        .BYTE   $F2             ; default limit for TAB = 14
        .WORD   Ram_base        ; start of user RAM
EndTab:

;  BASIC start-up code

PG2_TABS:
        .BYTE   $00             ; ctrl-c flag		-	$00 = enabled
        .BYTE   $03             ; ctrl-c byte		-	GET needs this
        .BYTE   $00             ; ctrl-c byte timeout	-	GET needs this
        .WORD   CTRLC           ; ctrl c check vector
PG2_TABE:
