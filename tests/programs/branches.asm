; Every conditional branch, taken and not taken. Pushes 2 when the branch
; is taken and 1 when not.
         LDHZ SP 0x0F
         SEC
         BCS Taken1
         LDLZ R5 1
         JMP Push1
Taken1:  LDLZ R5 2
Push1:   PSH R5
         CLC
         BCS Taken2
         LDLZ R5 1
         JMP Push2
Taken2:  LDLZ R5 2
Push2:   PSH R5
         CLC
         BCC Taken3
         LDLZ R5 1
         JMP Push3
Taken3:  LDLZ R5 2
Push3:   PSH R5
         SEC
         BCC Taken4
         LDLZ R5 1
         JMP Push4
Taken4:  LDLZ R5 2
Push4:   PSH R5
         CMP R0 R0
         BZS Taken5
         LDLZ R5 1
         JMP Push5
Taken5:  LDLZ R5 2
Push5:   PSH R5
         LDLZ R0 1
         BZS Taken6
         LDLZ R5 1
         JMP Push6
Taken6:  LDLZ R5 2
Push6:   PSH R5
         LDLZ R0 1
         BZC Taken7
         LDLZ R5 1
         JMP Push7
Taken7:  LDLZ R5 2
Push7:   PSH R5
         CMP R0 R0
         BZC Taken8
         LDLZ R5 1
         JMP Push8
Taken8:  LDLZ R5 2
Push8:   PSH R5
         LDHZ R0 0x80
         BNS Taken9
         LDLZ R5 1
         JMP Push9
Taken9:  LDLZ R5 2
Push9:   PSH R5
         LDLZ R0 1
         BNS Taken10
         LDLZ R5 1
         JMP Push10
Taken10:  LDLZ R5 2
Push10:   PSH R5
         LDLZ R0 1
         BNC Taken11
         LDLZ R5 1
         JMP Push11
Taken11:  LDLZ R5 2
Push11:   PSH R5
         LDHZ R0 0x80
         BNC Taken12
         LDLZ R5 1
         JMP Push12
Taken12:  LDLZ R5 2
Push12:   PSH R5
         LDHZ R0 0x40
         ADD R0 R0 R0
         BOS Taken13
         LDLZ R5 1
         JMP Push13
Taken13:  LDLZ R5 2
Push13:   PSH R5
         LDLZ R0 1
         ADD R0 R0 R0
         BOS Taken14
         LDLZ R5 1
         JMP Push14
Taken14:  LDLZ R5 2
Push14:   PSH R5
         LDLZ R0 1
         ADD R0 R0 R0
         BOC Taken15
         LDLZ R5 1
         JMP Push15
Taken15:  LDLZ R5 2
Push15:   PSH R5
         LDHZ R0 0x40
         ADD R0 R0 R0
         BOC Taken16
         LDLZ R5 1
         JMP Push16
Taken16:  LDLZ R5 2
Push16:   PSH R5
         HLT
