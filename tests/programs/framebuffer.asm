; Writes 512 frame buffer words and reads them back; counts mismatches in R5.
; The read loop takes an odd number of clocks, so the reads happen at all
; positions of the video's character fetch cycle.
         LDLZ R5 0           ; error count
         LDLZ R4 0x5A
         LDH  R4 0x5A        ; R4 = 0x5A5A
         LDHZ R1 0x80        ; R1 = 0x8000
         LDHZ R3 0x82        ; R3 = 0x8200
WrLoop:  XOR R2 R1 R4
         STO R2 [R1]
         INC R1 R1
         CMP R1 R3
         BCS WrLoop
         LDHZ R1 0x80
RdLoop:  LD R2 [R1]
         XOR R2 R2 R4
         CMP R2 R1
         BZC Err
Next:    INC R1 R1
         CMP R1 R3
         BCS RdLoop
         HLT
Err:     INC R5 R5
         JMP Next
