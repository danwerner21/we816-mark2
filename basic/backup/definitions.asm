PROGRAMBANK     = $FF           ; BANK THAT THE INTREPRETER LIVES IN
DATABANK        = $02           ; BANK THAT THE DATA LIVES IN

FNBUFFER        = $000F00       ; FILE NAME BUFFER, MUST BE IN ZERO BANK!



; offsets from a base of X or Y

PLUS_0          = $00           ; X or Y plus 0
PLUS_1          = $01           ; X or Y plus 1
PLUS_2          = $02           ; X or Y plus 2
PLUS_3          = $03           ; X or Y plus 3

STACK_BOTTOM    = $B000         ; stack bottom, no offset
STACK           = $BFFF         ; stack top, no offset

ccflag          = $000200       ; BASIC CTRL-C flag, 00 = enabled, 01 = dis
ccbyte          = ccflag+1      ; BASIC CTRL-C byte
ccnull          = ccbyte+1      ; BASIC CTRL-C byte timeout

VEC_CC          = ccnull+1      ; ctrl c check vector


; Ibuffs can now be anywhere in RAM AS LONG AS IT IS BEFORE RAM_BASE AND IS NOT PAGE ALIGNED!, ensure that the max length is < $80

        .IF     PROGRAMBANK=DATABANK
Ibuffs              = (ENDOFBASIC&$FF00)+$181
        .ELSE
Ibuffs              = $2000+$181
LIbuffs             = (DATABANK*$10000)+$2000+$181
        .ENDIF
Ibuffe          = Ibuffs+80     ; end of input buffer

Ram_base        = ((Ibuffe+1)&$FF00)+$100; start of user RAM (set as needed, should be page aligned)
Ram_top         = $FF00         ; end of user RAM+1 (set as needed, should be page aligned)
