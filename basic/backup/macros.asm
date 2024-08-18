;___________________________________________________________________________________________________
;
;	USEFUL 65186 MACROS
;__________________________________________________________________________________________________

.macro       STORECONTEXT             ; Store Complete Context at the beginning of a Sub
        PHX
        phy
        pha
        php
.endmacro

.macro       RESTORECONTEXT                 ; Restore Complete Context at the end of a Sub
        plp
        pla
        ply
        plx
.endmacro

.macro       INDEX16                         ; Set 16bit Index Registers
		REP #$10 		; 16 bit Index registers
		.I16
.endmacro
.macro       INDEX8                          ; Set 8bit Index Registers
		SEP #$10 		; 8 bit Index registers
		.I8
.endmacro

.macro       ACCUMULATOR16                  ; Set 16bit Index Registers
		REP #$20 		; 16 bit Index registers
		.A16
.endmacro

.macro       ACCUMULATOR8                   ; Set 8bit Index Registers
		SEP #$20 		; 8 bit Index registers
		.A8
.endmacro

.macro       ACCUMULATORINDEX16             ; Set 16bit Index Registers
		REP #$30 		; 16 bit Index registers
		.A16
                .I16
.endmacro

.macro       ACCUMULATORINDEX8              ; Set 8bit Index Registers
		SEP #$30 		; 8 bit Index registers
		.A8
                .I8
.endmacro

.macro       LDAINDIRECTY PARM1
    PHB
	PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
	LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLB
    LDA <TMPFLG
.endmacro

.macro       STAINDIRECTY PARM1
    PHB
	PHX
    PHA
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLA
    PLX
	STA	(<PARM1),Y		;
	PLB
    STA <TMPFLG
.endmacro

.macro       SETBANK PARM1
    PHX
	LDX #PARM1
	PHX
	PLB
    PLX
.endmacro


.macro       FETCHINDIRECTY PARM1
    PHB
	PHA
    PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
    LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLA
    PLB
.endmacro

.macro       CMPINDIRECTY PARM1
    PHB
    PHA
    PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
    LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLA
    PLB
    CMP	<TMPFLG		    ;
.endmacro

.macro       ADCINDIRECTY PARM1
    PHB
    PHA
    PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
    LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLA
    PLB
    CLC
    ADC	<TMPFLG 		;
.endmacro

.macro       LBEQ PARM1
     bne *+5
     jmp PARM1
.endmacro

.macro       LBNE PARM1
     beq *+5
     jmp PARM1
.endmacro

.macro       LBCC PARM1
     bcc *+4
     bra *+5
     jmp PARM1
.endmacro

.macro       LBCS PARM1
     bcs *+4
     bra *+5
     jmp PARM1
.endmacro
