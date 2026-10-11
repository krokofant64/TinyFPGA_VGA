; Loads and stores with positive and negative offsets, relative to a
; register and to PC, the stack, and jumps and subroutines.
         LDHZ SP 0x0F
         LDHZ R1 0x02        ; R1 = 0x0200
         LDLZ R0 0x11
         STO R0 [R1]         ; 0x0200 = 0x0011
         LDLZ R0 0x22
         STO R0 [R1 +63]     ; 0x023F = 0x0022
         LDLZ R0 0x33
         STO R0 [R1 -64]     ; 0x01C0 = 0x0033
         LD R2 [R1 +63]
         PSH R2
         LD R2 [R1 -64]
         PSH R2
         LD R2 Data          ; PC relative
         PSH R2
         LDLZ R0 0x44
         STO R0 Data
         LD R2 Data
         PSH R2
         ; Nested subroutines
         LDLZ R3 0
         JSR Sub1
         PSH R3
         ; Jump through a register
         LDL R0 Target.L
         LDH R0 Target.H
         JMP [R0]
         LDLZ R3 0x7F        ; skipped
Target:  PSH R3
         ; Jump with an offset to a register
         LDL R0 Target.L
         LDH R0 Target.H
         JMP [R0 +Target2-Target]
         LDLZ R3 0x7E        ; skipped
Target2: PSH R3
         ; Pop into all registers
         POP R0
         POP R1
         POP R2
         PSH R0
         PSH R1
         PSH R2
         HLT
Sub1:    INC R3 R3
         PSH R3
         JSR Sub2
         INC R3 R3
         POP R4              ; R4 = value pushed above
         RET
Sub2:    SHL R3 R3
         SHL R3 R3
         RET
Data:    .data 0x1234
