`ifndef K16CPU_V
`define K16CPU_V

module K16Cpu(clk, reset, hold, busy,
             address, data_in, data_out, write);

  input             clk;
  input             reset;
  input             hold;
  output reg        busy;
  output reg [15:0] address;
  input  [15:0]     data_in;
  output [15:0]     data_out;
  output reg        write;

  // 8 16-bit registers
  reg [15:0] register[0:7];

  localparam SP = 6; // SP in register 6
  localparam PC = 7; // PC in register 7

  reg [2:0] destinationRegister;

  // Flags
  reg carry;
  reg negative;
  reg zero;
  reg overflow;
  reg enableInterrupt;

  // CPU state
  reg [4:0] state;

  // CPU states
  localparam RESET   = 0;
  localparam FETCH_INSTR = 1;
  localparam WAIT_INSTR = 2;
  localparam DECODE_INSTR = 3;
  localparam STORE_RESULT = 4;
  localparam STORE_RESULT_AND_CARRY = 5;
  localparam STORE_FLAGS = 6;
  localparam JUMP = 7;
  localparam LOAD_MEM = 8;
  localparam WAIT_READ_MEM = 9;
  localparam STORE_READ_MEM = 10;
  localparam WAIT_WRITE_MEM = 11;
  localparam WAIT_WRITE_RETURN_ADDRESS = 12;

  reg [15:0] operand1;
  reg [15:0] operand2;
  wire [15:0] result;
  reg [2:0]  operation;
  reg        enableAlu;
  reg        enableShift;
  reg        enableLoad;
  wire       carryOut;
  wire       zeroOut;
  wire       negativeOut;
  Alu #(16) alu(
    .operand1(operand1),
    .operand2(operand2),
    .carryIn(carry),
    .operation(operation),
    .enableAlu(enableAlu),
    .enableShift(enableShift),
    .enableLoad(enableLoad),
    .result(result),
    .carryOut(carryOut),
    .zeroOut(zeroOut),
    .negativeOut(negativeOut));

  always @(posedge clk)
    if (reset)
    begin
      $display("Reset");
      state <= RESET;
      busy <= 1;
    end
    else
    begin
       case (state)
         RESET:
           begin
             $display("RESET");
             register[PC] <= 16'h0000;
             write <= 0;
             carry <= 0;
             zero <= 0;
             negative <= 0;
             state <= FETCH_INSTR;
           end
         FETCH_INSTR:
           begin
             $display("FETCH_INSTR");
             address <= register[PC];
             operation <= 0;
             operand1 <= register[PC];
             operand2 <= 1;
             enableAlu <= 1;
             enableShift <= 0;
             enableLoad <= 0;
             state <= WAIT_INSTR;
           end
         WAIT_INSTR:
           begin
             $display("WAIT_INSTR address=%04X", address);
             register[PC] <= result;
             state <= DECODE_INSTR;
           end
         DECODE_INSTR:
           begin
              $display("DECODE_INSTR address=%04X", address);
              casez (data_in)
                16'b000?????????00??:
                  begin
                    $display("DECODE_INSTR - ADD (0), ADC (1), SUB (2), SBC (3)");
                    // ADD (0), ADC (1), SUB (2), SBC (3), AND (4), OR (5), XOR (6), NOT (7)
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT_AND_CARRY;
                    $display("  operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????01??:
                  begin
                    $display("DECODE_INSTR - AND (4), OR (5), XOR (6), NOT (7)");
                    // ADD (0), ADC (1), SUB (2), SBC (3), AND (4), OR (5), XOR (6), NOT (7)
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                    $display("   operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????10??:
                  begin
                    $display("DECODE_INSTR - LD (0), LDL (1), LDH (2), SWP (3)");
                    operation <= {1'b0, data_in[1:0]};
                    operand1 <= register[data_in[9:7]];
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 0;
                    enableShift <= 0;
                    enableLoad <= 1;
                    state <= STORE_RESULT;
                  end
                16'b000?????????1100:
                  begin
                    $display("DECODE_INSTR - INC");
                    operation <= 3'b000;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                  end
                16'b000?????????1110:
                  begin
                    $display("DECODE_INSTR - CMP");
                    operation <= 3'b010;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_FLAGS;
                  end
                16'b000?????????1111:
                  begin
                    $display("DECODE_INSTR - DEC");
                    operation <= 3'b010;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                  end
                16'b001?????????0???:
                  begin
                    $display("DECODE_INSTR - SHR (0), ASHL/SHL (1), ASHR (2), ROR (3), ROL(4)");
                    operation <= {data_in[2:0]};
                    operand1 <= register[data_in[9:7]];
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 0;
                    enableShift <= 1;
                    enableLoad <= 0;
                    state <= STORE_RESULT_AND_CARRY;
                  end
                16'b001?????????10??:
                  begin
                    // CLC (0), SEC (1), CLI (2), SEI (3)
                    operation <= {data_in[2:0]};
                    operand1 <= register[data_in[9:7]];
                    enableAlu <= 0;
                    enableShift <= 1;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                  end
                16'b010?????????????:
                  begin
                    $display("DECODE_INSTR - BCS (0), BCC (1), BZS (2) BZC (3), BNS (4), BNC (5), BOS (6), BOC (7)");
                    if ((data_in[12:10] == 3'b000 && carry == 1'b1) ||
                        (data_in[12:10] == 3'b001 && carry == 1'b0) ||
                        (data_in[12:10] == 3'b010 && zero == 1'b1) ||
                        (data_in[12:10] == 3'b011 && zero == 1'b0) ||
                        (data_in[12:10] == 3'b100 && negative == 1'b1) ||
                        (data_in[12:10] == 3'b101 && negative == 1'b0))
                      begin
                        operation <= 3'b000;
                        operand1 <= register[data_in[9:7]];
                        operand2 <= {data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6:0]};;
                        enableAlu <= 1;
                        enableShift <= 0;
                        enableLoad <= 0;
                        state <= JUMP;
                      end
                    else
                      begin
                        state <= FETCH_INSTR;
                      end
                  end
                16'b011?????????????:
                  begin
                     $display("DECODE_INSTR - LDL imm8 (0), LDH imm8 (1), LDLZ imm8 (2), LDHZ imm8 (3)");
                     operation <= {1'b1, data_in[9:8]};
                     operand1 <= data_in[7:0];
                     destinationRegister <= data_in[12:10];
                     enableAlu <= 0;
                     enableShift <= 0;
                     enableLoad <= 1;
                     state <= STORE_RESULT;
                  $display("   operation=%03B,operand1=%02X,dest=%03B",operation,operand1,data_in[12:10]);
                  end
                16'b100?????????????:
                  begin
                    $display("DECODE_INSTR - JMP, HLT");
                    operation <= 0;
                    operand1 <= register[data_in[12:10]];
                    operand2 <= {data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9:0]};
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= JUMP;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9:0]});
                  end
                16'b110?????????????:
                  begin
                    $display("DECODE_INSTR - LD [MEM]");
                    operation <= 0;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= {data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6:0]};
                    destinationRegister <= data_in[12:10];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= LOAD_MEM;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6], data_in[6:0]});
                  end
              endcase
           end
         STORE_RESULT:
           begin
              $display("STORE_RESULT R%d = %04X", destinationRegister, result);
              register[destinationRegister] <= result;
              zero = zeroOut;
              negative = negativeOut;
              enableAlu <= 0;
              enableShift <= 0;
              enableLoad <= 0;
              state <= FETCH_INSTR;
           end
         STORE_RESULT_AND_CARRY:
           begin
             $display("STORE_RESULT_AND_CARRY R%d = %04X", destinationRegister, result);
             register[destinationRegister] <= result;
             carry = carryOut;
             zero = zeroOut;
             negative = negativeOut;
             enableAlu <= 0;
             enableShift <= 0;
             enableLoad <= 0;
             state <= FETCH_INSTR;
           end
         STORE_FLAGS:
           begin
             $display("STORE_FLAGS");
             carry = carryOut;
             zero = zeroOut;
             negative = negativeOut;
             enableAlu <= 0;
             enableShift <= 0;
             enableLoad <= 0;
             state <= FETCH_INSTR;
           end
         JUMP:
           begin
             $display("JUMP");
             register[PC] <= result;
             state <= FETCH_INSTR;
           end
         LOAD_MEM:
           begin
             $display("LOAD_MEM");
             address <= result;
             state <= WAIT_READ_MEM;
           end
         WAIT_READ_MEM:
           begin
             $display("WAIT_READ_MEM");
             state <= STORE_READ_MEM;
           end
         STORE_READ_MEM:
           begin
             $display("STORE_READ_MEM");
             register[destinationRegister] <= data_in;
             zero <= data_in == 16'hFFFF ? 1'b1 : 1'b0;
             negative <= data_in[15] == 1'b1 ? 1'b1 : 1'b0;
             state <= FETCH_INSTR;
           end
       endcase
       $display("   State=%02X,R0=%04X,R1=%04X,R2=%04X,R3=%04X,R4=%04X,R5=%04X,R6=%04X,R7=%04X,C=%B,Z=%B,N=%B,Address=%04x,data_in=%04X",state,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7],carry,zero,negative,address,data_in);
    end
endmodule
`endif
