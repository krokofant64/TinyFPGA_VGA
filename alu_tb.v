`include "alu.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test();

reg [15:0] a;
reg [15:0] b;
reg c;
reg       aluOn;
reg [2:0] aluOp;
reg       shiftOn;
reg [2:0] shiftOp;
reg       loadOn;
reg [2:0] loadOp;
wire [16:0] r;


Alu alu(.operand1(a),
        .operand2(b),
        .carry(c),
        .enableAlu(aluOn),
        .aluOperation(aluOp),
        .enableShift(shiftOn),
        .shiftOperation(shiftOp),
        .enableLoad(loadOn),
        .loadOperation(loadOp),
        .result(r));

initial begin
  $dumpfile("alu_tb.vcd");
  $monitor("a=%b,b=%b,c=%b,aluOn=%b,aluOp=%b,shiftOn=%b,shiftOp=%b,loadOn=%b,loadOp=%br=%b",a,b,c,aluOn,aluOp,shiftOn,shiftOp,loadOn,loadOp,r);
//  $dumpvars;
  a = 16'h000A;
  b = 16'h000F;
  c = 1'b1;
  aluOn = 1;
  aluOp = `ADC_OP;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 0;
  loadOp = 0;
  #1;
  if (r != 17'h0001A) $error("ERROR: ADC_OP 1");

  a = 16'hF000;
  b = 16'h1243;
  c = 1'b0;
  aluOn = 1;
  aluOp = `ADD_OP;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 0;
  loadOp = 0;
  #2
  if (r != 17'h10243) $error("ERROR: ADD_OP 1");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `SHL_OP;
  loadOn = 0;
  loadOp = 0;
  #3
  if (r != 17'h10468) $error("ERROR: ASL_OP 1");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `SHL_OP;
  loadOn = 0;
  loadOp = 0;
  #4
  if (r != 17'h10468) $error("ERROR: LSL_OP 1");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `ASHR_OP;
  loadOn = 0;
  loadOp = 0;
  #5
  if (r != 17'h0C11A) $error("ERROR: ASHR_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `ASHR_OP;
  loadOn = 0;
  loadOp = 0;
  #6
  if (r != 17'h1C11A) $error("ERROR: ASR_OP 2");

  a = 16'h8234;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `SHR_OP;
  loadOn = 0;
  loadOp = 0;
  #7
  if (r != 17'h0411A) $error("ERROR: LSR_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `SHR_OP;
  loadOn = 0;
  loadOp = 0;
  #8
  if (r != 17'h1411A) $error("ERROR: LSR_OP 2");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `ROL_OP;
  loadOn = 0;
  loadOp = 0;
  #9
  if (r != 17'h1046A) $error("ERROR: ROL_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `ROL_OP;
  loadOn = 0;
  loadOp = 0;
  #10
  if (r != 17'h1046B) $error("ERROR: ROL_OP 2");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b0;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `ROR_OP;
  loadOn = 0;
  loadOp = 0;
  #11
  if (r != 17'h1411A) $error("ERROR: ROL_OP 1");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 1;
  shiftOp = `ROR_OP;
  loadOn = 0;
  loadOp = 0;
  #12
  if (r != 17'h1C11A) $error("ERROR: ROL_OP 2");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 1;
  aluOp = `NOT_OP;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 0;
  loadOp = 0;
  #13
  if (r != 17'h07DCA) $error("ERROR: NOT_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 1;
  loadOp = `COPY_OP;
  #14
  if (r != 17'h8235) $error("ERROR: COPY_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 1;
  loadOp = `SWAP_OP;
  #15
  if (r != 17'h3582) $error("ERROR: SWAP_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 1;
  loadOp = `LDL_OP;
  #16
  if (r != 17'h0035) $error("ERROR: LDL_OP");

  a = 16'h8235;
  b = 16'h0000;
  c = 1'b1;
  aluOn = 0;
  aluOp = 0;
  shiftOn = 0;
  shiftOp = 0;
  loadOn = 1;
  loadOp = `LDH_OP;
  #17
  if (r != 17'h0082) $error("ERROR: LDH_OP");

end
endmodule
