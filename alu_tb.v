`include "alu.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test();

reg [15:0] a;
reg [15:0] b;
reg c;
reg [2:0] operation;
reg       aluOn;
reg       shiftOn;
reg       loadOn;
wire [15:0] r;
wire cOut;
wire zOut;
wire nOut;

Alu alu(.operand1(a),
        .operand2(b),
        .carryIn(c),
        .operation(operation),
        .enableAlu(aluOn),
        .enableShift(shiftOn),
        .enableLoad(loadOn),
        .result(r),
        .carryOut(cOut),
        .zeroOut(zOut),
        .negativeOut(nOut));

initial begin
//   $dumpfile("alu_tb.vcd");
//   $dumpvars(0,test);

  $monitor("a=%b,b=%b,c=%b,aluOp=%b,aluOn=%b,shiftOn=%b,loadOn=%b,r=%b,cOut=%b,zOut=%b,nOut=%b",a,b,c,operation,aluOn,shiftOn,loadOn,r,cOut,zOut,nOut);
//  $dumpvars;
  a = 16'h000A;
  b = 16'h000F;
  c = 1'b1;
  operation = `ADC_OP;
  aluOn = 1;
  shiftOn = 0;
  loadOn = 0;
  #1;
  if (r != 16'h001A || cOut != 1'b0) $error("ERROR: ADC_OP 1");

  a = 16'hF000;
  b = 16'h1243;
  c = 1'b0;
  operation = `ADD_OP;
  aluOn = 1;
  shiftOn = 0;
  loadOn = 0;
  #2
  if (r != 16'h0243 || cOut != 1'b1) $error("ERROR: ADD_OP 1");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b0;
  operation = `SHL_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #3
  if (r != 16'h0468 || cOut != 1'b1) $error("ERROR: ASL_OP 1");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b1;
  operation = `SHL_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #4
  if (r != 16'h0468 || cOut != 1'b1) $error("ERROR: LSL_OP 1");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b0;
  operation = `ASHR_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #5
  if (r != 16'hC11A || cOut != 1'b0) $error("ERROR: ASHR_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  operation = `ASHR_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #6
  if (r != 16'hC11A || cOut != 1'b1) $error("ERROR: ASR_OP 2");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b0;
  operation = `SHR_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #7
  if (r != 16'h411A || cOut != 1'b0) $error("ERROR: LSR_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  operation = `SHR_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #8
  if (r != 16'h411A || cOut != 1'b1) $error("ERROR: LSR_OP 2");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  operation = `ROL_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #9
  if (r != 16'h046A || cOut != 1'b1) $error("ERROR: ROL_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  operation = `ROL_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #10
  if (r != 16'h046B || cOut != 1'b1) $error("ERROR: ROL_OP 2");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  operation = `ROR_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #11
  if (r != 16'h411A || cOut != 1'b1) $error("ERROR: ROL_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  operation = `ROR_OP;
  aluOn = 0;
  shiftOn = 1;
  loadOn = 0;
  #12
  if (r != 16'hC11A || cOut != 1'b1) $error("ERROR: ROL_OP 2");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  operation = `NOT_OP;
  aluOn = 1;
  shiftOn = 0;
  loadOn = 0;
  #13
  if (r != 16'h7DCA || cOut != 1'b0) $error("ERROR: NOT_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  operation = `COPY_OP;
  aluOn = 0;
  shiftOn = 0;
  loadOn = 1;
  #14
  if (r != 16'h8235 || cOut != 1'b1) $error("ERROR: COPY_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  operation = `SWAP_OP;
  aluOn = 0;
  shiftOn = 0;
  loadOn = 1;
  #15
  if (r != 16'h3582 || cOut != 1'b1) $error("ERROR: SWAP_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  operation = `LDL_OP;
  aluOn = 0;
  shiftOn = 0;
  loadOn = 1;
  #16
  if (r != 16'h0035 || cOut != 1'b1) $error("ERROR: LDL_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  operation = `LDH_OP;
  aluOn = 0;
  shiftOn = 0;
  loadOn = 1;
  #17
  if (r != 16'h0082 || cOut != 1'b1) $error("ERROR: LDH_OP");

end
endmodule
