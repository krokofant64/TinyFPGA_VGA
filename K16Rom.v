`ifndef K16ROM_V
`define K16ROM_V

module K16Rom (addr, clk, dout);// 512x16
  parameter addr_width = 9;
  parameter data_width = 16;
  input [addr_width-1:0] addr;
  input clk;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout; // Register for output.
  reg [data_width-1:0] rom [(1<<addr_width)-1:0];
  always @(posedge clk)
    begin
      dout <= rom[addr]; // Output register controlled by clock.
    end
  initial
    begin
    // .org 0xF000
    // ;------------------------------------------------------------------------------
    // ; Sleep
    // ; [in]  R0 = time to sleep [ms]
    // ;------------------------------------------------------------------------------
rom[0] = 16'h240c; // Sleep:         PSH R1
rom[1] = 16'h280c; //                PSH R2
rom[2] = 16'h2c0c; //                PSH R3
rom[3] = 16'h6857; //                LDL R2 25175.L
rom[4] = 16'h6962; //                LDH R2 25175.H
rom[5] = 16'hbc2f; //                JSR Multiply
rom[6] = 16'h6cfe; //                LDL R3 $IoCntrLo.L
rom[7] = 16'h6dff; //                LDH R3 $IoCntrLo.H
rom[8] = 16'hcd80; //                LD R3 [R3]
rom[9] = 16'h0930; //                ADD R2 R2 R3
rom[10] = 16'h6cfd; //                LDL R3 $IoCntrHi.L
rom[11] = 16'h6dff; //                LDH R3 $IoCntrHi.H
rom[12] = 16'hcd80; //                LD R3 [R3]
rom[13] = 16'h04b1; //                ADC R1 R1 R3
rom[14] = 16'h4796; //                BCC SleepLoop2
    //                ; Counter overflow.
    //                ; Store previous counter value (R4 R5)
rom[15] = 16'h300c; //                PSH R4
rom[16] = 16'h340c; //                PSH R5
rom[17] = 16'h6cfd; //                LDL R3 $IoCntrHi.L
rom[18] = 16'h6dff; //                LDH R3 $IoCntrHi.H
rom[19] = 16'hd180; //                LD R4 [R3]
rom[20] = 16'h6cfe; //                LDL R3 $IoCntrLo.L
rom[21] = 16'h6dff; //                LDH R3 $IoCntrLo.H
rom[22] = 16'hd580; //                LD R5 [R3]
rom[23] = 16'h6cfd; //                LDL R3 $IoCntrHi.L
rom[24] = 16'h6dff; //                LDH R3 $IoCntrHi.H
rom[25] = 16'hcd80; //                LD R3 [R3]
rom[26] = 16'h01ce; //                CMP R3 R4
rom[27] = 16'h4b82; //                BZS CheckLow1
rom[28] = 16'h4386; //                BCS SleepDone1
rom[29] = 16'h9ff9; //                JMP SleepLoop1
rom[30] = 16'h6cfe; // CheckLow1:     LDL R3 $IoCntrLo.L
rom[31] = 16'h6dff; //                LDH R3 $IoCntrLo.H
rom[32] = 16'hcd80; //                LD R3 [R3]
rom[33] = 16'h01de; //                CMP R3 R5
rom[34] = 16'h47f4; //                BCC SleepLoop1
    //
rom[35] = 16'h300d; // SleepDone1:    POP R4
rom[36] = 16'h340d; //                POP R5
    //
rom[37] = 16'h6cfd; //                LDL R3 $IoCntrHi.L
rom[38] = 16'h6dff; //                LDH R3 $IoCntrHi.H
rom[39] = 16'hcd80; //                LD R3 [R3]
rom[40] = 16'h00be; //                CMP R1 R3
rom[41] = 16'h4b82; //                BZS CheckLow2
rom[42] = 16'h4386; //                BCS SleepDone2
rom[43] = 16'h9ff9; //                JMP SleepLoop2
rom[44] = 16'h6cfe; // CheckLow2:     LDL R3 $IoCntrLo.L
rom[45] = 16'h6dff; //                LDH R3 $IoCntrLo.H
rom[46] = 16'hcd80; //                LD R3 [R3]
rom[47] = 16'h013e; //                CMP R2 R3
rom[48] = 16'h47f4; //                BCC SleepLoop2
rom[49] = 16'h2c0d; // SleepDone2:    POP R3
rom[50] = 16'h280d; //                POP R2
rom[51] = 16'h240d; //                POP R1
rom[52] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Multiply  R0 * R2 -> R1 R2
    // ; [in]     R0 = operand1
    // ; [out]    R1 = result high
    // ; [in/out] R2 = operand2/result low
    // ;------------------------------------------------------------------------------
