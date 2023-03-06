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
    // .define $BPM    140
    // .define $BeatMs (60 * 1000) / $BPM
    // .define $Decay  $BeatMs / 10
    // .define $1_1    $BeatMs * 4 - $Decay
    // .define $1_2    $BeatMs * 2 - $Decay
    // .define $1_4    $BeatMs     - $Decay
    // .define $1_8    $BeatMs / 2 - $Decay
    // .define $1_16   $BeatMs / 4 - $Decay
mem[0] = 16'h9c53; // JMP Start
    //
mem[1] = 16'h03eb; // .data $G4, $1_4
mem[2] = 16'h0181;
mem[3] = 16'h04a9; // .data $E4, $1_4
mem[4] = 16'h0181;
mem[5] = 16'h04a9; // .data $E4, $1_2
mem[6] = 16'h032e;
mem[7] = 16'h0466; // .data $F4, $1_4
mem[8] = 16'h0181;
mem[9] = 16'h053b; // .data $D4, $1_4
mem[10] = 16'h0181;
mem[11] = 16'h053b; // .data $D4, $1_2
mem[12] = 16'h032e;
mem[13] = 16'h05e0; // .data $C4, $1_4
mem[14] = 16'h0181;
mem[15] = 16'h053b; // .data $D4, $1_4
mem[16] = 16'h0181;
mem[17] = 16'h04a9; // .data $E4, $1_4
mem[18] = 16'h0181;
mem[19] = 16'h0466; // .data $F4, $1_4
mem[20] = 16'h0181;
mem[21] = 16'h03eb; // .data $G4, $1_4
mem[22] = 16'h0181;
mem[23] = 16'h03eb; // .data $G4, $1_4
mem[24] = 16'h0181;
mem[25] = 16'h03eb; // .data $G4, $1_2
mem[26] = 16'h032e;
mem[27] = 16'h03eb; // .data $G4, $1_4
mem[28] = 16'h0181;
mem[29] = 16'h04a9; // .data $E4, $1_4
mem[30] = 16'h0181;
mem[31] = 16'h04a9; // .data $E4, $1_2
mem[32] = 16'h032e;
mem[33] = 16'h0466; // .data $F4, $1_4
mem[34] = 16'h0181;
mem[35] = 16'h053b; // .data $D4, $1_4
mem[36] = 16'h0181;
mem[37] = 16'h053b; // .data $D4, $1_2
mem[38] = 16'h032e;
mem[39] = 16'h05e0; // .data $C4, $1_4
mem[40] = 16'h0181;
mem[41] = 16'h04a9; // .data $E4, $1_4
mem[42] = 16'h0181;
mem[43] = 16'h03eb; // .data $G4, $1_4
mem[44] = 16'h0181;
mem[45] = 16'h03eb; // .data $G4, $1_4
mem[46] = 16'h0181;
mem[47] = 16'h05e0; // .data $C4, $1_1
mem[48] = 16'h0687;
mem[49] = 16'h0000; // .data    0,   0
mem[50] = 16'h0000;
mem[51] = 16'h4164; // .string "Address switches:"
mem[52] = 16'h6472;
mem[53] = 16'h6573;
mem[54] = 16'h7320;
mem[55] = 16'h7377;
mem[56] = 16'h6974;
mem[57] = 16'h6368;
mem[58] = 16'h6573;
mem[59] = 16'h3a00;
mem[60] = 16'h436f; // .string "Control switches:"
mem[61] = 16'h6e74;
mem[62] = 16'h726f;
mem[63] = 16'h6c20;
mem[64] = 16'h7377;
mem[65] = 16'h6974;
mem[66] = 16'h6368;
mem[67] = 16'h6573;
mem[68] = 16'h3a00;
mem[69] = 16'h5265; // .string "Register switches:"
mem[70] = 16'h6769;
mem[71] = 16'h7374;
mem[72] = 16'h6572;
mem[73] = 16'h2073;
mem[74] = 16'h7769;
mem[75] = 16'h7463;
mem[76] = 16'h6865;
mem[77] = 16'h733a;
mem[78] = 16'h0000;
mem[79] = 16'h436f; // .string "Counter:"
mem[80] = 16'h756e;
mem[81] = 16'h7465;
mem[82] = 16'h723a;
mem[83] = 16'h0000;
    //
mem[84] = 16'h7b01; // Start:         LDHZ SP 0x01 ; Set SP to 0x0100¨
mem[85] = 16'h6220; //                LDLZ R0 ' '
mem[86] = 16'h6608; //                LDLZ R1 $BgBlue
mem[87] = 16'h7400; //                LDL R5 Library.L
mem[88] = 16'h75f0; //                LDH R5 Library.H
    //                ;JMP Loop
