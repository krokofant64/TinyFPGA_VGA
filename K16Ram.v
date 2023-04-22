`ifndef K16RAM_V
`define K16RAM_V

module K16SinglePortRam (din, addr, write_en, clk, dout);// 4096x16
  parameter addr_width = 12;
  parameter data_width = 16;
  input [addr_width-1:0] addr;
  input [data_width-1:0] din;
  input write_en, clk;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout; // Register for output.
  reg [data_width-1:0] mem [(1<<addr_width)-1:0];
  always @(posedge clk)
    begin
      if (write_en)
        mem[(addr)] <= din;
      dout <= mem[addr]; // Output register controlled by clock.
    end
  initial
    begin
    // .define $FrameBuf  0x8000
    // .define $AddrSwtch 0xFFF8
    // .define $CtrlSwtch 0xFFF9
    // .define $AddrLeds  0xFFFA
    // .define $DataLeds  0xFFFB
    // .define $RegSwtch  0xFFFC
    // .define $IoCntrHi  0xFFFD
    // .define $IoCntrLo  0xFFFE
    // .define $Sound     0xFFFF
    //
    // .define $Black     0x0000
    // .define $Blue      0x0001
    // .define $Green     0x0002
    // .define $Cyan      0x0003
    // .define $Red       0x0004
    // .define $Magenta   0x0005
    // .define $Yellow    0x0006
    // .define $White     0x0007
    //
    // .define $BgBlack   ($Black << 3)
    // .define $BgBlue    ($Blue << 3)
    // .define $BgGreen   ($Green << 3)
    // .define $BgCyan    ($Cyan << 3)
    // .define $BgRed     ($Red << 3)
    // .define $BgMagenta ($Magenta << 3)
    // .define $BgYellow  ($Yellow << 3)
    // .define $BgWhite   ($White << 3)
    //
    // .define $Mask_x0y0 ~(0x0007)
    // .define $Mask_x1y0 ~(0x0007 << 3)
    // .define $Mask_x0y1 ~(0x0007 << 6)
    // .define $Mask_x1y1 ~(0x0007 << 9)
    //
    // ; Notes
    // .define $C3     3007
    // .define $Csp3   2838 ; C#3
    // .define $D3     2679
    // .define $Dsp3   2529 ; D#3
    // .define $E3     2387
    // .define $F3     2253
    // .define $Fsp3   2126 ; F#3
    // .define $G3     2007
    // .define $Gsp3   1894 ; G#3
    // .define $A3     1788
    // .define $Asp3   1688 ; A#3
    // .define $B3     1593
    //
    // .define $C4     1504
    // .define $Csp4   1419 ; C#4
    // .define $D4     1339
    // .define $Dsp4   1264 ; D#4
    // .define $E4     1193
    // .define $F4     1126
    // .define $Fsp4   1063 ; F#4
    // .define $G4     1003
    // .define $Gsp4    947 ; G#4
    // .define $A4      894
    // .define $Asp4    844 ; A#4
    // .define $B4      796
    //
    // .define $C5      752
    // .define $Csp5    710 ; C#5
    // .define $D5      670
    // .define $Dsp5    632 ; D#5
    // .define $E5      597
    // .define $F5      563
    // .define $Fsp5    532 ; F#5
    // .define $G5      502
    // .define $Gsp5    474 ; G#5
    // .define $A5      447
    // .define $Asp5    422 ; A#5
    // .define $B5      398
    //
    // ; Duration
    // .define $BPM    100 ; Hans 140
    // .define $BeatMs (60 * 1000) / $BPM
    // .define $Decay  $BeatMs / 10
    // .define $9_8    9 * ($BeatMs / 8) - $Decay
    // .define $1_1    1 * ($BeatMs * 4) - $Decay
    // .define $1_2d   3 * ($BeatMs    ) - $Decay
    // .define $1_2    1 * ($BeatMs * 2) - $Decay
    // .define $1_4d   3 * ($BeatMs / 2) - $Decay
    // .define $1_4    1 * ($BeatMs    ) - $Decay
    // .define $3_8    3 * ($BeatMs / 8) - $Decay
    // .define $1_8d   3 * ($BeatMs / 4) - $Decay
    // .define $1_8    1 * ($BeatMs / 2) - $Decay
    // .define $1_16d  3 * ($BeatMs / 8) - $Decay
    // .define $1_16   1 * ($BeatMs / 4) - $Decay
