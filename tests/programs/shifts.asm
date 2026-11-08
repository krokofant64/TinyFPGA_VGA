; Shift and rotate instructions with every count 1 .. 8, INC and DEC with
; every step 1 .. 8, and RTI. Each test value is used with carry clear and
; set; every result and the flags are pushed.
         LDHZ SP 0x0F        ; results go downwards from 0x0F00
         LDL R0 Isr.L        ; an interrupt changes nothing
         LDH R0 Isr.H
         LDL R1 0x0FFF.L
         LDH R1 0x0FFF.H
         STO R0 [R1]
         LDL R4 Values.L
         LDH R4 Values.H
         LDLZ R5 12          ; number of values
Next:    LD R0 [R4]
         CLC
         SHR R1 R0 1
         PSH R1
         PSF
         CLC
         SHR R1 R0 2
         PSH R1
         PSF
         CLC
         SHR R1 R0 3
         PSH R1
         PSF
         CLC
         SHR R1 R0 4
         PSH R1
         PSF
         CLC
         SHR R1 R0 5
         PSH R1
         PSF
         CLC
         SHR R1 R0 6
         PSH R1
         PSF
         CLC
         SHR R1 R0 7
         PSH R1
         PSF
         CLC
         SHR R1 R0 8
         PSH R1
         PSF
         CLC
         SHL R1 R0 1
         PSH R1
         PSF
         CLC
         SHL R1 R0 2
         PSH R1
         PSF
         CLC
         SHL R1 R0 3
         PSH R1
         PSF
         CLC
         SHL R1 R0 4
         PSH R1
         PSF
         CLC
         SHL R1 R0 5
         PSH R1
         PSF
         CLC
         SHL R1 R0 6
         PSH R1
         PSF
         CLC
         SHL R1 R0 7
         PSH R1
         PSF
         CLC
         SHL R1 R0 8
         PSH R1
         PSF
         CLC
         ASHR R1 R0 1
         PSH R1
         PSF
         CLC
         ASHR R1 R0 2
         PSH R1
         PSF
         CLC
         ASHR R1 R0 3
         PSH R1
         PSF
         CLC
         ASHR R1 R0 4
         PSH R1
         PSF
         CLC
         ASHR R1 R0 5
         PSH R1
         PSF
         CLC
         ASHR R1 R0 6
         PSH R1
         PSF
         CLC
         ASHR R1 R0 7
         PSH R1
         PSF
         CLC
         ASHR R1 R0 8
         PSH R1
         PSF
         CLC
         ROR R1 R0 1
         PSH R1
         PSF
         CLC
         ROR R1 R0 2
         PSH R1
         PSF
         CLC
         ROR R1 R0 3
         PSH R1
         PSF
         CLC
         ROR R1 R0 4
         PSH R1
         PSF
         CLC
         ROR R1 R0 5
         PSH R1
         PSF
         CLC
         ROR R1 R0 6
         PSH R1
         PSF
         CLC
         ROR R1 R0 7
         PSH R1
         PSF
         CLC
         ROR R1 R0 8
         PSH R1
         PSF
         CLC
         ROL R1 R0 1
         PSH R1
         PSF
         CLC
         ROL R1 R0 2
         PSH R1
         PSF
         CLC
         ROL R1 R0 3
         PSH R1
         PSF
         CLC
         ROL R1 R0 4
         PSH R1
         PSF
         CLC
         ROL R1 R0 5
         PSH R1
         PSF
         CLC
         ROL R1 R0 6
         PSH R1
         PSF
         CLC
         ROL R1 R0 7
         PSH R1
         PSF
         CLC
         ROL R1 R0 8
         PSH R1
         PSF
         SEC
         SHR R1 R0 1
         PSH R1
         PSF
         SEC
         SHR R1 R0 2
         PSH R1
         PSF
         SEC
         SHR R1 R0 3
         PSH R1
         PSF
         SEC
         SHR R1 R0 4
         PSH R1
         PSF
         SEC
         SHR R1 R0 5
         PSH R1
         PSF
         SEC
         SHR R1 R0 6
         PSH R1
         PSF
         SEC
         SHR R1 R0 7
         PSH R1
         PSF
         SEC
         SHR R1 R0 8
         PSH R1
         PSF
         SEC
         SHL R1 R0 1
         PSH R1
         PSF
         SEC
         SHL R1 R0 2
         PSH R1
         PSF
         SEC
         SHL R1 R0 3
         PSH R1
         PSF
         SEC
         SHL R1 R0 4
         PSH R1
         PSF
         SEC
         SHL R1 R0 5
         PSH R1
         PSF
         SEC
         SHL R1 R0 6
         PSH R1
         PSF
         SEC
         SHL R1 R0 7
         PSH R1
         PSF
         SEC
         SHL R1 R0 8
         PSH R1
         PSF
         SEC
         ASHR R1 R0 1
         PSH R1
         PSF
         SEC
         ASHR R1 R0 2
         PSH R1
         PSF
         SEC
         ASHR R1 R0 3
         PSH R1
         PSF
         SEC
         ASHR R1 R0 4
         PSH R1
         PSF
         SEC
         ASHR R1 R0 5
         PSH R1
         PSF
         SEC
         ASHR R1 R0 6
         PSH R1
         PSF
         SEC
         ASHR R1 R0 7
         PSH R1
         PSF
         SEC
         ASHR R1 R0 8
         PSH R1
         PSF
         SEC
         ROR R1 R0 1
         PSH R1
         PSF
         SEC
         ROR R1 R0 2
         PSH R1
         PSF
         SEC
         ROR R1 R0 3
         PSH R1
         PSF
         SEC
         ROR R1 R0 4
         PSH R1
         PSF
         SEC
         ROR R1 R0 5
         PSH R1
         PSF
         SEC
         ROR R1 R0 6
         PSH R1
         PSF
         SEC
         ROR R1 R0 7
         PSH R1
         PSF
         SEC
         ROR R1 R0 8
         PSH R1
         PSF
         SEC
         ROL R1 R0 1
         PSH R1
         PSF
         SEC
         ROL R1 R0 2
         PSH R1
         PSF
         SEC
         ROL R1 R0 3
         PSH R1
         PSF
         SEC
         ROL R1 R0 4
         PSH R1
         PSF
         SEC
         ROL R1 R0 5
         PSH R1
         PSF
         SEC
         ROL R1 R0 6
         PSH R1
         PSF
         SEC
         ROL R1 R0 7
         PSH R1
         PSF
         SEC
         ROL R1 R0 8
         PSH R1
         PSF
         INC R1 R0 1
         PSH R1
         PSF
         INC R1 R0 2
         PSH R1
         PSF
         INC R1 R0 3
         PSH R1
         PSF
         INC R1 R0 4
         PSH R1
         PSF
         INC R1 R0 5
         PSH R1
         PSF
         INC R1 R0 6
         PSH R1
         PSF
         INC R1 R0 7
         PSH R1
         PSF
         INC R1 R0 8
         PSH R1
         PSF
         DEC R1 R0 1
         PSH R1
         PSF
         DEC R1 R0 2
         PSH R1
         PSF
         DEC R1 R0 3
         PSH R1
         PSF
         DEC R1 R0 4
         PSH R1
         PSF
         DEC R1 R0 5
         PSH R1
         PSF
         DEC R1 R0 6
         PSH R1
         PSF
         DEC R1 R0 7
         PSH R1
         PSF
         DEC R1 R0 8
         PSH R1
         PSF
         INC R4 R4
         DEC R5 R5
         BZS Done
         JMP Next
; RTI returns like RET, keeps the flags (RET sets Z and N), and enables
; interrupts
Done:    LDL R0 AfterRti.L
         LDH R0 AfterRti.H
         PSH R0
         LDHZ R1 0x80
         SEC
         CMP R1 R1           ; Z = 1, N = 0, C = 0
         LDHZ R1 0x80        ; N = 1, Z = 0
         RTI
         HLT                 ; not reached
AfterRti: PSF
         CLI
         HLT
Isr:     RTI
Values:  .data 0x0000, 0x0001, 0x8000, 0xFFFF, 0x1234, 0xA5C3
         .data 0x7F01, 0x00FF, 0xFF00, 0x5555, 0xAAAA, 0x8001