mem[89] = 16'hb44f; //                JSR [R5 + (FillScreen-Library)] ; FillScreen - Library]
mem[90] = 16'h6401; //                LDL R1 Hans.L
mem[91] = 16'h6500; //                LDH R1 Hans.H
mem[92] = 16'h68ff; //                LDL R2 $Sound.L
mem[93] = 16'h69ff; //                LDH R2 $Sound.H
mem[94] = 16'hcc80; // SoundLoop:          LD R3 [R1] ; Frequency in R3
mem[95] = 16'h048c; //                INC R1 R1
mem[96] = 16'hc080; //                LD R0 [R1] ; Duration in R0
mem[97] = 16'h4b88; //                BZS Loop
mem[98] = 16'hed00; //                STO R3 [R2]
mem[99] = 16'hb400; //                JSR [R5 + (Sleep-Library)]
mem[100] = 16'h6e00; //                LDLZ R3 0
mem[101] = 16'hed00; //                STO R3 [R2]
mem[102] = 16'h6232; //                LDLZ R0 50
mem[103] = 16'hb400; //                JSR [R5 + (Sleep-Library)]
mem[104] = 16'h048c; //                INC R1 R1
mem[105] = 16'h9ff4; //                JMP SoundLoop
    //
    //                ; Display labels
mem[106] = 16'h6201; // Loop:          LDLZ R0 0x01; column 1
mem[107] = 16'h6601; //                LDLZ R1 0x01; row 1
mem[108] = 16'h6a33; //                LDLZ R2 AddrSwString.L
mem[109] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
mem[110] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[111] = 16'h6602; //                LDLZ R1 0x02; row 2
mem[112] = 16'h6a3c; //                LDLZ R2 CtrlSwString.L
mem[113] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
mem[114] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[115] = 16'h6603; //                LDLZ R1 0x03; row 3
mem[116] = 16'h6a45; //                LDLZ R2 RegSwString.L
mem[117] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
mem[118] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[119] = 16'h6604; //                LDLZ R1 0x04; row 4
mem[120] = 16'h6a4f; //                LDLZ R2 CounterString.L
mem[121] = 16'hb47f; //                JSR [R5 + (DisplayString-Library)]
    //
    //                ; Display address switch settings on screen
mem[122] = 16'h6cf8; //                LDL R3 $AddrSwtch.L
mem[123] = 16'h6dff; //                LDH R3 $AddrSwtch.H
mem[124] = 16'hc980; //                LD R2 [R3]
mem[125] = 16'h6214; //                LDLZ R0 20; column 1
mem[126] = 16'h6601; //                LDLZ R1 1;  row 1
mem[127] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
    //                ; Display address switch settings on LEDs
mem[128] = 16'h6cfa; //                LDL R3 $AddrLeds.L
mem[129] = 16'h6dff; //                LDH R3 $AddrLeds.H
mem[130] = 16'he980; //                STO R2 [R3]
    //
    //                ; Display control switch settings on screen
mem[131] = 16'h6cf9; //                LDL R3 $CtrlSwtch.L
mem[132] = 16'h6dff; //                LDH R3 $CtrlSwtch.H
mem[133] = 16'hc980; //                LD R2 [R3]
mem[134] = 16'h6214; //                LDLZ R0 20; column 1
mem[135] = 16'h6602; //                LDLZ R1 2;  row 2
mem[136] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
mem[137] = 16'h1109; //                LDL R4 R2
    //
    //                ; Display register switch settings on screen
mem[138] = 16'h6cfc; //                LDL R3 $RegSwtch.L
mem[139] = 16'h6dff; //                LDH R3 $RegSwtch.H
mem[140] = 16'hc980; //                LD R2 [R3]
mem[141] = 16'h6214; //                LDLZ R0 20; column 1
mem[142] = 16'h6603; //                LDLZ R1 3;  row 3
mem[143] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //                ; Display control and register switches on LEDs
mem[144] = 16'h110a; //                LDH R4 R2
mem[145] = 16'h6cfb; //                LDL R3 $DataLeds.L
mem[146] = 16'h6dff; //                LDH R3 $DataLeds.H
mem[147] = 16'hf180; //                STO R4 [R3]
    //
    //                ; Display cycle counters on screen
mem[148] = 16'h6cfe; //                LDL R3 $IoCntrLo.L
mem[149] = 16'h6dff; //                LDH R3 $IoCntrLo.H
mem[150] = 16'hc980; //                LD R2 [R3]
mem[151] = 16'h6214; //                LDLZ R0 20; column 1
mem[152] = 16'h6604; //                LDLZ R1 4;  row 4
mem[153] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
mem[154] = 16'h6cfd; //                LDL R3 $IoCntrHi.L
mem[155] = 16'h6dff; //                LDH R3 $IoCntrHi.H
mem[156] = 16'hc980; //                LD R2 [R3]
mem[157] = 16'h6219; //                LDLZ R0 25; column 1
mem[158] = 16'h6604; //                LDLZ R1 4;  row 4
mem[159] = 16'hb460; //                JSR [R5 + (DisplayReg-Library)]
    //
mem[160] = 16'h9fc9; //                JMP Loop
    //
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