mem[0] = 16'h9c21; // JMP Start
    //
mem[1] = 16'h4164; // .string "Address switches:"
mem[2] = 16'h6472;
mem[3] = 16'h6573;
mem[4] = 16'h7320;
mem[5] = 16'h7377;
mem[6] = 16'h6974;
mem[7] = 16'h6368;
mem[8] = 16'h6573;
mem[9] = 16'h3a00;
mem[10] = 16'h436f; // .string "Control switches:"
mem[11] = 16'h6e74;
mem[12] = 16'h726f;
mem[13] = 16'h6c20;
mem[14] = 16'h7377;
mem[15] = 16'h6974;
mem[16] = 16'h6368;
mem[17] = 16'h6573;
mem[18] = 16'h3a00;
mem[19] = 16'h5265; // .string "Register switches:"
mem[20] = 16'h6769;
mem[21] = 16'h7374;
mem[22] = 16'h6572;
mem[23] = 16'h2073;
mem[24] = 16'h7769;
mem[25] = 16'h7463;
mem[26] = 16'h6865;
mem[27] = 16'h733a;
mem[28] = 16'h0000;
mem[29] = 16'h436f; // .string "Counter:"
mem[30] = 16'h756e;
mem[31] = 16'h7465;
mem[32] = 16'h723a;
mem[33] = 16'h0000;
    //
mem[34] = 16'h6079; //                LDL R0 Interrupt.L
mem[35] = 16'h6100; //                LDH R0 Interrupt.H
mem[36] = 16'h64ff; //                LDL R1 0x0FFF.L
mem[37] = 16'h650f; //                LDH R1 0x0FFF.H
mem[38] = 16'he080; //                STO R0 [R1]
mem[39] = 16'h200b; //                SEI
mem[40] = 16'h6220; //                LDLZ R0 ' '
mem[41] = 16'h6608; //                LDLZ R1 $BgBlue
mem[42] = 16'h7400; //                LDL R5 Library.L
mem[43] = 16'h75f0; //                LDH R5 Library.H
mem[44] = 16'hb44f; //                JSR [R5 + (FillScreen-Library)] ; FillScreen - Library]
    //
mem[45] = 16'h642f; //                LDL R1 California.L
mem[46] = 16'h6501; //                LDH R1 California.H
mem[47] = 16'h68ff; //                LDL R2 $Sound.L
mem[48] = 16'h69ff; //                LDH R2 $Sound.H
mem[49] = 16'hcc80; // SoundLoop:     LD R3 [R1] ; Frequency in R3
mem[50] = 16'h048c; //                INC R1 R1
mem[51] = 16'hc080; //                LD R0 [R1] ; Duration in R0
mem[52] = 16'h4b88; //                BZS Loop
mem[53] = 16'hed00; //                STO R3 [R2]
mem[54] = 16'hb400; //                JSR [R5 + (Sleep-Library)]
mem[55] = 16'h6e00; //                LDLZ R3 0
mem[56] = 16'hed00; //                STO R3 [R2]
mem[57] = 16'h6232; //                LDLZ R0 50
mem[58] = 16'hb400; //                JSR [R5 + (Sleep-Library)]
mem[59] = 16'h048c; //                INC R1 R1
mem[60] = 16'h9ff4; //                JMP SoundLoop
    //
    //                ; Display labels
mem[61] = 16'h6201; // Loop:          LDLZ R0 0x01; column 1
mem[62] = 16'h6601; //                LDLZ R1 0x01; row 1
mem[63] = 16'h6a01; //                LDLZ R2 AddrSwString.L
mem[64] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
mem[65] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[66] = 16'h6602; //                LDLZ R1 0x02; row 2
mem[67] = 16'h6a0a; //                LDLZ R2 CtrlSwString.L
mem[68] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
mem[69] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[70] = 16'h6603; //                LDLZ R1 0x03; row 3
mem[71] = 16'h6a13; //                LDLZ R2 RegSwString.L
mem[72] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
mem[73] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[74] = 16'h6604; //                LDLZ R1 0x04; row 4
mem[75] = 16'h6a1d; //                LDLZ R2 CounterString.L
mem[76] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
    //                ; Display address switch settings on screen