rom[53] = 16'h2c0c; // Multiply:         PSH R3
rom[54] = 16'h6600; //                   LDLZ R1 0
rom[55] = 16'h6e10; //                   LDLZ R3 16
rom[56] = 16'h2900; //                   SHR R2 R2
rom[57] = 16'h4781; // MultiplyBitLoop:  BCC NoAdd
rom[58] = 16'h0480; //                   ADD R1 R1 R0
rom[59] = 16'h2480; // NoAdd:            SHR R1 R1
rom[60] = 16'h2903; //                   ROR R2 R2
rom[61] = 16'h0d8f; //                   DEC R3 R3
rom[62] = 16'h4ffa; //                   BZC MultiplyBitLoop
rom[63] = 16'h2c0d; //                   POP R3
rom[64] = 16'h3c0d; //                   RET
    //
    // ;------------------------------------------------------------------------------
    // ; Divide R1 by R2 -> result in R1, remainder in R0
    // ; [out]    R0 = remainder
    // ; [in/out] R1 = divident/result
    // ; [in]     R2 = divisor
    // ;------------------------------------------------------------------------------
rom[65] = 16'h2c0c; // Divide:           PSH R3
rom[66] = 16'h6200; //                   LDLZ R0 0
rom[67] = 16'h6e10; //                   LDLZ R3 16
rom[68] = 16'h2481; //                   SHL R1 R1
rom[69] = 16'h2004; // DivideBitLoop:    ROL R0 R0
rom[70] = 16'h010e; //                   CMP R2 R0
rom[71] = 16'h4782; //                   BCC NoSub
rom[72] = 16'h0022; //                   SUB R0 R0 R2
rom[73] = 16'h2009; //                   SEC
rom[74] = 16'h2484; // NoSub:            ROL R1 R1
rom[75] = 16'h0d8f; //                   DEC R3 R3
rom[76] = 16'h4ff8; //                   BZC DivideBitLoop
rom[77] = 16'h2c0d; //                   POP R3
rom[78] = 16'h3c0d; //                   RET
    //
    // ;------------------------------------------------------------------------------
    // ; Fill screeen
    // ; [in] R0 = character
    // ; [in] R1 = color
    // ;------------------------------------------------------------------------------
rom[79] = 16'h280c; // FillScreen:    PSH R2
rom[80] = 16'h2c0c; //                PSH R3
rom[81] = 16'h300c; //                PSH R4
rom[82] = 16'h0809; //                LDL R2 R0 ; combine character and color
rom[83] = 16'h088a; //                LDH R2 R1
rom[84] = 16'h6f80; //                LDHZ R3 $FrameBuf.H ; Start address
rom[85] = 16'h70b0; //                LDL R4 (30 * 40).L  ; end address + 1
rom[86] = 16'h7104; //                LDH R4 (30 * 40).H
rom[87] = 16'h1230; //                ADD R4 R4 R3
rom[88] = 16'he980; // CharacterLoop: STO R2 [R3]
rom[89] = 16'h0d8c; //                INC R3 R3
rom[90] = 16'h01ce; //                CMP R3 R4
rom[91] = 16'h4ffc; //                BZC CharacterLoop
rom[92] = 16'h300d; //                POP R4
rom[93] = 16'h2c0d; //                POP R3
rom[94] = 16'h280d; //                POP R2
rom[95] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Display the value of R2 in hexadecimal format at screen column R0, and row R1
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [in]   R2 = reg
    // ;------------------------------------------------------------------------------
