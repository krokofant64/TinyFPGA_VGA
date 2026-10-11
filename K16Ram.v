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
    // .define $AddrSwtch 0xFFF8
    // .define $CtrlSwtch 0xFFF9
    // .define $AddrLeds  0xFFFA
    // .define $DataLeds  0xFFFB
    // .define $RegSwtch  0xFFFC
    // .define $IoCntrHi  0xFFFD
    // .define $IoCntrLo  0xFFFE
    //
    // .define $FrameBuf  0x8000
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
mem[0] = 16'h7b01; //                LDHZ SP 0x01 ; Set SP to 0x0100
mem[1] = 16'h6200; //                LDLZ R0 $Black
mem[2] = 16'hbc5f; //                JSR FillPixelScreen
    //
mem[3] = 16'h7208; //                LDLZ R4 8
mem[4] = 16'h6200; // Start:         LDLZ R0 0x00
mem[5] = 16'h6600; //                LDLZ R1 0x00
mem[6] = 16'h6a00; //                LDLZ R2 0
mem[7] = 16'h6e3c; //                LDLZ R3 60
mem[8] = 16'hbc16; // DrawLoop1:     JSR DrawVline;
mem[9] = 16'h000c; //                INC R0 R0
mem[10] = 16'h090c; //                INC R2 R2
mem[11] = 16'h014e; //                CMP R2 R4
mem[12] = 16'h4ffb; //                BZC DrawLoop1
mem[13] = 16'h6200; //                LDLZ R0 0
mem[14] = 16'h6a00; //                LDLZ R2 0
mem[15] = 16'h6e50; //                LDLZ R3 80
mem[16] = 16'hbc05; // DrawLoop2:     JSR DrawHline
mem[17] = 16'h048c; //                INC R1 R1
mem[18] = 16'h090c; //                INC R2 R2
mem[19] = 16'h014e; //                CMP R2 R4
mem[20] = 16'h4ffb; //                BZC DrawLoop2
mem[21] = 16'h9fee; //                JMP Start
    //
    // ; Draw horizontal line
    // ; [in] R0 = x
    // ; [in] R1 = y
    // ; [in] R2 = color
    // ; [in] R3 = length
mem[22] = 16'h200c; // DrawHline:     PSH R0
mem[23] = 16'h2c0c; //                PSH R3
mem[24] = 16'hbc0f; // DrawHlineLoop: JSR DrawPixel
mem[25] = 16'h000c; //                INC R0 R0
mem[26] = 16'h0d8f; //                DEC R3 R3
mem[27] = 16'h4ffc; //                BZC DrawHlineLoop
mem[28] = 16'h2c0d; //                POP R3
mem[29] = 16'h200d; //                POP R0
mem[30] = 16'h3c0d; //                RET
    // ; Draw vertical line
    // ; [in] R0 = x
    // ; [in] R1 = y
    // ; [in] R2 = color
    // ; [in] R3 = length
mem[31] = 16'h240c; // DrawVline:     PSH R1
mem[32] = 16'h2c0c; //                PSH R3
mem[33] = 16'hbc06; // DrawVlineLoop: JSR DrawPixel
mem[34] = 16'h048c; //                INC R1 R1
mem[35] = 16'h0d8f; //                DEC R3 R3
mem[36] = 16'h4ffc; //                BZC DrawVlineLoop
mem[37] = 16'h2c0d; //                POP R3
mem[38] = 16'h240d; //                POP R1
mem[39] = 16'h3c0d; //                RET
    // ; Draw pixel
    // ; [in] R0 = x
    // ; [in] R1 = y
    // ; [in] R2 = color
mem[40] = 16'h200c; // DrawPixel:     PSH R0
mem[41] = 16'h240c; //                PSH R1
mem[42] = 16'h280c; //                PSH R2
mem[43] = 16'h2c0c; //                PSH R3
mem[44] = 16'h300c; //                PSH R4
mem[45] = 16'h340c; //                PSH R5
    //
    //                ; Calculate color map address
mem[46] = 16'h6c49; //                LDL R3 ColorMap.L
mem[47] = 16'h6d00; //                LDH R3 ColorMap.H
mem[48] = 16'h0930; //                ADD R2 R2 R3
mem[49] = 16'hc900; //                LD R2 [R2]
    //
mem[50] = 16'h6e00; //                LDLZ R3 0
mem[51] = 16'h2480; //                SHR R1 R1 ;
mem[52] = 16'h2d84; //                ROL R3 R3
mem[53] = 16'h2000; //                SHR R0 R0
mem[54] = 16'h2d84; //                ROL R3 R3
    //