mem[77] = 16'h6cf8; //                LDL R3 $AddrSwtch.L
mem[78] = 16'h6dff; //                LDH R3 $AddrSwtch.H
mem[79] = 16'hc980; //                LD R2 [R3]
mem[80] = 16'h6214; //                LDLZ R0 20; column 1
mem[81] = 16'h6601; //                LDLZ R1 1;  row 1
mem[82] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
    //                ; Display address switch settings on LEDs
mem[83] = 16'h6cfa; //                LDL R3 $AddrLeds.L
mem[84] = 16'h6dff; //                LDH R3 $AddrLeds.H
mem[85] = 16'he980; //                STO R2 [R3]
    //
    //                ; Display control switch settings on screen
mem[86] = 16'h6cf9; //                LDL R3 $CtrlSwtch.L
mem[87] = 16'h6dff; //                LDH R3 $CtrlSwtch.H
mem[88] = 16'hc980; //                LD R2 [R3]
mem[89] = 16'h6214; //                LDLZ R0 20; column 1
mem[90] = 16'h6602; //                LDLZ R1 2;  row 2
mem[91] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
mem[92] = 16'h1109; //                LDL R4 R2
    //
    //                ; Display register switch settings on screen
mem[93] = 16'h6cfc; //                LDL R3 $RegSwtch.L
mem[94] = 16'h6dff; //                LDH R3 $RegSwtch.H
mem[95] = 16'hc980; //                LD R2 [R3]
mem[96] = 16'h6214; //                LDLZ R0 20; column 1
mem[97] = 16'h6603; //                LDLZ R1 3;  row 3
mem[98] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //                ; Display control and register switches on LEDs
mem[99] = 16'h110a; //                LDH R4 R2
mem[100] = 16'h6cfb; //                LDL R3 $DataLeds.L
mem[101] = 16'h6dff; //                LDH R3 $DataLeds.H
mem[102] = 16'hf180; //                STO R4 [R3]
    //
    //                ; Display cycle counters on screen
mem[103] = 16'h6cfe; //                LDL R3 $IoCntrLo.L
mem[104] = 16'h6dff; //                LDH R3 $IoCntrLo.H
mem[105] = 16'hc980; //                LD R2 [R3]
mem[106] = 16'h6214; //                LDLZ R0 20; column 1
mem[107] = 16'h6604; //                LDLZ R1 4;  row 4
mem[108] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
mem[109] = 16'h6cfd; //                LDL R3 $IoCntrHi.L
mem[110] = 16'h6dff; //                LDH R3 $IoCntrHi.H
mem[111] = 16'hc980; //                LD R2 [R3]
mem[112] = 16'h6219; //                LDLZ R0 25; column 1
mem[113] = 16'h6604; //                LDLZ R1 4;  row 4
mem[114] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
mem[115] = 16'hcb84; //                LD R2 Counter
mem[116] = 16'h6219; //                LDLZ R0 25; column 1
mem[117] = 16'h6605; //                LDLZ R1 5;  row 5
mem[118] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
    //
mem[119] = 16'h9fc5; //                JMP Loop
mem[120] = 16'h0000; // .data 0
mem[121] = 16'h200e; // Interrupt: PSF
mem[122] = 16'h200c; //            PSH R0
mem[123] = 16'h240c; //            PSH R1
mem[124] = 16'hc3fb; //            LD R0 Counter
mem[125] = 16'h6601; //            LDLZ R1 1
mem[126] = 16'h0010; //            ADD R0 R0 R1
mem[127] = 16'he3f8; //            STO R0 Counter
mem[128] = 16'h240d; //            POP R1
mem[129] = 16'h200d; //            POP R0
mem[130] = 16'h200f; //            POF
mem[131] = 16'h200b; //            SEI
mem[132] = 16'h3c0d; //            RET
    //
    //
