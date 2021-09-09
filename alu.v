`ifndef ALU_V
`define ALU_V

// ALU operations
`define ADD_OP   3'b000
`define ADC_OP   3'b001
`define SUB_OP   3'b010
`define SBC_OP   3'b011
`define AND_OP   3'b100
`define OR_OP    3'b101
`define XOR_OP   3'b110
`define NOT_OP   3'b111

`define SHR_OP   3'b000
`define SHL_OP   3'b001
`define ASHR_OP  3'b010
`define ROR_OP   3'b011
`define ROL_OP   3'b100

`define COPY_OP  3'b000
`define LDL_OP   3'b001
`define LDH_OP   3'b010
`define SWAP_OP  3'b011
`define LDLI_OP  3'b100
`define LDHI_OP  3'b101
`define LDLZI_OP 3'b110
`define LDHZI_OP 3'b111

module Alu(operand1, operand2, carry, enableAlu, aluOperation, enableShift, shiftOperation, enableLoad, loadOperation, result);

  parameter N = 16;	// default width = 16 bits

  input [N-1:0]    operand1;
  input [N-1:0]    operand2;
  input            carry;
  input            enableAlu;
  input [2:0]      aluOperation;
  input            enableShift;
  input [2:0]      shiftOperation;
  input            enableLoad;
  input[2:0]       loadOperation;
  output reg [N:0] result;

  always @(*)
  begin
    if (enableAlu)
      case (aluOperation)
        `ADD_OP:   result = operand1 + operand2;
        `ADC_OP:   result = operand1 + operand2 + (carry ? 1 : 0);
        `SUB_OP:   result = operand1 - operand2;
        `SBC_OP:   result = operand1 - operand2 - (carry ? 1 : 0);
        `AND_OP:   result = { 1'b0, operand1 & operand2 };
        `OR_OP:    result = { 1'b0, operand1 | operand2 };
        `XOR_OP:   result = { 1'b0, operand1 ^ operand2 };
        `NOT_OP:   result = {1'b0, ~operand1};
      endcase
    else
    if (enableShift)
      case (shiftOperation)
        `SHR_OP:   result = {operand1[0], 1'b0, operand1[N-1:1]};
        `SHL_OP:   result = {operand1, 1'b0};
        `ASHR_OP:  result = {operand1[0], operand1[N-1], operand1[N-1], operand1[N-2:1]};
        `ROR_OP:   result = {operand1[0], carry, operand1[N-1:1]};
        `ROL_OP:   result = {operand1, carry};
      endcase
    else
    if (enableLoad)
      case (loadOperation)
        `COPY_OP:  result = {1'b0, operand1};
        `LDL_OP:   result = {9'b0, operand1[N/2-1:0]};
        `LDH_OP:   result = {9'b0, operand1[N-1:N/2]};
        `SWAP_OP:  result = {1'b0, operand1[N/2-1:0], operand1[N-1:N/2]};
        `LDLI_OP:  result = {1'b0, operand2[N-1:N/2], operand1[N/2-1:0]};
        `LDHI_OP:  result = {1'b0, operand1[N-1:N/2], operand2[N/2-1:0]};
        `LDLZI_OP: result = {9'b0, operand1[N/2-1:0]};
        `LDHZI_OP: result = {1'b0, operand1[N-1:N/2], 8'b0};
      endcase
  end
endmodule

`endif
