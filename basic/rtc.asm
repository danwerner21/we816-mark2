.P816

;___LAB_IECST_______________________________________________
;
; RETURN SYSTEM SECONDS
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_SECOND:
        PHB
        PHX
        PHP
        ACCUMULATORINDEX8
        LDX     #$0D
        LDA     #$00
        JSL     LWRITERTC        ; Set Mode
        LDX     #$00
        JSL     LREADRTC         ; Get ones digit
        PHA
        LDX     #$01
        JSL     LREADRTC         ; Get tens digit
        CLC
        ASL     A
        PHA
        ASL     A
        ASL     A
        STA     F:TEMP
        PLA
        CLC
        ADC     F:TEMP
        STA     F:TEMP
        PLA
        CLC
        ADC     F:TEMP
        TAY
        LDA     #0              ; Get high byte
        PLP
        PLX
        PLB
        JSR     LAB_AYFC
        RTS
LAB_PSECOND:
        LSR     <Dtypef         ; clear data type flag, $FF=string, $00=numeric
        JSL     LAB_IGBY        ; increment and scan memory then do function
        RTS