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
          // .define $AddrSwtch 0xFFF8
          // .define $CtrlSwtch 0xFFF9
          // .define $AddrLeds  0xFFFA
          // .define $DataLeds  0xFFFB
          // .define $RegSwtch  0xFFFC
          // .define $IoCntrLo  0xFFFD
          // .define $IoCntrHi  0xFFFE
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
      mem[1] = 16'h7300; // Start:         LDHZ R4 0x00
      mem[2] = 16'h6dff; //                LDH R3 $IoCntrLo.H
      mem[3] = 16'h6cfd; //                LDL R3 $IoCntrLo.L
      mem[4] = 16'hc980; //                LD  R2 [R3]
      mem[5] = 16'h6201; //                LDLZ R0 1
      mem[6] = 16'h6604; //                LDLZ R1 4
      mem[7] = 16'hbc0b; //                JSR DisplayReg
      mem[8] = 16'h6cfe; //                LDL R3 $IoCntrHi.L
      mem[9] = 16'hc980; //                LD R2 [R3]
      mem[10] = 16'h6201; //                LDLZ R0 1
      mem[11] = 16'h6605; //                LDLZ R1 5
      mem[12] = 16'hbc06; //                JSR DisplayReg
      mem[13] = 16'h0a08; //                LD R2 R4
      mem[14] = 16'h6201; //                LDLZ R0 1
      mem[15] = 16'h6607; //                LDLZ R1 7
      mem[16] = 16'hbc02; //                JSR DisplayReg
      mem[17] = 16'h120c; //                INC R4 R4
      mem[18] = 16'h9fee; //                JMP Start
          //
          // ; Display the value of R2 in hexadecimal format at screen column R0, and row R1
          // ; [in]   R0 = column
          // ; [in]   R1 = row
          // ; [in]   R2 = reg
      mem[19] = 16'h2c0c; // DisplayReg:    PSH R3
      mem[20] = 16'h300c; //                PSH R4
      mem[21] = 16'h340c; //                PSH R5
      mem[22] = 16'hbc1b; //                JSR GetCursorPos
      mem[23] = 16'h720f; //                LDLZ R4 0x0F
      mem[24] = 16'h090b; //                SWP R2 R2
      mem[25] = 16'h0d09; //                LDL R3 R2
      mem[26] = 16'h2d80; //                SHR R3 R3
      mem[27] = 16'h2d80; //                SHR R3 R3
      mem[28] = 16'h2d80; //                SHR R3 R3
      mem[29] = 16'h2d80; //                SHR R3 R3
      mem[30] = 16'h0dc4; //                AND R3 R3 R4
      mem[31] = 16'hbc1f; //               JSR WriteHexDigit
      mem[32] = 16'h0d09; //                LDL R3 R2
      mem[33] = 16'h0dc4; //                AND R3 R3 R4
      mem[34] = 16'hbc1c; //                JSR WriteHexDigit
      mem[35] = 16'h090b; //                SWP R2 R2
      mem[36] = 16'h0d09; //                LDL R3 R2
      mem[37] = 16'h2d80; //                SHR R3 R3
      mem[38] = 16'h2d80; //                SHR R3 R3
      mem[39] = 16'h2d80; //                SHR R3 R3
      mem[40] = 16'h2d80; //                SHR R3 R3
      mem[41] = 16'h0dc4; //                AND R3 R3 R4
      mem[42] = 16'hbc14; //               JSR WriteHexDigit
      mem[43] = 16'h0d09; //                LDL R3 R2
      mem[44] = 16'h0dc4; //                AND R3 R3 R4
      mem[45] = 16'hbc11; //                JSR WriteHexDigit
      mem[46] = 16'h340d; //                POP R5
      mem[47] = 16'h300d; //                POP R4
      mem[48] = 16'h2c0d; //                POP R3
      mem[49] = 16'h3c0d; //                RET
          //
          // ; Get the address of screen column R0, row R1
          // ; [in]   R0 = column
          // ; [in]   R1 = row
          // ; [out]  R5 = position
      mem[50] = 16'h2c0c; // GetCursorPos:  PSH R3
      mem[51] = 16'h7780; //                LDHZ R5 $FrameBuf.H
      mem[52] = 16'h0c88; //                LD R3  R1 ; Multiply row by 40
      mem[53] = 16'h2d81; //                SHL R3 R3
      mem[54] = 16'h2d81; //                SHL R3 R3
      mem[55] = 16'h2d81; //                SHL R3 R3
      mem[56] = 16'h16b0; //                ADD R5 R5 R3
      mem[57] = 16'h2d81; //                SHL R3 R3
      mem[58] = 16'h2d81; //                SHL R3 R3
      mem[59] = 16'h16b0; //                ADD R5 R5 R3
      mem[60] = 16'h1680; //                ADD R5 R5 R0 ; Add column
      mem[61] = 16'h2c0d; //                POP R3
      mem[62] = 16'h3c0d; //                RET
          //
          // ; Write hex digit R3 at position R5 to screen
          // ; [in]   R5 = pos
          // ; [in]   R3 = hex digit
      mem[63] = 16'h300c; // WriteHexDigit: PSH R4
      mem[64] = 16'h720a; //                LDLZ R4 10
      mem[65] = 16'h01ce; //                CMP R3 R4
      mem[66] = 16'h4783; //                BCC NotDecimal
      mem[67] = 16'h7230; //                LDLZ R4 '0'
      mem[68] = 16'h0dc0; //                ADD R3 R3 R4
      mem[69] = 16'h9c02; //                JMP StoreDigit
      mem[70] = 16'h7237; // NotDecimal:    LDLZ R4 'A' - 10
      mem[71] = 16'h0dc0; //                ADD R3 R3 R4
      mem[72] = 16'h6d3c; // StoreDigit:    LDH R3 $BgWhite | $Red; White background red text
      mem[73] = 16'hee80; //                STO R3 [R5]
      mem[74] = 16'h168c; //                INC R5 R5
      mem[75] = 16'h300d; //                POP R4
      mem[76] = 16'h3c0d; //                RET
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