rom[96] = 16'h2c0c; // DisplayReg:    PSH R3
rom[97] = 16'h300c; //                PSH R4
rom[98] = 16'h340c; //                PSH R5
rom[99] = 16'hbc38; //                JSR GetCursorPos
rom[100] = 16'h720f; //                LDLZ R4 0x0F
rom[101] = 16'h090b; //                SWP R2 R2
rom[102] = 16'h0d09; //                LDL R3 R2
rom[103] = 16'h2d80; //                SHR R3 R3
rom[104] = 16'h2d80; //                SHR R3 R3
rom[105] = 16'h2d80; //                SHR R3 R3
rom[106] = 16'h2d80; //                SHR R3 R3
rom[107] = 16'h0dc4; //                AND R3 R3 R4
rom[108] = 16'hbc3c; //                JSR WriteHexDigit
rom[109] = 16'h0d09; //                LDL R3 R2
rom[110] = 16'h0dc4; //                AND R3 R3 R4
rom[111] = 16'hbc39; //                JSR WriteHexDigit
rom[112] = 16'h090b; //                SWP R2 R2
rom[113] = 16'h0d09; //                LDL R3 R2
rom[114] = 16'h2d80; //                SHR R3 R3
rom[115] = 16'h2d80; //                SHR R3 R3
rom[116] = 16'h2d80; //                SHR R3 R3
rom[117] = 16'h2d80; //                SHR R3 R3
rom[118] = 16'h0dc4; //                AND R3 R3 R4
rom[119] = 16'hbc31; //                JSR WriteHexDigit
rom[120] = 16'h0d09; //                LDL R3 R2
rom[121] = 16'h0dc4; //                AND R3 R3 R4
rom[122] = 16'hbc2e; //                JSR WriteHexDigit
rom[123] = 16'h340d; //                POP R5
rom[124] = 16'h300d; //                POP R4
rom[125] = 16'h2c0d; //                POP R3
rom[126] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Write string at position R5 to screen
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [in]   R2 = address of string
    // ;------------------------------------------------------------------------------
rom[127] = 16'h240c; // DisplayString:     PSH R1
rom[128] = 16'h280c; //                    PSH R2
rom[129] = 16'h2c0c; //                    PSH R3
rom[130] = 16'h300c; //                    PSH R4
rom[131] = 16'h340c; //                    PSH R5
rom[132] = 16'hbc17; //                    JSR GetCursorPos
rom[133] = 16'h7100; //                    LDH R4 0x00
rom[134] = 16'h653c; //                    LDH R1 $BgWhite | $Red; White background red text
rom[135] = 16'hcd00; // DisplayStringLoop: LD  R3 [R2]
rom[136] = 16'h0d8b; //                    SWP R3 R3
rom[137] = 16'h1189; //                    LDL R4 R3
rom[138] = 16'h4b8b; //                    BZS DisplayStringDone
rom[139] = 16'h0609; //                    LDL R1 R4
rom[140] = 16'he680; //                    STO R1 [R5]
rom[141] = 16'h168c; //                    INC R5 R5
rom[142] = 16'h0d8b; //                    SWP R3 R3
rom[143] = 16'h1189; //                    LDL R4 R3
rom[144] = 16'h4b85; //                    BZS DisplayStringDone
rom[145] = 16'h0609; //                    LDL R1 R4
rom[146] = 16'he680; //                    STO R1 [R5]
rom[147] = 16'h168c; //                    INC R5 R5
rom[148] = 16'h090c; //                    INC R2 R2;
rom[149] = 16'h9ff1; //                    JMP DisplayStringLoop
rom[150] = 16'h340d; // DisplayStringDone: POP R5
rom[151] = 16'h300d; //                    POP R4
rom[152] = 16'h2c0d; //                    POP R3
rom[153] = 16'h280d; //                    POP R2
rom[154] = 16'h240d; //                    POP R1
rom[155] = 16'h3c0d; //                    RET
    //
    // ;------------------------------------------------------------------------------
    // ; Get the address of screen column R0, row R1
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [out]  R5 = position
    // ;------------------------------------------------------------------------------