mem[133] = 16'h03eb; // .data $G4, $1_4
mem[134] = 16'h021c;
mem[135] = 16'h04a9; // .data $E4, $1_4
mem[136] = 16'h021c;
mem[137] = 16'h04a9; // .data $E4, $1_2
mem[138] = 16'h0474;
mem[139] = 16'h0466; // .data $F4, $1_4
mem[140] = 16'h021c;
mem[141] = 16'h053b; // .data $D4, $1_4
mem[142] = 16'h021c;
mem[143] = 16'h053b; // .data $D4, $1_2
mem[144] = 16'h0474;
mem[145] = 16'h05e0; // .data $C4, $1_4
mem[146] = 16'h021c;
mem[147] = 16'h053b; // .data $D4, $1_4
mem[148] = 16'h021c;
mem[149] = 16'h04a9; // .data $E4, $1_4
mem[150] = 16'h021c;
mem[151] = 16'h0466; // .data $F4, $1_4
mem[152] = 16'h021c;
mem[153] = 16'h03eb; // .data $G4, $1_4
mem[154] = 16'h021c;
mem[155] = 16'h03eb; // .data $G4, $1_4
mem[156] = 16'h021c;
mem[157] = 16'h03eb; // .data $G4, $1_2
mem[158] = 16'h0474;
mem[159] = 16'h03eb; // .data $G4, $1_4
mem[160] = 16'h021c;
mem[161] = 16'h04a9; // .data $E4, $1_4
mem[162] = 16'h021c;
mem[163] = 16'h04a9; // .data $E4, $1_2
mem[164] = 16'h0474;
mem[165] = 16'h0466; // .data $F4, $1_4
mem[166] = 16'h021c;
mem[167] = 16'h053b; // .data $D4, $1_4
mem[168] = 16'h021c;
mem[169] = 16'h053b; // .data $D4, $1_2
mem[170] = 16'h0474;
mem[171] = 16'h05e0; // .data $C4, $1_4
mem[172] = 16'h021c;
mem[173] = 16'h04a9; // .data $E4, $1_4
mem[174] = 16'h021c;
mem[175] = 16'h03eb; // .data $G4, $1_4
mem[176] = 16'h021c;
mem[177] = 16'h03eb; // .data $G4, $1_4
mem[178] = 16'h021c;
mem[179] = 16'h05e0; // .data $C4, $1_1
mem[180] = 16'h0924;
mem[181] = 16'h0000; // .data   0,   0
mem[182] = 16'h0000;
    //
