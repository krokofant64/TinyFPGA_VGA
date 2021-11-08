`ifndef K16CPU_V
`define K16CPU_V

`include "alu.v"

//
`define START             0
`define STOP              1
`define CONTINUE          2
`define RESET             3
`define INST_STEP         4
`define EXAMINE           5
`define EXAMINE_NEXT      6
`define EXAMINE_REGISTER  7
`define DEPOSIT           8
`define DEPOSIT_NEXT      9
`define DEPOSIT_REGISTER 10


module K16Cpu(clk, reset, hold, busy,
             address, data_in, data_out, write, cpuInput1, cpuInput0, cpuOutput0, cpuOutput1);

  input              clk;
  input              reset;
  input              hold;
  output reg         busy;
  output reg [15:0]  address;
  input  [15:0]      data_in;
  output reg [15:0]  data_out;
  output reg         write;
  input  [15:0]      cpuInput1;
  input  [15:0]      cpuInput0;
  output reg [15:0]  cpuOutput0;
  output reg [15:0]  cpuOutput1;

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
  localparam LD_CALC_MEM_ADDR = 8;
  localparam WAIT_READ_MEM = 9;
  localparam STORE_READ_MEM = 10;
  localparam STO_CALC_MEM_ADDR = 11;
  localparam WAIT_WRITE_MEM = 12;
  localparam PSH_WAIT_WRITE_STACK = 13;
  localparam POP_CALCULATE_SP = 14;
  localparam JSR_WAIT_WRITE_STACK = 15;

  localparam STOPPED = 16;
  localparam EXAMINE_WAIT_NEXT = 17;
  localparam EXAMINE_WAIT_READ_MEM = 18;
  localparam EXAMINE_SHOW_READ_MEM = 19;
  localparam DEPOSIT_WAIT_NEXT = 20;
  localparam DEPOSIT_WAIT_WRITE_MEM = 21;
  localparam EXAMINE_WAIT_READ_REGISTER = 22;
  localparam DEPOSIT_WAIT_WRITE_REGISTER = 23;


  reg [15:0]  operand1;
  reg [15:0]  operand2;
  wire [15:0] result;
  reg [2:0]   operation;
  reg [2:0]   operationType;
  reg         running;
  wire        carryOut;
  wire        zeroOut;
  wire        negativeOut;
  Alu #(16) alu(
    .operand1(operand1),
    .operand2(operand2),
    .carryIn(carry),
    .operationType(operationType),
    .operation(operation),
    .result(result),
    .carryOut(carryOut),
    .zeroOut(zeroOut),
    .negativeOut(negativeOut));

  reg [10:0] buttonState;

  always @(posedge cpuInput1[`STOP])
    begin
      running <= 0;
    end
  always @(posedge cpuInput1[`START])
    begin
      buttonState[`START] <= 1;
    end
  always @(posedge cpuInput1[`CONTINUE])
    begin
      buttonState[`CONTINUE] <= 1;
    end
  always @(posedge cpuInput1[`INST_STEP])
    begin
      buttonState[`INST_STEP] <= 1;
    end
  always @(posedge cpuInput1[`EXAMINE])
    begin
      buttonState[`EXAMINE] <= 1;
    end
  always @(posedge cpuInput1[`EXAMINE_NEXT])
    begin
      buttonState[`EXAMINE_NEXT] <= 1;
    end
  always @(posedge cpuInput1[`DEPOSIT])
    begin
      buttonState[`DEPOSIT] <= 1;
    end
  always @(posedge cpuInput1[`DEPOSIT_NEXT])
    begin
      buttonState[`DEPOSIT_NEXT] <= 1;
    end

  always @(posedge clk)
    if (reset)
    begin
      $display("Reset");
      state <= RESET;
      busy <= 1;
      running <= 0;
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
             if (running)
               begin
                 write <= 0;
                 address <= register[PC];
                 operationType <= `ALU_OP;
                 operation <= `ADD_OP;
                 operand1 <= register[PC];
                 operand2 <= 1;
                 state <= WAIT_INSTR;
               end
             else
               state <= STOPPED;
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
                    operationType <= `ALU_OP;
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    destinationRegister <= data_in[12:10];
                    state <= STORE_RESULT_AND_CARRY;
                    $display("  operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????01??:
                  begin
                    $display("DECODE_INSTR - AND (4), OR (5), XOR (6), NOT (7)");
                    // ADD (0), ADC (1), SUB (2), SBC (3), AND (4), OR (5), XOR (6), NOT (7)
                    operationType <= `ALU_OP;
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    destinationRegister <= data_in[12:10];
                    state <= STORE_RESULT;
                    $display("   operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????10??:
                  begin
                    $display("DECODE_INSTR - LD (0), LDL (1), LDH (2), SWP (3)");
                    operationType <= `LOAD_OP;
                    operation <= {1'b0, data_in[1:0]};
                    operand1 <= register[data_in[9:7]];
                    destinationRegister <= data_in[12:10];
                    state <= STORE_RESULT;
                  end
                16'b000?????????1100:
                  begin
                    $display("DECODE_INSTR - INC");
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    destinationRegister <= data_in[12:10];
                    state <= STORE_RESULT;
                  end
                16'b000?????????1110:
                  begin
                    $display("DECODE_INSTR - CMP");
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    state <= STORE_FLAGS;
                  end
                16'b000?????????1111:
                  begin
                    $display("DECODE_INSTR - DEC");
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    destinationRegister <= data_in[12:10];
                    state <= STORE_RESULT;
                  end
                16'b001?????????0???:
                  begin
                    $display("DECODE_INSTR - SHR (0), ASHL/SHL (1), ASHR (2), ROR (3), ROL(4)");
                    operationType <= `SHIFT_OP;
                    operation <= {data_in[2:0]};
                    operand1 <= register[data_in[9:7]];
                    destinationRegister <= data_in[12:10];
                    state <= STORE_RESULT_AND_CARRY;
                  end
                16'b001?????????10??:
                  begin
                    $display("DECODE_INSTR -  CLC (0), SEC (1), CLI (2), SEI (3)");
                    if (data_in[1] == 1'b0)
                      begin
                        carry = data_in[0];
                      end
                    else
                      begin
                        enableInterrupt = data_in[0];
                      end
                    state <= FETCH_INSTR;
                  end
                16'b001?????????1100:
                  begin
                    $display("DECODE_INSTR -  PSH");
                    address <= register[SP];
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[SP];
                    operand2 <= 16'h0001;
                    destinationRegister <= SP;
                    data_out <= register[data_in[12:10]];
                    write <= 1;
                    state <= PSH_WAIT_WRITE_STACK;
                  end
                  16'b001?????????1101:
                    begin
                      $display("DECODE_INSTR -  POP");
                      operationType <= `ALU_OP;
                      operation <= `ADD_OP;
                      operand1 <= register[SP];
                      operand2 <= 16'h0001;
                      destinationRegister <= data_in[12:10];
                      state <= POP_CALCULATE_SP;
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
                        operationType <= `ALU_OP;
                        operation <= `ADD_OP;
                        operand1 <= register[data_in[9:7]];
                        operand2 <= {{9{data_in[6]}}, data_in[6:0]};;
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
                     operationType <= `LOAD_OP;
                     operation <= {1'b1, data_in[9:8]};
                     operand1 <= data_in[7:0];
                     destinationRegister <= data_in[12:10];
                     state <= STORE_RESULT;
                  $display("   operation=%03B,operand1=%02X,dest=%03B",operation,operand1,data_in[12:10]);
                  end
                16'b100?????????????:
                  begin
                    $display("DECODE_INSTR - JMP, HLT");
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[12:10]];
                    operand2 <= {{6{data_in[9]}}, data_in[9:0]};
                    state <= JUMP;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{6{data_in[9]}}, data_in[9:0]});
                  end
                16'b101?????????????:
                  begin
                    $display("DECODE_INSTR - JSR");
                    address <= register[SP];
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[SP];
                    operand2 <= 16'h0001;
                    destinationRegister <= SP;
                    data_out <= register[PC];
                    write <= 1;
                    state <= JSR_WAIT_WRITE_STACK;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{6{data_in[9]}}, data_in[9:0]});
                  end
                16'b110?????????????:
                  begin
                    $display("DECODE_INSTR - LD [MEM]");
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= {{9{data_in[6]}}, data_in[6:0]};
                    destinationRegister <= data_in[12:10];
                    state <= LD_CALC_MEM_ADDR;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{9{data_in[6]}}, data_in[6:0]});
                  end
                16'b111?????????????:
                  begin
                    $display("DECODE_INSTR - STO");
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= {{9{data_in[6]}}, data_in[6:0]};
                    destinationRegister <= data_in[12:10];
                    state <= STO_CALC_MEM_ADDR;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{9{data_in[6]}}, data_in[6:0]});
                  end
              endcase
           end
         STORE_RESULT:
           begin
              $display("STORE_RESULT R%d = %04X", destinationRegister, result);
              register[destinationRegister] <= result;
              zero = zeroOut;
              negative = negativeOut;
              state <= FETCH_INSTR;
           end
         STORE_RESULT_AND_CARRY:
           begin
             $display("STORE_RESULT_AND_CARRY R%d = %04X", destinationRegister, result);
             register[destinationRegister] <= result;
             carry = carryOut;
             zero = zeroOut;
             negative = negativeOut;
             state <= FETCH_INSTR;
           end
         STORE_FLAGS:
           begin
             $display("STORE_FLAGS");
             carry = carryOut;
             zero = zeroOut;
             negative = negativeOut;
             state <= FETCH_INSTR;
           end
         JUMP:
           begin
             $display("JUMP");
             register[PC] <= result;
             state <= FETCH_INSTR;
           end
         LD_CALC_MEM_ADDR:
           begin
             $display("LD_CALC_MEM_ADDR");
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
             zero <= data_in == 16'h0000 ? 1'b1 : 1'b0;
             negative <= data_in[15] == 1'b1 ? 1'b1 : 1'b0;
             state <= FETCH_INSTR;
           end
         STO_CALC_MEM_ADDR:
           begin
             $display("STO_CALC_MEM_ADDR");
             address <= result;
             data_out <= register[destinationRegister];
             write <= 1;
             state <= WAIT_WRITE_MEM;
           end
        WAIT_WRITE_MEM:
          begin
            $display("WAIT_WRITE_MEM");
            state <= FETCH_INSTR;
          end
        PSH_WAIT_WRITE_STACK:
          begin
            $display("PSH_WAIT_WRITE_STACK");
            write <= 0;
            register[destinationRegister] <= result;
            state <= FETCH_INSTR;
          end
        POP_CALCULATE_SP:
          begin
             $display("POP_CALCULATE_SP");
             address <= result;
             register[SP] <= result;
             state <= WAIT_READ_MEM;
          end
        JSR_WAIT_WRITE_STACK:
          begin
            $display("JSR_WAIT_WRITE_STACK");
            write <= 0;
            register[destinationRegister] <= result;
            operationType <= `ALU_OP;
            operation <= `ADD_OP;
            operand1 <= register[data_in[12:10]];
            operand2 <= {{6{data_in[9]}}, data_in[9:0]};
            state <= JUMP;
          end
        STOPPED:
          begin
            $display("STOPPED");
            if (buttonState[`CONTINUE] == 1)
              begin
                buttonState[`CONTINUE] <= 0;
                running <= 1;
                write <= 0;
                address <= register[PC];
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                state <= WAIT_INSTR;
              end
            else
            if (buttonState[`START] == 1)
              begin
                buttonState[`START] <= 0;
                running <= 1;
                write <= 0;
                register[PC] <= cpuInput0;
                address <= cpuInput0;
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= cpuInput0;
                operand2 <= 1;
                state <= WAIT_INSTR;
              end
            else
            if (buttonState[`INST_STEP] == 1)
              begin
                buttonState[`INST_STEP] <= 0;
                write <= 0;
                address <= register[PC];
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                state <= WAIT_INSTR;
              end
            else
            if (buttonState[`EXAMINE] == 1)
              begin
                buttonState[`EXAMINE] <= 0;
                write <= 0;
                register[PC] <= cpuInput0;
                address <= cpuInput0;
                cpuOutput0 = cpuInput0;
                state <= EXAMINE_WAIT_READ_MEM;
              end
            else
            if (buttonState[`EXAMINE_NEXT] == 1)
              begin
                buttonState[`EXAMINE_NEXT] <= 0;
                write <= 0;
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                state <= EXAMINE_WAIT_NEXT;
              end
            else
            if (buttonState[`DEPOSIT] == 1)
              begin
                buttonState[`DEPOSIT] <= 0;
                write <= 1;
                address <= register[PC];
                cpuOutput0 = register[PC];
                data_out <= cpuInput0;
                cpuOutput1 <= cpuInput0;
                state <= DEPOSIT_WAIT_WRITE_MEM;
              end
            else
            if (buttonState[`DEPOSIT_NEXT] == 1)
              begin
                buttonState[`DEPOSIT_NEXT] <= 0;
                write <= 0;
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                state <= DEPOSIT_WAIT_NEXT;
              end
          end
        EXAMINE_WAIT_NEXT:
          begin
            $display("EXAMINE_WAIT_NEXT");
            register[PC] <= result;
            address <= result;
            cpuOutput0 <= result;
            state <= EXAMINE_WAIT_READ_MEM;
          end
        EXAMINE_WAIT_READ_MEM:
          begin
            $display("EXAMINE_WAIT_READ_MEM");
            state <= EXAMINE_SHOW_READ_MEM;
          end
        EXAMINE_SHOW_READ_MEM:
          begin
            $display("EXAMINE_WAIT_READ_MEM");
            cpuOutput1 <= data_in;
            state <= STOPPED;
          end
        DEPOSIT_WAIT_NEXT:
          begin
            $display("DEPOSIT_WAIT_NEXT");
            write <= 1;
            register[PC] <= result;
            address <= result;
            cpuOutput0 <= result;
            data_out <= cpuInput0;
            cpuOutput1 <= cpuInput0;
            state <= DEPOSIT_WAIT_WRITE_MEM;
          end
        DEPOSIT_WAIT_WRITE_MEM:
          begin
            $display("DEPOSIT_WAIT_WRITE_MEM");
            write <= 0;
            state <= STOPPED;
          end
      endcase
      $display("   State=%02X,R0=%04X,R1=%04X,R2=%04X,R3=%04X,R4=%04X,R5=%04X,R6=%04X,R7=%04X,C=%B,Z=%B,N=%B,Address=%04x,data_in=%04X",state,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7],carry,zero,negative,address,data_in);
    end
endmodule
`endif
