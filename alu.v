`ifndef ALU_V
`define ALU_V

// OPERATION TYPES
`define ALU_OP   2'b00  // ALU operations
`define SHIFT_OP 2'b01  // Shift operations
`define LOAD_OP  2'b10  // Load operations

// ALU operations
`define ADD_OP   3'b000
`define ADC_OP   3'b001
`define SUB_OP   3'b010
`define SBC_OP   3'b011
`define AND_OP   3'b100
`define OR_OP    3'b101
`define XOR_OP   3'b110
`define NOT_OP   3'b111

// Shift operations
`define SHR_OP   3'b000
`define SHL_OP   3'b001
`define ASHR_OP  3'b010
`define ROR_OP   3'b011
`define ROL_OP   3'b100

// Load operations
`define COPY_OP  3'b000
`define LDL_OP   3'b001
`define LDH_OP   3'b010
`define SWAP_OP  3'b011
`define LDLI_OP  3'b100
`define LDHI_OP  3'b101
`define LDLZI_OP 3'b110
`define LDHZI_OP 3'b111

module Alu(operand1, operand2, carryIn, operationType, operation, result, carryOut, zeroOut, negativeOut);

  parameter N = 16;	// default width = 16 bits

  input [N-1:0]      operand1;
  input [N-1:0]      operand2;
  input              carryIn;
  input [2:0]        operationType;
  input [2:0]        operation;
  output reg         carryOut;
  output reg         zeroOut;
  output reg         negativeOut;
  output reg [N-1:0] result;

  always @(*)
  begin
    if (operationType == `ALU_OP)
      case (operation)
        `ADD_OP:   {carryOut, result} = operand1 + operand2;
        `ADC_OP:   {carryOut, result} = operand1 + operand2 + (carryIn ? 1 : 0);
        `SUB_OP:   {carryOut, result} = operand1 - operand2;
        `SBC_OP:   {carryOut, result} = operand1 - operand2 - (carryIn ? 1 : 0);
        `AND_OP:   {carryOut, result} = { carryIn, operand1 & operand2 };
        `OR_OP:    {carryOut, result} = { carryIn, operand1 | operand2 };
        `XOR_OP:   {carryOut, result} = { carryIn, operand1 ^ operand2 };
        `NOT_OP:   {carryOut, result} = { carryIn, ~operand1};
      endcase
    else
    if (operationType == `SHIFT_OP)
      case (operation)
        `SHR_OP:   {carryOut, result} = {operand1[0], 1'b0, operand1[N-1:1]};
        `SHL_OP:   {carryOut, result} = {operand1, 1'b0};
        `ASHR_OP:  {carryOut, result} = {operand1[0], operand1[N-1], operand1[N-1], operand1[N-2:1]};
        `ROR_OP:   {carryOut, result} = {operand1[0], carryIn, operand1[N-1:1]};
        `ROL_OP:   {carryOut, result} = {operand1, carryIn};
      endcase
    else
    if (operationType == `LOAD_OP)
      case (operation)
        `COPY_OP:  {carryOut, result} = {carryIn, operand1};
        `LDL_OP:   {carryOut, result} = {carryIn, 8'b0, operand1[N/2-1:0]};
        `LDH_OP:   {carryOut, result} = {carryIn, 8'b0, operand1[N-1:N/2]};
        `SWAP_OP:  {carryOut, result} = {carryIn, operand1[N/2-1:0], operand1[N-1:N/2]};
        `LDLI_OP:  {carryOut, result} = {carryIn, operand2[N-1:N/2], operand1[N/2-1:0]};
        `LDHI_OP:  {carryOut, result} = {carryIn, operand1[N-1:N/2], operand2[N/2-1:0]};
        `LDLZI_OP: {carryOut, result} = {carryIn, 8'b0, operand1[N/2-1:0]};
        `LDHZI_OP: {carryOut, result} = {carryIn, operand1[N-1:N/2], 8'b0};
      endcase
    negativeOut <= result[N-1];
    zeroOut <= result == 0;
  end
endmodule

`endif
