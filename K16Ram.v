`ifndef K16RAM_V
`define K16RAM_V

module K16SinglePortRam (din, addr, write_en, clk, dout);// 1024x16
  parameter addr_width = 10;
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
    // .define $IoCntrLo  0xFFFD
    // .define $IoCntrHi  0xFFFE
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
mem[0] = 16'h9c23; //                JMP Start
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
mem[34] = 16'h0000; // .data 0
mem[35] = 16'h0000; // .data 0
    //
mem[36] = 16'h7b01; // Start:         LDHZ SP 0x01 ; Set SP to 0x0100
mem[37] = 16'h6220; //                LDLZ R0 ' '
mem[38] = 16'h661d; //                LDLZ R1 $BgCyan | $Magenta
mem[39] = 16'hbc37; //                JSR FillScreen
    //
    //                ; Display labels
mem[40] = 16'h6201; // Loop:          LDLZ R0 0x01; column 1
mem[41] = 16'h6601; //                LDLZ R1 0x01; row 1
mem[42] = 16'h6a01; //                LDLZ R2 AddrSwString.L
mem[43] = 16'hbc63; //                JSR DisplayString
    //
mem[44] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[45] = 16'h6602; //                LDLZ R1 0x02; row 2
mem[46] = 16'h6a0a; //                LDLZ R2 CtrlSwString.L
mem[47] = 16'hbc5f; //                JSR DisplayString
    //
mem[48] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[49] = 16'h6603; //                LDLZ R1 0x03; row 3
mem[50] = 16'h6a13; //                LDLZ R2 RegSwString.L
mem[51] = 16'hbc5b; //                JSR DisplayString
    //
mem[52] = 16'h6201; //                LDLZ R0 0x01; column 1
mem[53] = 16'h6604; //                LDLZ R1 0x04; row 4
mem[54] = 16'h6a1d; //                LDLZ R2 CounterString.L
mem[55] = 16'hbc57; //                JSR DisplayString
    //
    //                ; Display address switch settings on screen
mem[56] = 16'h6cf8; //                LDL R3 $AddrSwtch.L
mem[57] = 16'h6dff; //                LDH R3 $AddrSwtch.H
mem[58] = 16'hc980; //                LD R2 [R3]
mem[59] = 16'h6214; //                LDLZ R0 20; column 1
mem[60] = 16'h6601; //                LDLZ R1 1;  row 1
mem[61] = 16'hbc32; //                JSR DisplayReg
    //                ; Display address switch settings on LEDs
mem[62] = 16'h6cfa; //                LDL R3 $AddrLeds.L
mem[63] = 16'h6dff; //                LDH R3 $AddrLeds.H
mem[64] = 16'he980; //                STO R2 [R3]
    //
    //                ; Display control switch settings on screen
mem[65] = 16'h6cf9; //                LDL R3 $CtrlSwtch.L
mem[66] = 16'h6dff; //                LDH R3 $CtrlSwtch.H
mem[67] = 16'hc980; //                LD R2 [R3]
mem[68] = 16'h6214; //                LDLZ R0 20; column 1
mem[69] = 16'h6602; //                LDLZ R1 2;  row 2
mem[70] = 16'hbc29; //                JSR DisplayReg
mem[71] = 16'h1109; //                LDL R4 R2
    //
    //                ; Display register switch settings on screen
mem[72] = 16'h6cfc; //                LDL R3 $RegSwtch.L
mem[73] = 16'h6dff; //                LDH R3 $RegSwtch.H
mem[74] = 16'hc980; //                LD R2 [R3]
mem[75] = 16'h6214; //                LDLZ R0 20; column 1
mem[76] = 16'h6603; //                LDLZ R1 3;  row 3
mem[77] = 16'hbc22; //                JSR DisplayReg
    //                ; Display control and register switches on LEDs
mem[78] = 16'h110a; //                LDH R4 R2
mem[79] = 16'h6cfb; //                LDL R3 $DataLeds.L
mem[80] = 16'h6dff; //                LDH R3 $DataLeds.H
mem[81] = 16'hf180; //                STO R4 [R3]
    //
    //                ; Display cycle counters on screen