mem[55] = 16'h7051; //                LDL R4 PixelMask.L
mem[56] = 16'h7100; //                LDH R4 PixelMask.H
mem[57] = 16'h0dc0; //                ADD R3 R3 R4
mem[58] = 16'hcd80; //                LD R3 [R3]
mem[59] = 16'h0934; //                AND R2 R2 R3
mem[60] = 16'h0d87; //                NOT R3 R3
mem[61] = 16'hbc17; //                JSR GetCursorPos
mem[62] = 16'hd280; //                LD R4 [R5]
mem[63] = 16'h1234; //                AND R4 R4 R3
mem[64] = 16'h1225; //                OR R4 R4 R2
mem[65] = 16'hf280; //                STO R4 [R5]
    //
mem[66] = 16'h340d; //                POP R5
mem[67] = 16'h300d; //                POP R4
mem[68] = 16'h2c0d; //                POP R3
mem[69] = 16'h280d; //                POP R2
mem[70] = 16'h240d; //                POP R1
mem[71] = 16'h200d; //                POP R0
mem[72] = 16'h3c0d; //                RET
    // ColorMap:
mem[73] = 16'h8000; // .data $Black   | ($Black << 3)   | ($Black << 6)   | ($Black << 9)   | 0x8000
mem[74] = 16'h8249; // .data $Blue    | ($Blue << 3)    | ($Blue << 6)    | ($Blue << 9)    | 0x8000
mem[75] = 16'h8492; // .data $Green   | ($Green << 3)   | ($Green << 6)   | ($Green << 9)   | 0x8000
mem[76] = 16'h86db; // .data $Cyan    | ($Cyan << 3)    | ($Cyan << 6)    | ($Cyan << 9)    | 0x8000
mem[77] = 16'h8924; // .data $Red     | ($Red << 3)     | ($Red << 6)     | ($Red << 9)     | 0x8000
mem[78] = 16'h8b6d; // .data $Magenta | ($Magenta << 3) | ($Magenta << 6) | ($Magenta << 9) | 0x8000
mem[79] = 16'h8db6; // .data $Yellow  | ($Yellow << 3)  | ($Yellow << 6)  | ($Yellow << 9)  | 0x8000
mem[80] = 16'h8fff; // .data $White   | ($White << 3)   | ($White << 6)   | ($White << 9)   | 0x8000
    //
    // PixelMask:
mem[81] = 16'h8007; // .data 0x0007      | 0x8000
mem[82] = 16'h8038; // .data 0x0007 << 3 | 0x8000
mem[83] = 16'h81c0; // .data 0x0007 << 6 | 0x8000
mem[84] = 16'h8e00; // .data 0x0007 << 9 | 0x8000
    //
    // ; Calculate cursor position
    // ; [in]   R0 = column
    // ; [in]   R1 = row
    // ; [out]  R5 = position
mem[85] = 16'h2c0c; // GetCursorPos:  PSH R3
mem[86] = 16'h7780; //                LDHZ R5 $FrameBuf.H
mem[87] = 16'h0c88; //                LD R3  R1 ; Multiply row by 40
mem[88] = 16'h2d81; //                SHL R3 R3
mem[89] = 16'h2d81; //                SHL R3 R3
mem[90] = 16'h2d81; //                SHL R3 R3
mem[91] = 16'h16b0; //                ADD R5 R5 R3
mem[92] = 16'h2d81; //                SHL R3 R3
mem[93] = 16'h2d81; //                SHL R3 R3
mem[94] = 16'h16b0; //                ADD R5 R5 R3
mem[95] = 16'h1680; //                ADD R5 R5 R0 ; Add column
mem[96] = 16'h2c0d; //                POP R3
mem[97] = 16'h3c0d; //                RET
    // ; Fill pixel screen with a color
    // ; [in] R0 = color
mem[98] = 16'h280c; // FillPixelScreen: PSH R2
mem[99] = 16'h2c0c; //                  PSH R3
mem[100] = 16'h300c; //                  PSH R4
    //
    //                  ; Calculate color map address
mem[101] = 16'h6849; //                  LDL R2 ColorMap.L
mem[102] = 16'h6900; //                  LDH R2 ColorMap.H
mem[103] = 16'h0900; //                  ADD R2 R2 R0
    //
    //                  ; Load R2 with pixel block color
mem[104] = 16'hc900; //                  LD R2 [R2]
    //
mem[105] = 16'h6f80; //                  LDHZ R3 $FrameBuf.H ; Start address
mem[106] = 16'h70b0; //                  LDL R4 (30 * 40).L  ; end address + 1
mem[107] = 16'h7104; //                  LDH R4 (30 * 40).H
mem[108] = 16'h1230; //                  ADD R4 R4 R3
mem[109] = 16'he980; // PixelBlockLoop:  STO R2 [R3]
mem[110] = 16'h0d8c; //                  INC R3 R3
mem[111] = 16'h01ce; //                  CMP R3 R4
mem[112] = 16'h4ffc; //                  BZC PixelBlockLoop
mem[113] = 16'h300d; //                  POP R4
mem[114] = 16'h2c0d; //                  POP R3
mem[115] = 16'h280d; //                  POP R2
mem[116] = 16'h3c0d; //                  RET
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
