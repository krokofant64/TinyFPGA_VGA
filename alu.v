`ifndef ALU_V
`define ALU_V

module Alu(operand1, operand2, operation, result);

  input [15:0] operand1;
  input [15:0] operand2;
  input [3:0] operation;
  output reg [15:0] result;

  always @(*)
  begin
    case (operation)
      4'b000: result = operand1 + operand2;
      4'b001: result = operand1 - operand2;
      4'b010: result = operand1 & operand2;
      4'b011: result = operand1 | operand2;
      4'b100: result = operand1 ^ operand2;
    endcase

  end

endmodule

`endif