mem[183] = 16'h04a9; // .data $E4, $1_8d
mem[184] = 16'h0186;
mem[185] = 16'h04a9; // .data $E4, $1_16
mem[186] = 16'h005a;
mem[187] = 16'h04a9; // .data $E4, $1_8d
mem[188] = 16'h0186;
mem[189] = 16'h0466; // .data $F4, $1_16
mem[190] = 16'h005a;
mem[191] = 16'h03eb; // .data $G4, $1_4
mem[192] = 16'h021c;
mem[193] = 16'h04a9; // .data $E4, $1_4
mem[194] = 16'h021c;
mem[195] = 16'h0466; // .data $F4, $1_8d
mem[196] = 16'h0186;
mem[197] = 16'h0466; // .data $F4, $1_16
mem[198] = 16'h005a;
mem[199] = 16'h0466; // .data $F4, $1_8d
mem[200] = 16'h0186;
mem[201] = 16'h02f0; // .data $C5, $1_16
mem[202] = 16'h005a;
mem[203] = 16'h031c; // .data $B4, $1_2
mem[204] = 16'h0474;
mem[205] = 16'h053b; // .data $D4, $1_8d
mem[206] = 16'h0186;
mem[207] = 16'h053b; // .data $D4, $1_16
mem[208] = 16'h005a;
mem[209] = 16'h053b; // .data $D4, $1_8d
mem[210] = 16'h0186;
mem[211] = 16'h04a9; // .data $E4, $1_16
mem[212] = 16'h005a;
mem[213] = 16'h0466; // .data $F4, $1_4
mem[214] = 16'h021c;
mem[215] = 16'h0466; // .data $F4, $1_8d
mem[216] = 16'h0186;
mem[217] = 16'h03eb; // .data $G4, $1_16
mem[218] = 16'h005a;
mem[219] = 16'h031c; // .data $B4, $1_8d
mem[220] = 16'h0186;
mem[221] = 16'h037e; // .data $A4, $1_16
mem[222] = 16'h005a;
mem[223] = 16'h03eb; // .data $G4, $1_8d
mem[224] = 16'h0186;
mem[225] = 16'h0466; // .data $F4, $1_16
mem[226] = 16'h005a;
mem[227] = 16'h04a9; // .data $E4, $1_4d
mem[228] = 16'h0348;
mem[229] = 16'h05e0; // .data $C4, $1_8
mem[230] = 16'h00f0;
mem[231] = 16'h037e; // .data $A4, $1_4
mem[232] = 16'h021c;
mem[233] = 16'h031c; // .data $B4, $1_8d
mem[234] = 16'h0186;
mem[235] = 16'h02f0; // .data $C5, $1_16
mem[236] = 16'h005a;
mem[237] = 16'h031c; // .data $B4, $1_4
mem[238] = 16'h021c;
mem[239] = 16'h037e; // .data $A4, $1_4
mem[240] = 16'h021c;
mem[241] = 16'h037e; // .data $A4, $1_4
mem[242] = 16'h021c;
mem[243] = 16'h03eb; // .data $G4, $1_4
mem[244] = 16'h021c;
mem[245] = 16'h031c; // .data $B4, $1_4d
mem[246] = 16'h0348;
mem[247] = 16'h037e; // .data $A4, $1_8
mem[248] = 16'h00f0;
mem[249] = 16'h03eb; // .data $G4, $1_4
mem[250] = 16'h021c;
mem[251] = 16'h0466; // .data $F4, $1_4
mem[252] = 16'h021c;
mem[253] = 16'h037e; // .data $A4, $1_4d
mem[254] = 16'h0348;
mem[255] = 16'h03eb; // .data $G4, $1_8
mem[256] = 16'h00f0;
mem[257] = 16'h0466; // .data $F4, $1_4
mem[258] = 16'h021c;
mem[259] = 16'h04a9; // .data $E4, $1_4
mem[260] = 16'h021c;
mem[261] = 16'h03eb; // .data $G4, $1_4d
mem[262] = 16'h0348;
mem[263] = 16'h04a9; // .data $E4, $1_8
mem[264] = 16'h00f0;
mem[265] = 16'h03eb; // .data $G4, $1_4d
mem[266] = 16'h0348;
mem[267] = 16'h0466; // .data $F4, $1_8
mem[268] = 16'h00f0;
mem[269] = 16'h0466; // .data $F4, $1_4
mem[270] = 16'h021c;
mem[271] = 16'h029e; // .data $D5, $1_4
mem[272] = 16'h021c;
mem[273] = 16'h02f0; // .data $C5, $1_2
mem[274] = 16'h0474;
mem[275] = 16'h03eb; // .data $G4, $1_4
mem[276] = 16'h021c;
mem[277] = 16'h04a9; // .data $E4, $1_4
mem[278] = 16'h021c;
mem[279] = 16'h03eb; // .data $G4, $1_4d
mem[280] = 16'h0348;
mem[281] = 16'h0466; // .data $F4, $1_8
mem[282] = 16'h00f0;
mem[283] = 16'h0466; // .data $F4, $1_4
mem[284] = 16'h021c;
mem[285] = 16'h0639; // .data $B3, $1_4
mem[286] = 16'h021c;
mem[287] = 16'h05e0; // .data $C4, $1_2
mem[288] = 16'h0474;
mem[289] = 16'h0255; // .data $E5, $1_4
mem[290] = 16'h021c;
mem[291] = 16'h01f6; // .data $G5, $1_4d
mem[292] = 16'h0348;
mem[293] = 16'h0233; // .data $F5, $1_8
mem[294] = 16'h00f0;
mem[295] = 16'h0233; // .data $F5, $1_4
mem[296] = 16'h021c;
mem[297] = 16'h031c; // .data $B4, $1_4
mem[298] = 16'h021c;
mem[299] = 16'h02f0; // .data $C5, $1_1
mem[300] = 16'h0924;
mem[301] = 16'h0000; // .data   0,   0
mem[302] = 16'h0000;
    //
