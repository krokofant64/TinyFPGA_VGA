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

  // Current instruction
  reg [15:0] instruction;

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
  localparam JUMP = 4;
  localparam WAIT_READ_MEM = 6;
  localparam WAIT_WRITE_MEM = 7;
  localparam WAIT_WRITE_RETURN_ADDRESS = 8;

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
    .negativeOut(negativeOut)
    );

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
                16'b000?????????0???:
                  begin
                    $display("DECODE_INSTR - ADD");
                    // ADD (0), ADC (1), SUB (2), SBC (3), AND (4), OR (5), XOR (6), NOT (7)
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                    $display("operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????10??:
                  begin
                    // LD (0), LDL (1), LDH (2), SWP (3)
                    operation <= {1'b0, data_in[1:0]};
                    operand1 <= register[data_in[9:7]];
                    enableAlu <= 0;
                    enableShift <= 0;
                    enableLoad <= 1;
                    state <= STORE_RESULT;
                  end
                16'b000?????????1100:
                  begin
                    // INC
                    operation <= 3'b000;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                  end
                16'b000?????????1110:
                  begin
                    // DEC
                    operation <= 3'b010;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
                  end
                16'b000?????????1111:
                  begin
                    // CMP
                    operation <= 3'b010;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    enableAlu <= 1;
                    enableShift <= 0;
                    enableLoad <= 0;
                  end
                16'b001?????????0???:
                  begin
                    // SHR (0), ASHL/SHL (1), ASHR (2), ROR (3), ROL(4)
                    operation <= {data_in[2:0]};
                    operand1 <= register[data_in[9:7]];
                    register[data_in[12:10]] <= result;
                    enableAlu <= 0;
                    enableShift <= 1;
                    enableLoad <= 0;
                    state <= STORE_RESULT;
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
                16'b011?????????????:
                  // Load from immediate
                  begin
                  $display("DECODE_INSTR - LD Immediate");
                  operation <= {1'b1, data_in[9:8]};
                  operand1 <= data_in[7:0];
                  enableAlu <= 0;
                  enableShift <= 0;
                  enableLoad <= 1;
                  state <= STORE_RESULT;
                  $display("operation=%03B,operand1=%02X,dest=%03B",operation,operand1,data_in[12:10]);
                  end
                16'b100?????????????:
                  // JMP, HLT
                  begin
                  $display("DECODE_INSTR - Jump");
                  operation <= 0;
                  operand1 <= register[data_in[12:10]];
                  operand2 <= {data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9:0]};
                  enableAlu <= 1;
                  enableShift <= 0;
                  enableLoad <= 0;
                  state <= JUMP;
                  $display("operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9], data_in[9:0]});
                  end
              endcase
              instruction <= data_in;
           end
         STORE_RESULT:
           begin
              $display("STORE_RESULT R%d = %04X",data_in[12:10], result);
              register[data_in[12:10]] <= result;
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
       endcase
       $display("State=%02X,R0=%04X,R1=%04X,R2=%04X,R3=%04X,R4=%04X,R5=%04X,R6=%04X,R7=%04X,Address=%04x,data_in=%04X",state,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7],address,data_in);
    end
endmodule
`endif
