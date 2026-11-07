; ROM library, called from assembler. Arguments 1 and 2 are in R0 and R1, the
; others are pushed by the caller, last argument first.

            LDHZ SP 0x0F

            ; R2, R4, and R5 keep their values in all calls
            LDLZ R2 0x22
            LDLZ R4 0x44
            LDLZ R5 0x55

            ; ClearScreen(' ', blue background, white text)
            LDLZ R0 32
            LDHZ R1 0x0F
            LDL R3 $ClearScreen.L
            LDH R3 $ClearScreen.H
            JSR [R3]

            ; PrintAt(3, 4, Text)
            LDL R0 Text.L
            LDH R0 Text.H
            PSH R0
            LDLZ R0 3
            LDLZ R1 4
            LDL R3 $PrintAt.L
            LDH R3 $PrintAt.H
            JSR [R3]
            INC SP SP

            ; PrintHex(Sqrt(40000))
            LDL R0 40000.L
            LDH R0 40000.H
            LDL R3 $Sqrt.L
            LDH R3 $Sqrt.H
            JSR [R3]
            LDL R3 $PrintHex.L
            LDH R3 $PrintHex.H
            JSR [R3]

            ; R0 = RtUDiv(1000, 7), R1 = remainder
            LDL R0 1000.L
            LDH R0 1000.H
            LDLZ R1 7
            LDL R3 $RtUDiv.L
            LDH R3 $RtUDiv.H
            JSR [R3]

            ; DrawLine(0, 30, 79, 59, 3)
            LDLZ R0 3
            PSH R0
            LDLZ R0 59
            PSH R0
            LDLZ R0 79
            PSH R0
            LDLZ R0 0
            LDLZ R1 30
            LDL R3 $DrawLine.L
            LDH R3 $DrawLine.H
            JSR [R3]
            INC SP SP
            INC SP SP
            INC SP SP

            HLT

Text:       .cstring "From assembler: "