mem[303] = 16'h037e; // .data $A4,   $1_8
mem[304] = 16'h00f0;
mem[305] = 16'h031c; // .data $B4,   $1_8
mem[306] = 16'h00f0;
mem[307] = 16'h037e; // .data $A4,   $1_8
mem[308] = 16'h00f0;
mem[309] = 16'h03eb; // .data $G4,   $1_8
mem[310] = 16'h00f0;
mem[311] = 16'h037e; // .data $A4,   $1_2
mem[312] = 16'h0474;
mem[313] = 16'h0000; // .data   0,   $1_2
mem[314] = 16'h0474;
mem[315] = 16'h0000; // .data   0,   $1_4
mem[316] = 16'h021c;
mem[317] = 16'h037e; // .data $A4,   $1_8
mem[318] = 16'h00f0;
mem[319] = 16'h031c; // .data $B4,   $1_8
mem[320] = 16'h00f0;
mem[321] = 16'h037e; // .data $A4,   $1_8
mem[322] = 16'h00f0;
mem[323] = 16'h03eb; // .data $G4,   $1_8
mem[324] = 16'h00f0;
mem[325] = 16'h03eb; // .data $G4,   $1_8
mem[326] = 16'h00f0;
mem[327] = 16'h04a9; // .data $E4,   $9_8
mem[328] = 16'h0267;
mem[329] = 16'h0000; // .data   0,   $1_2
mem[330] = 16'h0474;
mem[331] = 16'h02f0; // .data $C5,   $1_8
mem[332] = 16'h00f0;
mem[333] = 16'h02f0; // .data $C5,   $1_4
mem[334] = 16'h021c;
mem[335] = 16'h02f0; // .data $C5,   $1_8
mem[336] = 16'h00f0;
mem[337] = 16'h02f0; // .data $C5,   $1_8
mem[338] = 16'h00f0;
mem[339] = 16'h02f0; // .data $C5,   $1_2
mem[340] = 16'h0474;
mem[341] = 16'h0000; // .data   0,   $1_2
mem[342] = 16'h0474;
mem[343] = 16'h0000; // .data   0,   $1_4
mem[344] = 16'h021c;
mem[345] = 16'h02f0; // .data $C5,   $1_8
mem[346] = 16'h00f0;
mem[347] = 16'h02f0; // .data $C5,   $1_8
mem[348] = 16'h00f0;
mem[349] = 16'h02f0; // .data $C5,   $1_8
mem[350] = 16'h00f0;
mem[351] = 16'h02f0; // .data $C5,   $1_4
mem[352] = 16'h021c;
mem[353] = 16'h031c; // .data $B4,   $9_8
mem[354] = 16'h0267;
mem[355] = 16'h0000; // .data   0,   $1_2
mem[356] = 16'h0474;
mem[357] = 16'h04a9; // .data $E4,   $1_8
mem[358] = 16'h00f0;
mem[359] = 16'h04a9; // .data $E4,   $1_8
mem[360] = 16'h00f0;
mem[361] = 16'h0427; // .data $Fsp4, $1_8
mem[362] = 16'h00f0;
mem[363] = 16'h04a9; // .data $E4,   $1_8
mem[364] = 16'h00f0;
mem[365] = 16'h02f0; // .data $C5,   $1_8
mem[366] = 16'h00f0;
mem[367] = 16'h037e; // .data $A4,   $3_8
mem[368] = 16'h00a5;
mem[369] = 16'h0000; // .data   0,   $1_2
mem[370] = 16'h0474;
mem[371] = 16'h0000; // .data   0,   $1_4
mem[372] = 16'h021c;
mem[373] = 16'h037e; // .data $A4,   $1_8
mem[374] = 16'h00f0;
mem[375] = 16'h031c; // .data $B4,   $1_8
mem[376] = 16'h00f0;
mem[377] = 16'h037e; // .data $A4,   $1_8
mem[378] = 16'h00f0;
mem[379] = 16'h03eb; // .data $G4,   $1_8
mem[380] = 16'h00f0;
mem[381] = 16'h03eb; // .data $G4,   $1_8
mem[382] = 16'h00f0;
mem[383] = 16'h04a9; // .data $E4,   $9_8
mem[384] = 16'h0267;
mem[385] = 16'h0000; // .data   0,   0
mem[386] = 16'h0000;
    end
endmodule

