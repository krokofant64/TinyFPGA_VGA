 `ifndef ALU_V
`define ALU_V

`include "K16Trace.vh"

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

// Shift operations shift by shiftCount + 1 (1 .. 8) positions; the carry is
// the last bit shifted out. ROR and ROL rotate the 17 bits {carry, operand1}.
module K16Alu(operand1, operand2, carryIn, operationType, operation, shiftCount, result, carryOut, zeroOut, negativeOut, overflowOut);

  input [15:0]      operand1;
  input [15:0]      operand2;
  input              carryIn;
  input [1:0]        operationType;
  input [2:0]        operation;
  input [2:0]        shiftCount;
  output reg         carryOut;
  output reg         zeroOut;
  output reg         negativeOut;
  output reg         overflowOut;
  output reg [15:0] result;

  wire [3:0]  count = {1'b0, shiftCount} + 4'd1;
  wire [16:0] shifted_right = {operand1, 1'b0} >> count;                     // {result, carry}
  wire [16:0] shifted_left = {1'b0, operand1} << count;                      // {carry, result}
  wire [16:0] shifted_arith = $signed({operand1, 1'b0}) >>> count;           // {result, carry}
  wire [16:0] rotate_in = {carryIn, operand1};
  wire [16:0] rotated_right = (rotate_in >> count) | (rotate_in << (5'd17 - count));   // {carry, result}
  wire [16:0] rotated_left = (rotate_in << count) | (rotate_in >> (5'd17 - count));    // {carry, result}

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
        `SHR_OP:   {carryOut, result} = {shifted_right[0], shifted_right[16:1]};
        `SHL_OP:   {carryOut, result} = shifted_left;
        `ASHR_OP:  {carryOut, result} = {shifted_arith[0], shifted_arith[16:1]};
        `ROR_OP:   {carryOut, result} = rotated_right;
        `ROL_OP:   {carryOut, result} = rotated_left;
        default:   {carryOut, result} = {carryIn, operand1};
      endcase
    else
    if (operationType == `LOAD_OP)
      case (operation)
        `COPY_OP:  {carryOut, result} = {carryIn, operand1};
        `LDL_OP:   {carryOut, result} = {carryIn, operand2[15:8], operand1[7:0]};
        `LDH_OP:   {carryOut, result} = {carryIn, operand1[7:0], operand2[7:0]};
        `SWAP_OP:  {carryOut, result} = {carryIn, operand1[7:0], operand1[15:8]};
        `LDLI_OP:  {carryOut, result} = {carryIn, operand1[15:8], operand2[7:0]};
        `LDHI_OP:  {carryOut, result} = {carryIn, operand2[7:0], operand1[7:0]};
        `LDLZI_OP: {carryOut, result} = {carryIn, 8'b0, operand2[7:0]};
        `LDHZI_OP: {carryOut, result} = {carryIn, operand2[7:0], 8'b0};
      endcase
    else
      begin
        {carryOut, result} = {carryIn, operand1};
      end

    negativeOut = result[15];
    zeroOut = result == 0;

    // Signed overflow of ADD, ADC, SUB, and SBC
    if (operationType == `ALU_OP && operation[2] == 1'b0)
      if (operation[1] == 1'b0)
        // ADD, ADC: operands have the same sign, result has a different one
        overflowOut = (operand1[15] == operand2[15]) && (result[15] != operand1[15]);
      else
        // SUB, SBC: operands have different signs, result differs from operand1
        overflowOut = (operand1[15] != operand2[15]) && (result[15] != operand1[15]);
    else
      overflowOut = 1'b0;
    if (`K16_TRACE) $display(".  .  operationType=%02B, operation=%02B, operand1=%04X, operand2=%04X, result=%04X, carryOut=%b", operationType, operation, operand1, operand2, result, carryOut);
  end
endmodule
`endif
