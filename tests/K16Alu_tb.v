// ----------------------------------------------------------------------------
// K16Alu: all operations against a reference model written from the
// instruction set documentation (result, carry, zero, negative, overflow).
// Edge values for both operands and the carry, plus random values. Shifts
// with every count 1 .. 8; the model shifts one bit at a time.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Alu.v"

module K16Alu_tb();
`include "K16Test.vh"

  reg  [15:0] operand1;
  reg  [15:0] operand2;
  reg         carryIn;
  reg  [1:0]  operationType;
  reg  [2:0]  operation;
  reg  [2:0]  shiftCount;
  wire [15:0] result;
  wire        carryOut;
  wire        zeroOut;
  wire        negativeOut;
  wire        overflowOut;

  K16Alu alu(.operand1(operand1), .operand2(operand2), .carryIn(carryIn),
             .operationType(operationType), .operation(operation), .shiftCount(shiftCount),
             .result(result), .carryOut(carryOut), .zeroOut(zeroOut),
             .negativeOut(negativeOut), .overflowOut(overflowOut));

  // Reference model
  reg [15:0] expectedResult;
  reg        expectedCarry;
  reg        expectedOverflow;
  integer    signed1;
  integer    signed2;
  integer    signedResult;
  integer    step;
  reg        bit_out;

  task model;
    begin
      expectedCarry = carryIn;   // unchanged unless the operation sets it
      expectedOverflow = 0;
      signed1 = operand1[15] ? operand1 - 65536 : operand1;
      signed2 = operand2[15] ? operand2 - 65536 : operand2;
      case ({operationType, operation})
        // ALU operations
        5'b00_000: begin // ADD
                     expectedResult = operand1 + operand2;
                     expectedCarry = ({1'b0, operand1} + operand2) > 17'h0FFFF;
                     signedResult = signed1 + signed2;
                     expectedOverflow = signedResult > 32767 || signedResult < -32768;
                   end
        5'b00_001: begin // ADC
                     expectedResult = operand1 + operand2 + carryIn;
                     expectedCarry = ({1'b0, operand1} + operand2 + carryIn) > 17'h0FFFF;
                     signedResult = signed1 + signed2 + carryIn;
                     expectedOverflow = signedResult > 32767 || signedResult < -32768;
                   end
        5'b00_010: begin // SUB: carry is the borrow
                     expectedResult = operand1 - operand2;
                     expectedCarry = operand1 < operand2;
                     signedResult = signed1 - signed2;
                     expectedOverflow = signedResult > 32767 || signedResult < -32768;
                   end
        5'b00_011: begin // SBC
                     expectedResult = operand1 - operand2 - carryIn;
                     expectedCarry = {1'b0, operand1} < {1'b0, operand2} + carryIn;
                     signedResult = signed1 - signed2 - carryIn;
                     expectedOverflow = signedResult > 32767 || signedResult < -32768;
                   end
        5'b00_100: expectedResult = operand1 & operand2;               // AND
        5'b00_101: expectedResult = operand1 | operand2;               // OR
        5'b00_110: expectedResult = operand1 ^ operand2;               // XOR
        5'b00_111: expectedResult = ~operand1;                         // NOT
        // Shift operations: shiftCount + 1 single steps
        5'b01_000, 5'b01_001, 5'b01_010, 5'b01_011, 5'b01_100:
                   begin
                     expectedResult = operand1;
                     for (step = 0; step <= shiftCount; step = step + 1)
                       case (operation)
                         3'b000: begin // SHR
                                   bit_out = expectedResult[0];
                                   expectedResult = expectedResult >> 1;
                                   expectedCarry = bit_out;
                                 end
                         3'b001: begin // SHL, ASHL
                                   bit_out = expectedResult[15];
                                   expectedResult = expectedResult << 1;
                                   expectedCarry = bit_out;
                                 end
                         3'b010: begin // ASHR
                                   bit_out = expectedResult[0];
                                   expectedResult = (expectedResult >> 1) | (expectedResult & 16'h8000);
                                   expectedCarry = bit_out;
                                 end
                         3'b011: begin // ROR through the carry
                                   bit_out = expectedResult[0];
                                   expectedResult = (expectedResult >> 1) | (expectedCarry << 15);
                                   expectedCarry = bit_out;
                                 end
                         default: begin // ROL through the carry
                                   bit_out = expectedResult[15];
                                   expectedResult = (expectedResult << 1) | expectedCarry;
                                   expectedCarry = bit_out;
                                 end
                       endcase
                   end
        // Load operations (register: operand1 = source, operand2 = destination;
        // immediate: operand1 = destination, operand2 = immediate value)
        5'b10_000: expectedResult = operand1;                                // LD
        5'b10_001: expectedResult = (operand2 & 16'hFF00) | (operand1 & 16'h00FF);   // LDL
        5'b10_010: expectedResult = (operand1 << 8) | (operand2 & 16'h00FF);  // LDH
        5'b10_011: expectedResult = (operand1 << 8) | (operand1 >> 8);        // SWP
        5'b10_100: expectedResult = (operand1 & 16'hFF00) | (operand2 & 16'h00FF);   // LDL imm8
        5'b10_101: expectedResult = (operand2 << 8) | (operand1 & 16'h00FF);  // LDH imm8
        5'b10_110: expectedResult = operand2 & 16'h00FF;                      // LDLZ imm8
        5'b10_111: expectedResult = operand2 << 8;                            // LDHZ imm8
        default:   expectedResult = operand1;  // unused shift codes and operation type 3
      endcase
    end
  endtask

  task check_operation;
    begin
      #1;
      model;
      test_checks = test_checks + 1;
      if (result !== expectedResult || carryOut !== expectedCarry ||
          zeroOut !== (expectedResult == 0) || negativeOut !== expectedResult[15] ||
          overflowOut !== expectedOverflow)
        begin
          test_errors = test_errors + 1;
          if (test_errors <= 25)
            $fdisplay(32'h8000_0002, "  failed: type %0d operation %0d count %0d: %04h, %04h, carry %0d: result %04h C%0d Z%0d N%0d O%0d, expected %04h C%0d Z%0d N%0d O%0d",
                      operationType, operation, shiftCount + 1, operand1, operand2, carryIn,
                      result, carryOut, zeroOut, negativeOut, overflowOut,
                      expectedResult, expectedCarry, expectedResult == 0, expectedResult[15], expectedOverflow);
        end
    end
  endtask

  reg [15:0] edges[0:13];
  integer i, j, k, n, c;
  integer seed;

  initial
    begin
      edges[0] = 16'h0000; edges[1] = 16'h0001; edges[2] = 16'h0002; edges[3] = 16'h7FFF;
      edges[4] = 16'h8000; edges[5] = 16'h8001; edges[6] = 16'hFFFE; edges[7] = 16'hFFFF;
      edges[8] = 16'h00FF; edges[9] = 16'hFF00; edges[10] = 16'h5555; edges[11] = 16'hAAAA;
      edges[12] = 16'h1234; edges[13] = 16'hF0F0;

      test_section("ALU: all operations with edge values");
      for (n = 0; n < 32; n = n + 1)
        for (i = 0; i < 14; i = i + 1)
          for (j = 0; j < 14; j = j + 1)
            for (k = 0; k < 2; k = k + 1)
              for (c = 0; c < 8; c = c + 1)
                if (c == 0 || n[4:3] == 2'b01)   // the count only matters for shifts
                  begin
                    {operationType, operation} = n;
                    shiftCount = c;
                    operand1 = edges[i];
                    operand2 = edges[j];
                    carryIn = k;
                    check_operation;
                  end

      test_section("ALU: all operations with random values");
      seed = 16;
      for (i = 0; i < 20000; i = i + 1)
        begin
          {operationType, operation} = $random(seed);
          shiftCount = $random(seed);
          operand1 = $random(seed);
          operand2 = $random(seed);
          carryIn = $random(seed);
          check_operation;
        end

      test_done;
    end
endmodule