rom[156] = 16'h2c0c; // GetCursorPos:  PSH R3
rom[157] = 16'h7780; //                LDHZ R5 $FrameBuf.H
rom[158] = 16'h0c88; //                LD R3  R1 ; Multiply row by 40
rom[159] = 16'h2d81; //                SHL R3 R3
rom[160] = 16'h2d81; //                SHL R3 R3
rom[161] = 16'h2d81; //                SHL R3 R3
rom[162] = 16'h16b0; //                ADD R5 R5 R3
rom[163] = 16'h2d81; //                SHL R3 R3
rom[164] = 16'h2d81; //                SHL R3 R3
rom[165] = 16'h16b0; //                ADD R5 R5 R3
rom[166] = 16'h1680; //                ADD R5 R5 R0 ; Add column
rom[167] = 16'h2c0d; //                POP R3
rom[168] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Write hex digit R3 at position R5 to screen
    // ; [in]   R5 = pos
    // ; [in]   R3 = hex digit
    // ;------------------------------------------------------------------------------
rom[169] = 16'h300c; // WriteHexDigit: PSH R4
rom[170] = 16'h720a; //                LDLZ R4 10
rom[171] = 16'h01ce; //                CMP R3 R4
rom[172] = 16'h4783; //                BCC NotDecimal
rom[173] = 16'h7230; //                LDLZ R4 '0'
rom[174] = 16'h0dc0; //                ADD R3 R3 R4
rom[175] = 16'h9c02; //                JMP StoreDigit
rom[176] = 16'h7237; // NotDecimal:    LDLZ R4 'A' - 10
rom[177] = 16'h0dc0; //                ADD R3 R3 R4
rom[178] = 16'h6d3c; // StoreDigit:    LDH R3 $BgWhite | $Red; White background red text
rom[179] = 16'hee80; //                STO R3 [R5]
rom[180] = 16'h168c; //                INC R5 R5
rom[181] = 16'h300d; //                POP R4
rom[182] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Draw horizontal line
    // ; [in] R0 = x
    // ; [in] R1 = y
    // ; [in] R2 = color
    // ; [in] R3 = length
    // ;------------------------------------------------------------------------------
rom[183] = 16'h200c; // DrawHline:     PSH R0
rom[184] = 16'h2c0c; //                PSH R3
rom[185] = 16'hbc0f; // DrawHlineLoop: JSR DrawPixel
rom[186] = 16'h000c; //                INC R0 R0
rom[187] = 16'h0d8f; //                DEC R3 R3
rom[188] = 16'h4ffc; //                BZC DrawHlineLoop
rom[189] = 16'h2c0d; //                POP R3
rom[190] = 16'h200d; //                POP R0
rom[191] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Draw vertical line
    // ; [in] R0 = x
    // ; [in] R1 = y
    // ; [in] R2 = color
    // ; [in] R3 = length
    // ;------------------------------------------------------------------------------
rom[192] = 16'h240c; // DrawVline:     PSH R1
rom[193] = 16'h2c0c; //                PSH R3
rom[194] = 16'hbc06; // DrawVlineLoop: JSR DrawPixel
rom[195] = 16'h048c; //                INC R1 R1
rom[196] = 16'h0d8f; //                DEC R3 R3
rom[197] = 16'h4ffc; //                BZC DrawVlineLoop
rom[198] = 16'h2c0d; //                POP R3
rom[199] = 16'h240d; //                POP R1
rom[200] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Draw pixel
    // ; [in] R0 = x
    // ; [in] R1 = y
    // ; [in] R2 = color
    // ;------------------------------------------------------------------------------
rom[201] = 16'h200c; // DrawPixel:     PSH R0
rom[202] = 16'h240c; //                PSH R1
rom[203] = 16'h280c; //                PSH R2
rom[204] = 16'h2c0c; //                PSH R3
rom[205] = 16'h300c; //                PSH R4
rom[206] = 16'h340c; //                PSH R5
    //
    //                ; Calculate color map address
rom[207] = 16'h6cfd; //                LDL R3 ColorMap.L
rom[208] = 16'h6df0; //                LDH R3 ColorMap.H
rom[209] = 16'h0930; //                ADD R2 R2 R3
rom[210] = 16'hc900; //                LD R2 [R2]
    //
rom[211] = 16'h6e00; //                LDLZ R3 0
rom[212] = 16'h2480; //                SHR R1 R1 ;
rom[213] = 16'h2d84; //                ROL R3 R3
rom[214] = 16'h2000; //                SHR R0 R0
rom[215] = 16'h2d84; //                ROL R3 R3
    //
