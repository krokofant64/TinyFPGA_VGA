`include "K16Cpu.v"
`include "K16Io.v"

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

reg [2:0]   io_addr_in;
reg [15:0]  io_din;
reg         io_write_en;
wire [15:0] io_dout;
wire        io_stop;
wire        io_reset;
wire [3:0]  io_leds;
wire        io_clk_out;
wire [2:0]  io_addr_out;
reg  [3:0]  io_switches;
reg  [2:0]  io_reg_switches;
wire        io_sound;

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

K16Alu alu(.operand1(a),
           .operand2(b),
           .carryIn(c),
           .operationType(operationType),
           .operation(operation),
           .result(r),
           .carryOut(cOut),
           .zeroOut(zOut),
           .negativeOut(nOut));

K16Io io(
   .din(io_din),
   .addr(io_addr_in),
   .write_en(io_write_en),
   .clk(clk),
   .dout(io_dout),
   .stop(io_stop),
   .reset(io_reset),
   .io_leds(io_leds),
   .io_clk(io_clk_out),
   .io_addr(io_addr_out),
   .io_switches(io_switches),
   .io_reg_switches(io_reg_switches),
   .sound(io_sound));

  reg [15:0] ram[0:65535];

  always @(posedge clk)
    if (write) begin
      ram[address] <= data_out;
    end

  always @(posedge clk)
    data_in <= ram[address];

  initial begin
    $dumpfile("K16Cpu_tb.vcd");
    $dumpvars(1, cpu, io);

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

    ram[`ADDR_SWITCHES]        = 16'h0000;
    ram[`CTRL_SWITCHES]        = 16'h0000;
    ram[`ADDR_LEDS]            = 16'h0000;
    ram[`DATA_LEDS]            = 16'h0000;
    ram[`CMD_AND_REG_SWITCHES] = 16'h0000;
    ram[16'hFFFD]              = 16'h0000;
    ram[16'hFFFE]              = 16'h0000;

    //$monitor(".  clk=%b, reset=%b, hold=%b, busy=%b, address=%04X, data_in=%04X, data_out=%04X, write=%b", clk, reset, hold, busy, address, data_in, data_out, write);

    a = 16'h000A;
    b = 16'h000F;
    c = 1'b1;
    operation = `ADC_OP;
    operationType = `ALU_OP;
    #10;
    if (r != 16'h001A || cOut != 1'b0)
      begin
        $error("ERROR: ADC_OP 1");
        $finish;
      end

    a = 16'hF000;
    b = 16'h1243;
    c = 1'b0;
    operation = `ADD_OP;
    operationType = `ALU_OP;
    #10
    if (r != 16'h0243 || cOut != 1'b1)
      begin
        $error("ERROR: ADD_OP 1");
        $finish;
      end

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b0;
    operation = `SHL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h0468 || cOut != 1'b1)
      begin
        $error("ERROR: ASL_OP 1");
        $finish;
      end

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b1;
    operation = `SHL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h0468 || cOut != 1'b1)
      begin
        $error("ERROR: LSL_OP 1");
        $finish;
      end

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b0;
    operation = `ASHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'hC11A || cOut != 1'b0)
      begin
        $error("ERROR: ASHR_OP 1");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `ASHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'hC11A || cOut != 1'b1)
      begin
        $error("ERROR: ASR_OP 2");
        $finish;
      end

    a = 16'h8234;
    b = 16'h0000;
    c = 1'b0;
    operation = `SHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h411A || cOut != 1'b0)
      begin
        $error("ERROR: LSR_OP 1");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `SHR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h411A || cOut != 1'b1)
      begin
        $error("ERROR: LSR_OP 2");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `ROL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h046A || cOut != 1'b1)
      begin
        $error("ERROR: ROL_OP 1");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `ROL_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h046B || cOut != 1'b1)
      begin
        $error("ERROR: ROL_OP 2");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `ROR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'h411A || cOut != 1'b1)
      begin
        $error("ERROR: ROL_OP 1");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `ROR_OP;
    operationType = `SHIFT_OP;
    #10
    if (r != 16'hC11A || cOut != 1'b1)
      begin
        $error("ERROR: ROL_OP 2");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b0;
    operation = `NOT_OP;
    operationType = `ALU_OP;
    #10
    if (r != 16'h7DCA || cOut != 1'b0)
      begin
        $error("ERROR: NOT_OP");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `COPY_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h8235 || cOut != 1'b1)
      begin
        $error("ERROR: COPY_OP");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `SWAP_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h3582 || cOut != 1'b1)
      begin
        $error("ERROR: SWAP_OP");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `LDL_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h0035 || cOut != 1'b1)
      begin
        $error("ERROR: LDL_OP");
        $finish;
      end

    a = 16'h8235;
    b = 16'h0000;
    c = 1'b1;
    operation = `LDH_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h3500 || cOut != 1'b1)
      begin
        $error("ERROR: LDH_OP");
        $finish;
      end

    a = 16'h2100;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDLI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h2134 || cOut != 1'b1)
      begin
        $error("ERROR: LDLI_OP");
        $finish;
      end

    a = 16'h21FE;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDHI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h34FE || cOut != 1'b1)
      begin
        $error("ERROR: LDHI_OP");
        $finish;
      end

    a = 16'h2100;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDLZI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h0034 || cOut != 1'b1)
      begin
        $error("ERROR: LDLZI_OP");
        $finish;
      end

    a = 16'h21FE;
    b = 16'h1234;
    c = 1'b1;
    operation = `LDHZI_OP;
    operationType = `LOAD_OP;
    #10
    if (r != 16'h3400 || cOut != 1'b1)
      begin
        $error("ERROR: LDHZI_OP");
        $finish;
      end

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

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `INST_STEP << 3;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0001 ||
        ram[`DATA_LEDS] != 16'h7300)
      begin
        $error("ERROR: INST_STEP 1");
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE << 3;
    ram[`ADDR_SWITCHES] = 16'h0001;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0001 ||
        ram[`DATA_LEDS] != 16'h7300)
      begin
        $error("ERROR: Examine 1");
        $finish;
      end;

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE_NEXT << 3;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0002 ||
        ram[`DATA_LEDS] != 16'h6dff)
      begin
        $error("ERROR: Examine next 1");
        $finish;
      end;

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE_NEXT << 3;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 16'h0003 ||
        ram[`DATA_LEDS] != 16'h6cfd)
      begin
        $error("ERROR: Examine next 2");
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE << 3;
    ram[`ADDR_SWITCHES] = 100;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 100 ||
        ram[`DATA_LEDS] != 0)
      begin
        $error("ERROR: Examine 2");
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `DEPOSIT << 3;
    ram[`ADDR_SWITCHES] = 16'h1234;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 100 ||
        ram[`DATA_LEDS] != 16'h1234 ||
        ram[100] != 16'h1234)
      begin
        $error("ERROR: Deposit 1");
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `DEPOSIT_NEXT << 3;
    ram[`ADDR_SWITCHES] = 16'hABCD;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
        ram[`DATA_LEDS] != 16'hABCD ||
        ram[100] != 16'h1234 ||
        ram[101] != 16'hABCD)
       begin
         $error("ERROR: Deposit next 1");
         $finish;
       end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE_REGISTER << 3 | 7;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
        ram[`DATA_LEDS] != 101)
      begin
        $error("ERROR: Examine register 1: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`ADDR_SWITCHES] = 16'hBABE;
    ram[`CMD_AND_REG_SWITCHES] = `DEPOSIT_REGISTER << 3 | 0;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
        ram[`DATA_LEDS] != 16'hBABE)
      begin
        $error("ERROR: Deposit register 1: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE_REGISTER << 3 | 7;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
       ram[`DATA_LEDS] != 101)
      begin
        $error("ERROR: Examine register 2: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);
        $finish;
      end

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `EXAMINE_REGISTER << 3 | 0;
    repeat (20) @(posedge clk);
    if (ram[`ADDR_LEDS] != 101 ||
       ram[`DATA_LEDS] != 16'hBABE)
      begin
        $error("ERROR: Examine register 3: ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);
        $finish;
      end

    ram[0] = 16'h7b02; //                LDHZ SP 0x02 ; Set SP to 0x0200
    ram[1] = 16'h9c01; //                JMP Start
                       //
    ram[2] = 16'h0000; // .data 0
                       //
    ram[3] = 16'h7495; // Start:         LDL R5 Error.L
    ram[4] = 16'h7500; //                LDH R5 Error.H
                       //
    ram[5] = 16'h649a; //                LDL R1 Operand1_1.L     ; Test ADD
    ram[6] = 16'h6500; //                LDH R1 Operand1_1.H
    ram[7] = 16'hc480; //                LD R1 [R1]
    ram[8] = 16'h689b; //                LDL R2 Operand2_1.L
    ram[9] = 16'h6900; //                LDH R2 Operand2_1.H
    ram[10] = 16'hc900; //                LD R2 [R2]
    ram[11] = 16'h2009; //                SEC
    ram[12] = 16'h0ca0; //                ADD R3 R1 R2
    ram[13] = 16'h709e; //                LDL R4 Result_Add_1.L
    ram[14] = 16'h7100; //                LDH R4 Result_Add_1.H
    ram[15] = 16'hd200; //                LD R4 [R4]
    ram[16] = 16'h01ce; //                CMP R3 R4
    ram[17] = 16'h4e80; //                BZC [R5]
                       //
    ram[18] = 16'h2008; //                CLC                     ; Test ADC - Carry 0
    ram[19] = 16'h0ca1; //                ADC R3 R1 R2
    ram[20] = 16'h709e; //                LDL R4 Result_Add_1.L
    ram[21] = 16'h7100; //                LDH R4 Result_Add_1.H
    ram[22] = 16'hd200; //                LD R4 [R4]
    ram[23] = 16'h01ce; //                CMP R3 R4
    ram[24] = 16'h4e80; //                BZC [R5]
                       //
    ram[25] = 16'h2009; //                SEC                     ; Test ADC - Carry 1
    ram[26] = 16'h0ca1; //                ADC R3 R1 R2
    ram[27] = 16'h709f; //                LDL R4 Result_Add_2.L
    ram[28] = 16'h7100; //                LDH R4 Result_Add_2.H
    ram[29] = 16'hd200; //                LD R4 [R4]
    ram[30] = 16'h01ce; //                CMP R3 R4
    ram[31] = 16'h4e80; //                BZC [R5]
                       //
    ram[32] = 16'h2009; //                SEC                     ; Test SUB
    ram[33] = 16'h0ca2; //                SUB R3 R1 R2
    ram[34] = 16'h70a0; //                LDL R4 Result_Sub_1.L
    ram[35] = 16'h7100; //                LDH R4 Result_Sub_1.H
    ram[36] = 16'hd200; //                LD R4 [R4]
    ram[37] = 16'h01ce; //                CMP R3 R4
    ram[38] = 16'h4e80; //                BZC [R5]
                       //
    ram[39] = 16'h2008; //                CLC                     ; Test SBC - Carry 0
    ram[40] = 16'h0ca3; //                SBC R3 R1 R2
    ram[41] = 16'h70a0; //                LDL R4 Result_Sub_1.L
    ram[42] = 16'h7100; //                LDH R4 Result_Sub_1.H
    ram[43] = 16'hd200; //                LD R4 [R4]
    ram[44] = 16'h01ce; //                CMP R3 R4
    ram[45] = 16'h4e80; //                BZC [R5]
                       //
    ram[46] = 16'h2009; //                SEC                     ; Test SBC - Carry 1
    ram[47] = 16'h0ca3; //                SBC R3 R1 R2
    ram[48] = 16'h70a1; //                LDL R4 Result_Sub_2.L
    ram[49] = 16'h7100; //                LDH R4 Result_Sub_2.H
    ram[50] = 16'hd200; //                LD R4 [R4]
    ram[51] = 16'h01ce; //                CMP R3 R4
    ram[52] = 16'h4e80; //                BZC [R5]
                       //
    ram[53] = 16'h649a; //                LDL R1 Operand1_1.L     ; Test LD
    ram[54] = 16'h6500; //                LDH R1 Operand1_1.H
    ram[55] = 16'hc480; //                LD R1 [R1]
    ram[56] = 16'h0888; //                LD R2 R1
    ram[57] = 16'h709a; //                LDL R4 Operand1_1.L
    ram[58] = 16'h7100; //                LDH R4 Operand1_1.H
    ram[59] = 16'hd200; //                LD R4 [R4]
    ram[60] = 16'h014e; //                CMP R2 R4
    ram[61] = 16'h4e80; //                BZC [R5]
                       //
    ram[62] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test LDL
    ram[63] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[64] = 16'hc480; //                LD R1 [R1]
    ram[65] = 16'h689d; //                LDL R2 Operand2_2.L
    ram[66] = 16'h6900; //                LDH R2 Operand2_2.H
    ram[67] = 16'hc900; //                LD R2 [R2]
    ram[68] = 16'h0509; //                LDL R1 R2
    ram[69] = 16'h70a2; //                LDL R4 Result_Ldl_1.L
    ram[70] = 16'h7100; //                LDH R4 Result_Ldl_1.H
    ram[71] = 16'hd200; //                LD R4 [R4]
    ram[72] = 16'h00ce; //                CMP R1 R4
    ram[73] = 16'h4e80; //                BZC [R5]
                       //
    ram[74] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test LDH
    ram[75] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[76] = 16'hc480; //                LD R1 [R1]
    ram[77] = 16'h689d; //                LDL R2 Operand2_2.L
    ram[78] = 16'h6900; //                LDH R2 Operand2_2.H
    ram[79] = 16'hc900; //                LD R2 [R2]
    ram[80] = 16'h050a; //                LDH R1 R2
    ram[81] = 16'h70a3; //                LDL R4 Result_Ldh_1.L
    ram[82] = 16'h7100; //                LDH R4 Result_Ldh_1.H
    ram[83] = 16'hd200; //                LD R4 [R4]
    ram[84] = 16'h00ce; //                CMP R1 R4
    ram[85] = 16'h4e80; //                BZC [R5]
                       //
    ram[86] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test LDL imm
    ram[87] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[88] = 16'hc480; //                LD R1 [R1]
    ram[89] = 16'h6412; //                LDL R1 0x12
    ram[90] = 16'h70a2; //                LDL R4 Result_Ldl_1.L
    ram[91] = 16'h7100; //                LDH R4 Result_Ldl_1.H
    ram[92] = 16'hd200; //                LD R4 [R4]
    ram[93] = 16'h00ce; //                CMP R1 R4
    ram[94] = 16'h4e80; //                BZC [R5]
                       //
    ram[95] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test LDH imm
    ram[96] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[97] = 16'hc480; //                LD R1 [R1]
    ram[98] = 16'h6512; //                LDH R1 0x12
    ram[99] = 16'h70a3; //                LDL R4 Result_Ldh_1.L
    ram[100] = 16'h7100; //                LDH R4 Result_Ldh_1.H
    ram[101] = 16'hd200; //                LD R4 [R4]
    ram[102] = 16'h00ce; //                CMP R1 R4
    ram[103] = 16'h4e80; //                BZC [R5]
                       //
    ram[104] = 16'h66ab; //                LDLZ R1 0xAB            ; Test LDLZ imm
    ram[105] = 16'h70a4; //                LDL R4 Result_Ldlz_1.L
    ram[106] = 16'h7100; //                LDH R4 Result_Ldlz_1.H
    ram[107] = 16'hd200; //                LD R4 [R4]
    ram[108] = 16'h00ce; //                CMP R1 R4
    ram[109] = 16'h4e80; //                BZC [R5]
                       //
    ram[110] = 16'h67ba; //                LDHZ R1 0xBA            ; Test LDHZ imm
    ram[111] = 16'h70a5; //                LDL R4 Result_Ldhz_1.L
    ram[112] = 16'h7100; //                LDH R4 Result_Ldhz_1.H
    ram[113] = 16'hd200; //                LD R4 [R4]
    ram[114] = 16'h00ce; //                CMP R1 R4
    ram[115] = 16'h4e80; //                BZC [R5]
                       //
    ram[116] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test SWP
    ram[117] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[118] = 16'hc480; //                LD R1 [R1]
    ram[119] = 16'h048b; //                SWP R1 R1
    ram[120] = 16'h70a6; //                LDL R4 Result_Swp_1.L
    ram[121] = 16'h7100; //                LDH R4 Result_Swp_1.H
    ram[122] = 16'hd200; //                LD R4 [R4]
    ram[123] = 16'h00ce; //                CMP R1 R4
    ram[124] = 16'h4e80; //                BZC [R5]
                       //
    ram[125] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test INC
    ram[126] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[127] = 16'hc480; //                LD R1 [R1]
    ram[128] = 16'h048c; //                INC R1 R1
    ram[129] = 16'h70a7; //                LDL R4 Result_Inc_1.L
    ram[130] = 16'h7100; //                LDH R4 Result_Inc_1.H
    ram[131] = 16'hd200; //                LD R4 [R4]
    ram[132] = 16'h00ce; //                CMP R1 R4
    ram[133] = 16'h4e80; //                BZC [R5]
                       //
    ram[134] = 16'h649c; //                LDL R1 Operand1_2.L     ; Test DEC
    ram[135] = 16'h6500; //                LDH R1 Operand1_2.H
    ram[136] = 16'hc480; //                LD R1 [R1]
    ram[137] = 16'h048f; //                DEC R1 R1
    ram[138] = 16'h70a8; //                LDL R4 Result_Dec_1.L
    ram[139] = 16'h7100; //                LDH R4 Result_Dec_1.H
    ram[140] = 16'hd200; //                LD R4 [R4]
    ram[141] = 16'h00ce; //                CMP R1 R4
    ram[142] = 16'h4e80; //                BZC [R5]
                       //
                       //
                       //                ; Test succeeded
    ram[143] = 16'h7002; //                LDL R4 TestOk.L
    ram[144] = 16'h7100; //                LDH R4 TestOk.H
    ram[145] = 16'h7434; //                LDL R5 0x34
    ram[146] = 16'h7512; //                LDH R5 0x12
    ram[147] = 16'hf600; //                STO R5 [R4]
    ram[148] = 16'h9fff; //                HLT
                       //
    ram[149] = 16'h7002; //                LDL R4 TestOk.L
    ram[150] = 16'h7100; //                LDH R4 TestOk.H
    ram[151] = 16'h7600; //                LDLZ R5 0
    ram[152] = 16'hf600; //                STO R5 [R4]
    ram[153] = 16'h9fff; //                HLT
                       //
    ram[154] = 16'h0064; // .data 100
    ram[155] = 16'h000d; // .data 13
    ram[156] = 16'hfedc; // .data 0xFEDC
    ram[157] = 16'h0012; // .data 0x12
    ram[158] = 16'h0071; // .data 100 + 13
    ram[159] = 16'h0072; // .data 100 + 13 + 1
    ram[160] = 16'h0057; // .data 100 - 13
    ram[161] = 16'h0056; // .data 100 - 13 - 1
    ram[162] = 16'hfe12; // .data 0xFE12
    ram[163] = 16'h12dc; // .data 0x12DC
    ram[164] = 16'h00ab; // .data 0x00AB
    ram[165] = 16'hba00; // .data 0xBA00
    ram[166] = 16'hdcfe; // .data 0xDCFE
    ram[167] = 16'hfedd; // .data 0xFEDC + 1
    ram[168] = 16'hfedb; // .data 0xFEDC - 1

    ram[`CMD_AND_REG_SWITCHES] = `NONE << 3;
    repeat (5) @(posedge clk);

    ram[`CMD_AND_REG_SWITCHES] = `START << 3;
    ram[`ADDR_SWITCHES] = 0;
    repeat (700) @(posedge clk);
    if (ram[`ADDR_LEDS] != 149 ||
        ram[`DATA_LEDS] != 16'h7002 ||
        ram[2] != 16'h1234)
      begin
        $error("ERROR: START - : ADDR=%04X, DATA=%04X", ram[`ADDR_LEDS], ram[`DATA_LEDS]);
        $finish;
      end
      /*
      .din(io_din),
      .addr(io_addr_in),
      .write_en(io_write_en),
      .clk(clk),
      .dout(io_dout),
      .stop(io_stop),
      .reset(io_reset),
      .io_leds(io_leds),
      .io_clk(io_clk_out),
      .io_addr(io_addr_out),
      .io_switches(io_switches),
      .io_reg_switches(io_reg_switches),
      .sound(io_sound)); */


    io_din = 16'h1234;
    io_addr_in = 2;
    io_write_en = 1;

    repeat (5) @(posedge clk);

    io_write_en = 0;

    repeat (5) @(posedge clk);

    io_din = 16'hFEDC;
    io_addr_in = 3;
    io_write_en = 1;

    repeat (5) @(posedge clk);
    io_write_en = 0;

    io_din = 16'h001F;
    io_addr_in = 7;
    io_write_en = 1;

    repeat (5) @(posedge clk);
    io_write_en = 0;

    repeat (5) @(posedge clk);
//repeat (25000000 / 50 *4)  @(posedge clk);




    $display("All tests passed!");

    $finish;
end
endmodule
