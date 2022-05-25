`include "K16Cpu.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

`define DISPLAY_PANEL $display("ADDR_SWITCHES: %04X, CTRL_SWITCHES: %04X, ADDR_LEDS: %04X, DATA_LEDS: %04X", ram[`ADDR_SWITCHES], ram[`CTRL_SWITCHES], ram[`ADDR_LEDS], ram[`DATA_LEDS]);
module test2();

reg         clk;
reg         reset;
reg         stop;
wire        hold;
wire        busy;
wire [15:0] address;
reg [15:0]  data_in;
wire [15:0] data_out;
wire        write;

always #10 clk = ~clk;

reg [15:0] a;
reg [15:0] b;
reg c;
reg [1:0] operationType;
reg [2:0] operation;
reg       aluOn;
reg       shiftOn;
reg       loadOn;
wire [15:0] r;
wire cOut;
wire zOut;
wire nOut;

K16Alu alu(.operand1(a),
           .operand2(b),
           .carryIn(c),
           .operationType(operationType),
           .operation(operation),
           .result(r),
           .carryOut(cOut),
           .zeroOut(zOut),
           .negativeOut(nOut));


K16Cpu cpu(
  .clk(clk),
  .reset(reset),
  .stop(stop),
  .hold(hold),
  .busy(busy),
  .address(address),
  .data_in(data_in),
  .data_out(data_out),
  .write(write));

  reg [15:0] ram[0:65535];

  always @(posedge clk)
    if (write) begin
      ram[address] <= data_out;
    end

  always @(posedge clk)
    data_in <= ram[address];

  initial begin
    $dumpfile("K16Cpu_tb.vcd");
    $dumpvars(1, cpu);

    ram[0] = 16'h7b01; //                LDHZ SP 0x01 ; Set SP to 0x0100
    ram[1] = 16'h7300; // Start:         LDHZ R4 0x00
    ram[2] = 16'h6dff; //                LDH R3 $IoCntrLo.H
    ram[3] = 16'h6cfd; //                LDL R3 $IoCntrLo.L
    ram[4] = 16'hc980; //                LD  R2 [R3]
    ram[5] = 16'h6201; //                LDLZ R0 1
    ram[6] = 16'h6604; //                LDLZ R1 4
    ram[7] = 16'hbc0b; //                JSR DisplayReg
    ram[8] = 16'h6cfe; //                LDL R3 $IoCntrHi.L
    ram[9] = 16'hc980; //                LD R2 [R3]
    ram[10] = 16'h6201; //                LDLZ R0 1
    ram[11] = 16'h6605; //                LDLZ R1 5
    ram[12] = 16'hbc06; //                JSR DisplayReg
    ram[13] = 16'h0a08; //                LD R2 R4
    ram[14] = 16'h6201; //                LDLZ R0 1
    ram[15] = 16'h6607; //                LDLZ R1 7
    ram[16] = 16'hbc02; //                JSR DisplayReg
    ram[17] = 16'h120c; //                INC R4 R4
    ram[18] = 16'h9fee; //                JMP Start
          //
          // ; Display the value of R2 in hexadecimal format at screen column R0, and row R1
          // ; [in]   R0 = column
          // ; [in]   R1 = row
          // ; [in]   R2 = reg
    ram[19] = 16'h2c0c; // DisplayReg:    PSH R3
    ram[20] = 16'h300c; //                PSH R4
    ram[21] = 16'h340c; //                PSH R5
    ram[22] = 16'hbc1b; //                JSR GetCursorPos
    ram[23] = 16'h720f; //                LDLZ R4 0x0F
    ram[24] = 16'h090b; //                SWP R2 R2
    ram[25] = 16'h0d09; //                LDL R3 R2
    ram[26] = 16'h2d80; //                SHR R3 R3
    ram[27] = 16'h2d80; //                SHR R3 R3
    ram[28] = 16'h2d80; //                SHR R3 R3
    ram[29] = 16'h2d80; //                SHR R3 R3
    ram[30] = 16'h0dc4; //                AND R3 R3 R4
    ram[31] = 16'hbc1f; //               JSR WriteHexDigit
    ram[32] = 16'h0d09; //                LDL R3 R2
    ram[33] = 16'h0dc4; //                AND R3 R3 R4
    ram[34] = 16'hbc1c; //                JSR WriteHexDigit
    ram[35] = 16'h090b; //                SWP R2 R2
    ram[36] = 16'h0d09; //                LDL R3 R2
    ram[37] = 16'h2d80; //                SHR R3 R3
    ram[38] = 16'h2d80; //                SHR R3 R3
    ram[39] = 16'h2d80; //                SHR R3 R3
    ram[40] = 16'h2d80; //                SHR R3 R3
    ram[41] = 16'h0dc4; //                AND R3 R3 R4
    ram[42] = 16'hbc14; //               JSR WriteHexDigit
    ram[43] = 16'h0d09; //                LDL R3 R2
    ram[44] = 16'h0dc4; //                AND R3 R3 R4
    ram[45] = 16'hbc11; //                JSR WriteHexDigit
    ram[46] = 16'h340d; //                POP R5
    ram[47] = 16'h300d; //                POP R4
    ram[48] = 16'h2c0d; //                POP R3
    ram[49] = 16'h3c0d; //                RET
          //
          // ; Get the address of screen column R0, row R1
          // ; [in]   R0 = column
          // ; [in]   R1 = row
          // ; [out]  R5 = position
    ram[50] = 16'h2c0c; // GetCursorPos:  PSH R3
    ram[51] = 16'h7780; //                LDHZ R5 $FrameBuf.H
    ram[52] = 16'h0c88; //                LD R3  R1 ; Multiply row by 40
    ram[53] = 16'h2d81; //                SHL R3 R3
    ram[54] = 16'h2d81; //                SHL R3 R3
    ram[55] = 16'h2d81; //                SHL R3 R3
    ram[56] = 16'h16b0; //                ADD R5 R5 R3
    ram[57] = 16'h2d81; //                SHL R3 R3
    ram[58] = 16'h2d81; //                SHL R3 R3
    ram[59] = 16'h16b0; //                ADD R5 R5 R3
    ram[60] = 16'h1680; //                ADD R5 R5 R0 ; Add column
    ram[61] = 16'h2c0d; //                POP R3
    ram[62] = 16'h3c0d; //                RET
          //
          // ; Write hex digit R3 at position R5 to screen
          // ; [in]   R5 = pos
          // ; [in]   R3 = hex digit
    ram[63] = 16'h300c; // WriteHexDigit: PSH R4
    ram[64] = 16'h720a; //                LDLZ R4 10
    ram[65] = 16'h01ce; //                CMP R3 R4
    ram[66] = 16'h4783; //                BCC NotDecimal
    ram[67] = 16'h7230; //                LDLZ R4 '0'
    ram[68] = 16'h0dc0; //                ADD R3 R3 R4
    ram[69] = 16'h9c02; //                JMP StoreDigit
    ram[70] = 16'h7237; // NotDecimal:    LDLZ R4 'A' - 10
    ram[71] = 16'h0dc0; //                ADD R3 R3 R4
    ram[72] = 16'h6d3c; // StoreDigit:    LDH R3 $BgWhite | $Red; White background red text
    ram[73] = 16'hee80; //                STO R3 [R5]
    ram[74] = 16'h168c; //                INC R5 R5
    ram[75] = 16'h300d; //                POP R4
    ram[76] = 16'h3c0d; //                RET

    ram[100] = 16'h0000;
    ram[101] = 16'h0000;
    ram[102] = 16'h0000;
    ram[103] = 16'h0000;
    ram[104] = 16'h0000;

    ram[`ADDR_SWITCHES] = 16'h0000;
    ram[`CTRL_SWITCHES] = 16'h0000;
    ram[`ADDR_LEDS] = 16'h0000;
    ram[`DATA_LEDS] = 16'h0000;
    ram[16'hFFFD] = 16'h0000;
    ram[16'hFFFE] = 16'h0000;

    //$monitor(".  clk=%b, reset=%b, hold=%b, busy=%b, address=%04X, data_in=%04X, data_out=%04X, write=%b", clk, reset, hold, busy, address, data_in, data_out, write);

    a = 16'h000A;
    b = 16'h000F;
    c = 1'b1;
    operation = `ADC_OP;
    operationType = `ALU_OP;
    #10;
    if (r != 16'h001A || cOut != 1'b0) $error("ERROR: ADC_OP 1");

    a = 16'hF000;
    b = 16'h1243;
    c = 1'b0;
    operation = `ADD_OP;
    operationType = `ALU_OP;
    #10
    if (r != 16'h0243 || cOut != 1'b1) $error("ERROR: ADD_OP 1");

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b0;
    operation = `SHL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h0468 || cOut != 1'b1) $error("ERROR: ASL_OP 1");

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b1;
    operation = `SHL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h0468 || cOut != 1'b1) $error("ERROR: LSL_OP 1");

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b0;
    operation = `ASHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'hC11A || cOut != 1'b0) $error("ERROR: ASHR_OP 1");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `ASHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'hC11A || cOut != 1'b1) $error("ERROR: ASR_OP 2");

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b0;
    operation = `SHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h411A || cOut != 1'b0) $error("ERROR: LSR_OP 1");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `SHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h411A || cOut != 1'b1) $error("ERROR: LSR_OP 2");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `ROL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h046A || cOut != 1'b1) $error("ERROR: ROL_OP 1");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `ROL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h046B || cOut != 1'b1) $error("ERROR: ROL_OP 2");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `ROR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h411A || cOut != 1'b1) $error("ERROR: ROL_OP 1");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `ROR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'hC11A || cOut != 1'b1) $error("ERROR: ROL_OP 2");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `NOT_OP;
    operationType = `ALU_OP;
    #10
    if (r != 16'h7DCA || cOut != 1'b0) $error("ERROR: NOT_OP");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `COPY_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h8235 || cOut != 1'b1) $error("ERROR: COPY_OP");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `SWAP_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h3582 || cOut != 1'b1) $error("ERROR: SWAP_OP");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `LDL_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h0035 || cOut != 1'b1) $error("ERROR: LDL_OP");

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `LDH_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h3500 || cOut != 1'b1) $error("ERROR: LDH_OP");

    a = 16'h2100;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDLI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h2134 || cOut != 1'b1) $error("ERROR: LDLI_OP");

    a = 16'h21FE;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDHI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h34FE || cOut != 1'b1) $error("ERROR: LDHI_OP");

    a = 16'h2100;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDLZI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h0034 || cOut != 1'b1) $error("ERROR: LDLZI_OP");

    a = 16'h21FE;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDHZI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h3400 || cOut != 1'b1) $error("ERROR: LDHZI_OP");

    #10
    reset = 1;
    clk = 0;
    #10
    reset = 0;
    clk = 1;
    #10
    clk = 0;
    #10
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `INST_STEP;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0001 ||
        ram[`DATA_LEDS] != 16'h7300)
      $error("ERROR: INST_STEP 1");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `EXAMINE;
    ram[`ADDR_SWITCHES] = 16'h0001;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0001 ||
        ram[`DATA_LEDS] != 16'h7300)
      $error("ERROR: Examine 1");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `EXAMINE_NEXT;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0002 ||
        ram[`DATA_LEDS] != 16'h6dff)
      $error("ERROR: Examine next 1");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `EXAMINE_NEXT;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0003 ||
        ram[`DATA_LEDS] != 16'h6cfd)
      $error("ERROR: Examine next 2");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `EXAMINE;
    ram[`ADDR_SWITCHES] = 100;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 100 ||
        ram[`DATA_LEDS] != 0)
      $error("ERROR: Examine 2");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `DEPOSIT;
    ram[`ADDR_SWITCHES] = 16'h1234;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 100 ||
        ram[`DATA_LEDS] != 16'h1234 ||
        ram[100] != 16'h1234)
      $error("ERROR: Deposit 1");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`CTRL_SWITCHES] = `DEPOSIT_NEXT;
    ram[`ADDR_SWITCHES] = 16'hABCD;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
        ram[`DATA_LEDS] != 16'hABCD ||
        ram[100] != 16'h1234 ||
        ram[101] != 16'hABCD)
       $error("ERROR: Deposit next 1");

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`REG_SWITCHES] = 7;
    ram[`CTRL_SWITCHES] = `EXAMINE_REGISTER;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
        ram[`DATA_LEDS] != 101)
       $error("ERROR: Examine register 1: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`REG_SWITCHES] = 0;
    ram[`ADDR_SWITCHES] = 16'hBABE;
    ram[`CTRL_SWITCHES] = `DEPOSIT_REGISTER;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
        ram[`DATA_LEDS] != 16'hBABE)
       $error("ERROR: Deposit register 1: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);

    ram[`REG_SWITCHES] = 7;
    ram[`CTRL_SWITCHES] = `EXAMINE_REGISTER;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
       ram[`DATA_LEDS] != 101)
      $error("ERROR: Examine register 2: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);

    ram[`CTRL_SWITCHES] = `NONE;
    repeat (5) @(posedge clk);
   
    ram[`REG_SWITCHES] = 0;
    ram[`CTRL_SWITCHES] = `EXAMINE_REGISTER;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
       ram[`DATA_LEDS] != 16'hBABE)
      $error("ERROR: Examine register 3: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);




    $finish;
end
endmodule