module K16DualPortRam(din, write_en, waddr, wclk, raddr, rclk, dout); //1024x16
  parameter addr_width = 11;
  parameter data_width = 16;
  input [addr_width-1:0] waddr, raddr;
  input [data_width-1:0] din;
  input write_en, wclk, rclk;
  output reg [data_width-1:0] dout;
  reg [data_width-1:0] mem [(1<<addr_width)-1:0] ;

  always @(posedge wclk) // Write memory.
    begin
      if (write_en)
        mem[waddr] <= din; // Using write address bus.
    end
  always @(posedge rclk) // Read memory.
    begin
      dout <= mem[raddr]; // Using read address bus.
    end

  initial
    begin
      mem[0]  = {8'b00100111, "H"};
      mem[1]  = {8'b00100111, "e"};
      mem[2]  = {8'b00100111, "l"};
      mem[3]  = {8'b00100111, "l"};
      mem[4]  = {8'b00100111, "o"};
      mem[5]  = {8'b00100111, " "};
      mem[6]  = {8'b00100111, "W"};
      mem[7]  = {8'b00100111, "o"};
      mem[8]  = {8'b00100111, "r"};
      mem[9]  = {8'b00100111, "l"};
      mem[10] = {8'b00100111, "d"};
      mem[11] = {8'b00100111, "!"};
      mem[12] = {8'b00100111, " "};
      mem[13] = {8'b00100111, "3"};
      mem[14] = {8'b00100111, "4"};
      mem[15] = {8'b00100111, "5"};
      mem[16] = {8'b00100111, "6"};
      mem[17] = {8'b00100111, "7"};
      mem[18] = {8'b00100111, "8"};
      mem[19] = {8'b00100111, "9"};
      mem[20] = {8'b00100111, "A"};
      mem[21] = {8'b00100111, "B"};
      mem[22] = {8'b00100111, "C"};
      mem[23] = {8'b00100111, "D"};
      mem[24] = {8'b00100111, "E"};
      mem[25] = {8'b00100111, "F"};
      mem[26] = {8'b00100111, "G"};
      mem[27] = {8'b00100111, "H"};
      mem[28] = {8'b00100111, "I"};
      mem[29] = {8'b00100111, "J"};
      mem[30] = {8'b00100111, "K"};
      mem[31] = {8'b00100111, " "};
      mem[32] = {8'b00100111, "T"};
      mem[33] = {8'b00100111, "h"};
      mem[34] = {8'b00100111, "o"};
      mem[35] = {8'b00100111, "r"};
      mem[36] = {8'b00100111, "s"};
      mem[37] = {8'b00100111, "t"};
      mem[38] = {8'b00100111, "e"};
      mem[39] = {8'b00100111, "n"};
      mem[40] = {8'b00100111, " "};
      mem[41] = {8'b00100111, "H"};
      mem[42] = {8'b00100111, "e"};
      mem[43] = {8'b00100111, "r"};
      mem[44] = {8'b00100111, "b"};
      mem[45] = {8'b00100111, "e"};
      mem[46] = {8'b00100111, "r"};
      mem[47] = {8'b00100111, " "};
      mem[48] = 16'b1000110001010111;
      mem[49] = {8'b00110010, 8'd0};
      mem[50] = {8'b00110010, 8'd1};
      mem[51] = {8'b00110010, 8'd2};
      mem[52] = {8'b00110010, 8'd3};
      mem[53] = {8'b00110010, 8'd4};
      mem[54] = {8'b00110010, 8'd5};
      mem[55] = {8'b00110010, 8'd6};
      mem[56] = {8'b00110010, 8'd7};
      mem[57] = {8'b00110010, 8'd8};
      mem[58] = {8'b00110010, 8'd9};
      mem[59] = {8'b00110010, 8'd10};
      mem[60] = {8'b00110010, 8'd11};
      mem[61] = {8'b00110010, 8'd12};
      mem[62] = {8'b00110010, 8'd13};
      mem[63] = {8'b00110010, 8'd14};
      mem[64] = {8'b00111001, 8'd16};
      mem[65] = {8'b00111001, 8'd17};
      mem[66] = {8'b00111001, 8'd18};
      mem[67] = {8'b00111001, 8'd19};
      mem[68] = {8'b00111001, 8'd20};
      mem[69] = {8'b00111001, 8'd21};
      mem[70] = {8'b00111001, 8'd22};
      mem[71] = {8'b00111001, 8'd23};
      mem[72] = {8'b00111001, 8'd24};
      mem[73] = {8'b00111001, 8'd25};
      mem[74] = {8'b00111001, 8'd26};
      mem[75] = {8'b00111001, 8'd27};
      mem[76] = {8'b00111001, 8'd28};
      mem[77] = {8'b00111001, 8'd28};
      mem[78] = {8'b00111001, 8'd29};
      mem[79] = {8'b00111001, 8'd30};
      mem[80] = {8'b00111001, 8'd31};
      mem[81] = {8'b00111001, 8'd15};
      mem[82] = {8'b00111001, 8'd32};
    end
endmodule

`endif
