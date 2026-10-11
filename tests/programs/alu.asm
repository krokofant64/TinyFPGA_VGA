; Runs every ALU, shift, and register load instruction on all pairs of
; test values (with carry clear and set where it matters) and pushes each
; result and the flags.
         LDHZ SP 0x0F        ; results go downwards from 0x0F00
         LDL R4 Values.L
         LDH R4 Values.H
         LDLZ R5 0           ; index of the first operand
Outer:   LDLZ R3 0           ; index of the second operand
Inner:   LD R0 R4
         ADD R0 R0 R5
         LD R0 [R0]          ; R0 = Values[R5]
         LD R1 R4
         ADD R1 R1 R3
         LD R1 [R1]          ; R1 = Values[R3]
         ADD R2 R0 R1
         PSH R2
         PSF
         CLC
         ADC R2 R0 R1
         PSH R2
         PSF
         SEC
         ADC R2 R0 R1
         PSH R2
         PSF
         SUB R2 R0 R1
         PSH R2
         PSF
         CLC
         SBC R2 R0 R1
         PSH R2
         PSF
         SEC
         SBC R2 R0 R1
         PSH R2
         PSF
         SEC
         AND R2 R0 R1
         PSH R2
         PSF
         CLC
         OR R2 R0 R1
         PSH R2
         PSF
         XOR R2 R0 R1
         PSH R2
         PSF
         NOT R2 R0
         PSH R2
         PSF
         INC R2 R0
         PSH R2
         PSF
         DEC R2 R0
         PSH R2
         PSF
         SHR R2 R0
         PSH R2
         PSF
         SHL R2 R0
         PSH R2
         PSF
         ASHR R2 R0
         PSH R2
         PSF
         CLC
         ROR R2 R0
         PSH R2
         PSF
         SEC
         ROR R2 R0
         PSH R2
         PSF
         CLC
         ROL R2 R0
         PSH R2
         PSF
         SEC
         ROL R2 R0
         PSH R2
         PSF
         LD R2 R0
         PSH R2
         PSF
         LDL R2 R1
         LDL R2 R0
         PSH R2
         PSF
         LDL R2 R1
         LDH R2 R0
         PSH R2
         PSF
         SWP R2 R0
         PSH R2
         PSF
         LDL R2 R1
         LDL R2 0x5A
         PSH R2
         PSF
         LDL R2 R1
         LDH R2 0xA5
         PSH R2
         PSF
         CMP R0 R1
         PSF
         INC R3 R3
         LDLZ R2 8
         CMP R3 R2
         BZS NextOuter
         JMP Inner
NextOuter: INC R5 R5
         CMP R5 R2
         BZS Done
         JMP Outer
Done:    HLT
Values:  .data 0x0000, 0x0001, 0x7FFF, 0x8000, 0x8001, 0xFFFF, 0x4000, 0xC0F3
