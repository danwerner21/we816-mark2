A 0700  LDX     #$0D
        LDA     #$00
        JSR     $DDA6
        LDX     #$00
        JSR     $DD95
        PHA
        LDX     #$01
        JSR    $DD95
        TAY
        plx
        BRK