mem[82] = 16'h6cfd; //                LDL R3 $IoCntrLo.L
mem[83] = 16'h6dff; //                LDH R3 $IoCntrLo.H
mem[84] = 16'hc980; //                LD R2 [R3]
mem[85] = 16'h6214; //                LDLZ R0 20; column 1
mem[86] = 16'h6604; //                LDLZ R1 4;  row 4
mem[87] = 16'hbc18; //                JSR DisplayReg
    //
mem[88] = 16'h6cfe; //                LDL R3 $IoCntrHi.L
mem[89] = 16'h6dff; //                LDH R3 $IoCntrHi.H
mem[90] = 16'hc980; //                LD R2 [R3]
mem[91] = 16'h6219; //                LDLZ R0 25; column 1
mem[92] = 16'h6604; //                LDLZ R1 4;  row 4
mem[93] = 16'hbc12; //                JSR DisplayReg
    //
mem[94] = 16'h9fc9; //                JMP Loop
    // ; Fill screeen
    // ; [in] R0 = character
    // ; [in] R1 = color
mem[95] = 16'h280c; // FillScreen:    PSH R2
mem[96] = 16'h2c0c; //                PSH R3
mem[97] = 16'h300c; //                PSH R4
mem[98] = 16'h0809; //                LDL R2 R0 ; combine character and color
mem[99] = 16'h088a; //                LDH R2 R1
mem[100] = 16'h6f80; //                LDHZ R3 $FrameBuf.H ; Start address
mem[101] = 16'h70b0; //                LDL R4 (30 * 40).L  ; end address + 1
mem[102] = 16'h7104; //                LDH R4 (30 * 40).H
mem[103] = 16'h1230; //                ADD R4 R4 R3
mem[104] = 16'he980; // CharacterLoop: STO R2 [R3]
mem[105] = 16'h0d8c; //                INC R3 R3
mem[106] = 16'h01ce; //                CMP R3 R4
mem[107] = 16'h4ffc; //                BZC CharacterLoop
mem[108] = 16'h300d; //                POP R4
mem[109] = 16'h2c0d; //                POP R3
mem[110] = 16'h280d; //                POP R2
mem[111] = 16'h3c0d; //                RET
    //
    // ; Display the value of R2 in hexadecimal format at screen column R0, and row R1
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [in]   R2 = reg
mem[112] = 16'h2c0c; // DisplayReg:    PSH R3
mem[113] = 16'h300c; //                PSH R4
mem[114] = 16'h340c; //                PSH R5
mem[115] = 16'hbc38; //                JSR GetCursorPos
mem[116] = 16'h720f; //                LDLZ R4 0x0F
mem[117] = 16'h090b; //                SWP R2 R2
mem[118] = 16'h0d09; //                LDL R3 R2
mem[119] = 16'h2d80; //                SHR R3 R3
mem[120] = 16'h2d80; //                SHR R3 R3
mem[121] = 16'h2d80; //                SHR R3 R3
mem[122] = 16'h2d80; //                SHR R3 R3
mem[123] = 16'h0dc4; //                AND R3 R3 R4
mem[124] = 16'hbc3c; //                JSR WriteHexDigit
mem[125] = 16'h0d09; //                LDL R3 R2
mem[126] = 16'h0dc4; //                AND R3 R3 R4
mem[127] = 16'hbc39; //                JSR WriteHexDigit
mem[128] = 16'h090b; //                SWP R2 R2
mem[129] = 16'h0d09; //                LDL R3 R2
mem[130] = 16'h2d80; //                SHR R3 R3
mem[131] = 16'h2d80; //                SHR R3 R3
mem[132] = 16'h2d80; //                SHR R3 R3
mem[133] = 16'h2d80; //                SHR R3 R3
mem[134] = 16'h0dc4; //                AND R3 R3 R4
mem[135] = 16'hbc31; //                JSR WriteHexDigit
mem[136] = 16'h0d09; //                LDL R3 R2
mem[137] = 16'h0dc4; //                AND R3 R3 R4
mem[138] = 16'hbc2e; //                JSR WriteHexDigit
mem[139] = 16'h340d; //                POP R5
mem[140] = 16'h300d; //                POP R4
mem[141] = 16'h2c0d; //                POP R3
mem[142] = 16'h3c0d; //                RET
    //
    // ; Write string at position R5 to screen
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [in]   R2 = address of string
mem[143] = 16'h240c; // DisplayString:     PSH R1
mem[144] = 16'h280c; //                    PSH R2
mem[145] = 16'h2c0c; //                    PSH R3
mem[146] = 16'h300c; //                    PSH R4
mem[147] = 16'h340c; //                    PSH R5
mem[148] = 16'hbc17; //                    JSR GetCursorPos
mem[149] = 16'h7100; //                    LDH R4 0x00
mem[150] = 16'h653c; //                    LDH R1 $BgWhite | $Red; White background red text
mem[151] = 16'hcd00; // DisplayStringLoop: LD  R3 [R2]
mem[152] = 16'h0d8b; //                    SWP R3 R3
mem[153] = 16'h1189; //                    LDL R4 R3
mem[154] = 16'h4b8b; //                    BZS DisplayStringDone
mem[155] = 16'h0609; //                    LDL R1 R4
mem[156] = 16'he680; //                    STO R1 [R5]
mem[157] = 16'h168c; //                    INC R5 R5
mem[158] = 16'h0d8b; //                    SWP R3 R3
mem[159] = 16'h1189; //                    LDL R4 R3
mem[160] = 16'h4b85; //                    BZS DisplayStringDone
mem[161] = 16'h0609; //                    LDL R1 R4
mem[162] = 16'he680; //                    STO R1 [R5]
mem[163] = 16'h168c; //                    INC R5 R5
mem[164] = 16'h090c; //                    INC R2 R2;
mem[165] = 16'h9ff1; //                    JMP DisplayStringLoop
mem[166] = 16'h340d; // DisplayStringDone: POP R5
mem[167] = 16'h300d; //                    POP R4
mem[168] = 16'h2c0d; //                    POP R3
mem[169] = 16'h280d; //                    POP R2
mem[170] = 16'h240d; //                    POP R1
mem[171] = 16'h3c0d; //                    RET
    //
    // ; Get the address of screen column R0, row R1
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [out]  R5 = position
mem[172] = 16'h2c0c; // GetCursorPos:  PSH R3
mem[173] = 16'h7780; //                LDHZ R5 $FrameBuf.H
mem[174] = 16'h0c88; //                LD R3  R1 ; Multiply row by 40
mem[175] = 16'h2d81; //                SHL R3 R3
mem[176] = 16'h2d81; //                SHL R3 R3
mem[177] = 16'h2d81; //                SHL R3 R3
mem[178] = 16'h16b0; //                ADD R5 R5 R3
mem[179] = 16'h2d81; //                SHL R3 R3
mem[180] = 16'h2d81; //                SHL R3 R3
mem[181] = 16'h16b0; //                ADD R5 R5 R3
mem[182] = 16'h1680; //                ADD R5 R5 R0 ; Add column
mem[183] = 16'h2c0d; //                POP R3
mem[184] = 16'h3c0d; //                RET
    //
    // ; Write hex digit R3 at position R5 to screen
    // ; [in]   R5 = pos
    // ; [in]   R3 = hex digit
mem[185] = 16'h300c; // WriteHexDigit: PSH R4
mem[186] = 16'h720a; //                LDLZ R4 10
mem[187] = 16'h01ce; //                CMP R3 R4
mem[188] = 16'h4783; //                BCC NotDecimal
mem[189] = 16'h7230; //                LDLZ R4 '0'
mem[190] = 16'h0dc0; //                ADD R3 R3 R4
mem[191] = 16'h9c02; //                JMP StoreDigit
mem[192] = 16'h7237; // NotDecimal:    LDLZ R4 'A' - 10
mem[193] = 16'h0dc0; //                ADD R3 R3 R4
mem[194] = 16'h6d3c; // StoreDigit:    LDH R3 $BgWhite | $Red; White background red text
mem[195] = 16'hee80; //                STO R3 [R5]
mem[196] = 16'h168c; //                INC R5 R5
mem[197] = 16'h300d; //                POP R4
mem[198] = 16'h3c0d; //                RET
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