rom[216] = 16'h7005; //                LDL R4 PixelMask.L
rom[217] = 16'h71f1; //                LDH R4 PixelMask.H
rom[218] = 16'h0dc0; //                ADD R3 R3 R4
rom[219] = 16'hcd80; //                LD R3 [R3]
rom[220] = 16'h0934; //                AND R2 R2 R3
rom[221] = 16'h0d87; //                NOT R3 R3
rom[222] = 16'hbfbd; //                JSR GetCursorPos
rom[223] = 16'hd280; //                LD R4 [R5]
rom[224] = 16'h1234; //                AND R4 R4 R3
rom[225] = 16'h1225; //                OR R4 R4 R2
rom[226] = 16'hf280; //                STO R4 [R5]
    //
rom[227] = 16'h340d; //                POP R5
rom[228] = 16'h300d; //                POP R4
rom[229] = 16'h2c0d; //                POP R3
rom[230] = 16'h280d; //                POP R2
rom[231] = 16'h240d; //                POP R1
rom[232] = 16'h200d; //                POP R0
rom[233] = 16'h3c0d; //                RET
    //
    // ;------------------------------------------------------------------------------
    // ; Fill pixel screen with a color
    // ; [in] R0 = color
    // ;------------------------------------------------------------------------------
rom[234] = 16'h280c; // FillPixelScreen: PSH R2
rom[235] = 16'h2c0c; //                  PSH R3
rom[236] = 16'h300c; //                  PSH R4
    //
    //                  ; Calculate color map address
rom[237] = 16'h68fd; //                  LDL R2 ColorMap.L
rom[238] = 16'h69f0; //                  LDH R2 ColorMap.H
rom[239] = 16'h0900; //                  ADD R2 R2 R0
    //
    //                  ; Load R2 with pixel block color
rom[240] = 16'hc900; //                  LD R2 [R2]
    //
rom[241] = 16'h6f80; //                  LDHZ R3 $FrameBuf.H ; Start address
rom[242] = 16'h70b0; //                  LDL R4 (30 * 40).L  ; end address + 1
rom[243] = 16'h7104; //                  LDH R4 (30 * 40).H
rom[244] = 16'h1230; //                  ADD R4 R4 R3
rom[245] = 16'he980; // PixelBlockLoop:  STO R2 [R3]
rom[246] = 16'h0d8c; //                  INC R3 R3
rom[247] = 16'h01ce; //                  CMP R3 R4
rom[248] = 16'h4ffc; //                  BZC PixelBlockLoop
rom[249] = 16'h300d; //                  POP R4
rom[250] = 16'h2c0d; //                  POP R3
rom[251] = 16'h280d; //                  POP R2
rom[252] = 16'h3c0d; //                  RET
    //
rom[253] = 16'h8000; // .data $Black   | ($Black << 3)   | ($Black << 6)   | ($Black << 9)   | 0x8000
rom[254] = 16'h8249; // .data $Blue    | ($Blue << 3)    | ($Blue << 6)    | ($Blue << 9)    | 0x8000
rom[255] = 16'h8492; // .data $Green   | ($Green << 3)   | ($Green << 6)   | ($Green << 9)   | 0x8000
rom[256] = 16'h86db; // .data $Cyan    | ($Cyan << 3)    | ($Cyan << 6)    | ($Cyan << 9)    | 0x8000
rom[257] = 16'h8924; // .data $Red     | ($Red << 3)     | ($Red << 6)     | ($Red << 9)     | 0x8000
rom[258] = 16'h8b6d; // .data $Magenta | ($Magenta << 3) | ($Magenta << 6) | ($Magenta << 9) | 0x8000
rom[259] = 16'h8db6; // .data $Yellow  | ($Yellow << 3)  | ($Yellow << 6)  | ($Yellow << 9)  | 0x8000
rom[260] = 16'h8fff; // .data $White   | ($White << 3)   | ($White << 6)   | ($White << 9)   | 0x8000
    //
rom[261] = 16'h8007; // .data 0x0007      | 0x8000
rom[262] = 16'h8038; // .data 0x0007 << 3 | 0x8000
rom[263] = 16'h81c0; // .data 0x0007 << 6 | 0x8000
rom[264] = 16'h8e00; // .data 0x0007 << 9 | 0x8000
    end
endmodule

`endif
