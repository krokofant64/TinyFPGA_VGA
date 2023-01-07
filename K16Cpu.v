`ifndef K16CPU_V
`define K16CPU_V

`include "K16Alu.v"

//
`define ADDR_SWITCHES        16'hFFF8
`define CTRL_SWITCHES        16'hFFF9
`define ADDR_LEDS            16'hFFFA
`define DATA_LEDS            16'hFFFB
`define CMD_AND_REG_SWITCHES 16'hFFFC

//
`define NONE              0
`define START             1
`define CONTINUE          2
`define INST_STEP         3
`define EXAMINE           4
`define EXAMINE_NEXT      5
`define EXAMINE_REGISTER  6
`define DEPOSIT           7
`define DEPOSIT_NEXT      8
`define DEPOSIT_REGISTER  9


module K16Cpu(clk, reset, stop, hold, busy,
             address, data_in, data_out, write, statusR, statusG, statusB);
  input              clk;
  input              reset;
  input              stop;
  input              hold;
  output reg         busy;
  output reg [15:0]  address;
  input  [15:0]      data_in;
  output reg [15:0]  data_out;
  output reg         write;
  output reg         statusR;
  output reg         statusG;
  output reg         statusB;

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
  localparam PANEL_EXAMINE_WAIT_NEXT = 17;
  localparam PANEL_DEPOSIT_WAIT_NEXT = 18;
  localparam PANEL_DEPOSIT_WAIT_WRITE_MEM = 19;
  localparam PANEL_START_WAIT_ADDR = 20;
  localparam PANEL_EXAMINE_WAIT_ADDR = 21;
  localparam PANEL_DEPOSIT_WAIT_DATA = 22;
  localparam PANEL_DEPOSIT_WRITE_DATA = 23;
  localparam PANEL_DECODE_CTRL_SWITCHES = 24;
  localparam PANEL_EXAMINE_REG_WAIT_REG = 25;
  localparam PANEL_SHOW_REG = 26;
  localparam PANEL_DEPOSIT_REG_WAIT_REG = 27;
  localparam PANEL_DEPOSIT_REG_FETCH_DATA = 28;
  localparam PANEL_DEPOSIT_REG_WAIT_DATA = 29;
  localparam PANEL_DEPOSIT_REG_WRITE_DATA = 30;
  localparam PANEL_FETCH_DATA = 31;
  localparam PANEL_WAIT_DATA = 32;
  localparam PANEL_SHOW_DATA = 33;
  localparam PANEL_SHOW_ADDR = 34;
  localparam PANEL_WAIT_CTRL_SWITCHES = 35;
  localparam PANEL_EXAMINE_SET_ADDR = 36;

  // 8 16-bit registers
  reg [15:0] register[0:7];

  localparam SP = 6; // SP in register 6
  localparam PC = 7; // PC in register 7

  reg [2:0] destReg;

  // Flags
  reg carry;
  reg negative;
  reg zero;
  reg overflow;
  reg enableInterrupt;

  // CPU state
  reg [5:0] state = RESET;

  reg [15:0]  operand1;
  reg [15:0]  operand2;
  wire [15:0] result;
  reg [2:0]   operation;
  reg [1:0]   operationType;
  reg         running = 0;
  wire        carryOut;
  wire        zeroOut;
  wire        negativeOut;

  reg         key_valid;

  K16Alu alu(
    .operand1(operand1),
    .operand2(operand2),
    .carryIn(carry),
    .operationType(operationType),
    .operation(operation),
    .result(result),
    .carryOut(carryOut),
    .zeroOut(zeroOut),
    .negativeOut(negativeOut));

  always @(posedge clk)
    if (reset)
      begin
        $display("Reset");
        state <= RESET;
        busy <= 0;
        running <= 0;
        key_valid <= 1;
      end
    else
    if (stop)
      begin
        $display("Stop");
        busy <= 0;
        running <= 0;
        key_valid <= 1;
      end
    else
    begin
      if (running)
        begin
          statusR <= 0;
          statusG <= 1;
          statusB <= 0;
        end
      else
        begin
          statusR <= 1;
          statusG <= 0;
          statusB <= 0;
        end
       case (state)
         RESET:
           begin
             $display("RESET");
             write <= 0;
             register[0] <= 16'h0000;
             register[1] <= 16'h0000;
             register[2] <= 16'h0000;
             register[3] <= 16'h0000;
             register[4] <= 16'h0000;
             register[5] <= 16'h0000;
             register[SP] <= 16'h0000;
             register[PC] <= 16'h0000;
             carry <= 0;
             zero <= 0;
             negative <= 0;
             running <= 0;
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
               begin
                 write <= 0;
                 state <= PANEL_FETCH_DATA;
               end
           end
         WAIT_INSTR:
           begin
             $display("WAIT_INSTR address=%04X", address);
             write <= 0;
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
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    destReg <= data_in[12:10];
                    state <= STORE_RESULT_AND_CARRY;
                    $display("  operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????01??:
                  begin
                    $display("DECODE_INSTR - AND (4), OR (5), XOR (6), NOT (7)");
                    // ADD (0), ADC (1), SUB (2), SBC (3), AND (4), OR (5), XOR (6), NOT (7)
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= data_in[2:0];
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    destReg <= data_in[12:10];
                    state <= STORE_RESULT;
                    $display("   operation=%03B,operand1=%03B,operand2=%03B,dest=%03B",data_in[2:0],data_in[9:7],data_in[6:4],data_in[12:10]);
                  end
                16'b000?????????10??:
                  begin
                    $display("DECODE_INSTR - LD (0), LDL (1), LDH (2), SWP (3)");
                    write <= 0;
                    operationType <= `LOAD_OP;
                    operation <= {1'b0, data_in[1:0]};
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[12:10]];
                    destReg <= data_in[12:10];
                    state <= STORE_RESULT;
                  end
                16'b000?????????1100:
                  begin
                    $display("DECODE_INSTR - INC");
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    destReg <= data_in[12:10];
                    state <= STORE_RESULT;
                  end
                16'b000?????????1110:
                  begin
                    $display("DECODE_INSTR - CMP");
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= register[data_in[6:4]];
                    state <= STORE_FLAGS;
                  end
                16'b000?????????1111:
                  begin
                    $display("DECODE_INSTR - DEC");
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= 16'h0001;
                    destReg <= data_in[12:10];
                    state <= STORE_RESULT;
                  end
                16'b001?????????0???:
                  begin
                    $display("DECODE_INSTR - SHR (0), ASHL/SHL (1), ASHR (2), ROR (3), ROL(4)");
                    write <= 0;
                    operationType <= `SHIFT_OP;
                    operation <= {data_in[2:0]};
                    operand1 <= register[data_in[9:7]];
                    destReg <= data_in[12:10];
                    state <= STORE_RESULT_AND_CARRY;
                  end
                16'b001?????????10??:
                  begin
                    $display("DECODE_INSTR -  CLC (0), SEC (1), CLI (2), SEI (3)");
                    write <= 0;
                    if (data_in[1] == 1'b0)
                      begin
                        carry <= data_in[0];
                      end
                    else
                      begin
                        enableInterrupt <= data_in[0];
                      end
                    state <= FETCH_INSTR;
                  end
                16'b001?????????1100:
                  begin
                    $display("DECODE_INSTR -  PSH");
                    write <= 1;
                    address <= register[SP];
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[SP];
                    operand2 <= 16'h0001;
                    destReg <= SP;
                    data_out <= register[data_in[12:10]];
                    state <= PSH_WAIT_WRITE_STACK;
                  end
                  16'b001?????????1101:
                    begin
                      $display("DECODE_INSTR -  POP");
                      write <= 0;
                      operationType <= `ALU_OP;
                      operation <= `ADD_OP;
                      operand1 <= register[SP];
                      operand2 <= 16'h0001;
                      destReg <= data_in[12:10];
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
                        write <= 0;
                        operationType <= `ALU_OP;
                        operation <= `ADD_OP;
                        operand1 <= register[data_in[9:7]];
                        operand2 <= {{9{data_in[6]}}, data_in[6:0]};;
                        state <= JUMP;
                      end
                    else
                      begin
                        write <= 0;
                        state <= FETCH_INSTR;
                      end
                  end
                16'b011?????????????:
                  begin
                     $display("DECODE_INSTR - LDL imm8 (0), LDH imm8 (1), LDLZ imm8 (2), LDHZ imm8 (3)");
                     write <= 0;
                     operationType <= `LOAD_OP;
                     operation <= {1'b1, data_in[9:8]};
                     operand1 <= register[data_in[12:10]];
                     operand2 <= {8'b00000000, data_in[7:0]};
                     destReg <= data_in[12:10];
                     state <= STORE_RESULT;
                  $display("   operation=%03B,operand1=%04X,dest=%03B",operation,operand1,data_in[12:10]);
                  end
                16'b100?????????????:
                  begin
                    if (data_in[12:0] != 13'h1FFF)
                      begin
                        $display("DECODE_INSTR - JMP");
                        write <= 0;
                        operationType <= `ALU_OP;
                        operation <= `ADD_OP;
                        operand1 <= register[data_in[12:10]];
                        operand2 <= {{6{data_in[9]}}, data_in[9:0]};
                        state <= JUMP;
                        $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{6{data_in[9]}}, data_in[9:0]});
                      end
                    else
                      begin
                        $display("DECODE_INSTR - HLT");
                        write <= 0;
                        state <= PANEL_FETCH_DATA;
                      end
                  end
                16'b1001111111111111:
                  begin
                  end
                16'b101?????????????:
                  begin
                    $display("DECODE_INSTR - JSR");
                    write <= 1;
                    address <= register[SP];
                    operationType <= `ALU_OP;
                    operation <= `SUB_OP;
                    operand1 <= register[SP];
                    operand2 <= 16'h0001;
                    destReg <= SP;
                    data_out <= register[PC];
                    state <= JSR_WAIT_WRITE_STACK;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{6{data_in[9]}}, data_in[9:0]});
                  end
                16'b110?????????????:
                  begin
                    $display("DECODE_INSTR - LD [MEM]");
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= {{9{data_in[6]}}, data_in[6:0]};
                    destReg <= data_in[12:10];
                    state <= LD_CALC_MEM_ADDR;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{9{data_in[6]}}, data_in[6:0]});
                  end
                16'b111?????????????:
                  begin
                    $display("DECODE_INSTR - STO");
                    write <= 0;
                    operationType <= `ALU_OP;
                    operation <= `ADD_OP;
                    operand1 <= register[data_in[9:7]];
                    operand2 <= {{9{data_in[6]}}, data_in[6:0]};
                    destReg <= data_in[12:10];
                    state <= STO_CALC_MEM_ADDR;
                    $display("   operation=%03B,operand1=%04X,operand2=%04x",1'b0,data_in[12:10],{{9{data_in[6]}}, data_in[6:0]});
                  end
                default:
                  begin
                    $display("Invalid instruction");
                    write <= 0;
                  end
              endcase
           end
         STORE_RESULT:
           begin
              $display("STORE_RESULT R%d = %04X", destReg, result);
              write <= 0;
              register[destReg] <= result;
              zero <= zeroOut;
              negative <= negativeOut;
              state <= FETCH_INSTR;
           end
         STORE_RESULT_AND_CARRY:
           begin
             $display("STORE_RESULT_AND_CARRY R%d = %04X", destReg, result);
             write <= 0;
             register[destReg] <= result;
             carry <= carryOut;
             zero <= zeroOut;
             negative <= negativeOut;
             state <= FETCH_INSTR;
           end
         STORE_FLAGS:
           begin
             $display("STORE_FLAGS");
             write <= 0;
             carry <= carryOut;
             zero <= zeroOut;
             negative <= negativeOut;
             state <= FETCH_INSTR;
           end
         JUMP:
           begin
             $display("JUMP");
             write <= 0;
             register[PC] <= result;
             state <= FETCH_INSTR;
           end
         LD_CALC_MEM_ADDR:
           begin
             $display("LD_CALC_MEM_ADDR");
             write <= 0;
             address <= result;
             state <= WAIT_READ_MEM;
           end
         WAIT_READ_MEM:
           begin
             $display("WAIT_READ_MEM");
             write <= 0;
             state <= STORE_READ_MEM;
           end
         STORE_READ_MEM:
           begin
             $display("STORE_READ_MEM");
             write <= 0;
             register[destReg] <= data_in;
             zero <= data_in == 16'h0000 ? 1'b1 : 1'b0;
             negative <= data_in[15] == 1'b1 ? 1'b1 : 1'b0;
             state <= FETCH_INSTR;
           end
         STO_CALC_MEM_ADDR:
           begin
             $display("STO_CALC_MEM_ADDR");
             write <= 1;
             address <= result;
             data_out <= register[destReg];
             state <= WAIT_WRITE_MEM;
           end
        WAIT_WRITE_MEM:
          begin
            $display("WAIT_WRITE_MEM");
            write <= 1;
            state <= FETCH_INSTR;
          end
        PSH_WAIT_WRITE_STACK:
          begin
            $display("PSH_WAIT_WRITE_STACK");
            write <= 0;
            register[destReg] <= result;
            state <= FETCH_INSTR;
          end
        POP_CALCULATE_SP:
          begin
             $display("POP_CALCULATE_SP");
             write <= 0;
             address <= result;
             register[SP] <= result;
             state <= WAIT_READ_MEM;
          end
        JSR_WAIT_WRITE_STACK:
          begin
            $display("JSR_WAIT_WRITE_STACK");
            write <= 0;
            register[destReg] <= result;
            operationType <= `ALU_OP;
            operation <= `ADD_OP;
            operand1 <= register[data_in[12:10]];
            operand2 <= {{6{data_in[9]}}, data_in[9:0]};
            state <= JUMP;
          end
        STOPPED:
          begin
            write <= 0;
            address <= `CMD_AND_REG_SWITCHES;
            state <= PANEL_WAIT_CTRL_SWITCHES;
            $display("STOPPED");
          end
        PANEL_WAIT_CTRL_SWITCHES:
          begin
            $display("PANEL_WAIT_CTRL_SWITCHES");
            write <= 0;
            state <= PANEL_DECODE_CTRL_SWITCHES;
          end
        PANEL_DECODE_CTRL_SWITCHES:
          begin
            $display("PANEL_DECODE_CTRL_SWITCHES data_in: %04X, key_valid: %d", data_in, key_valid);
            if (key_valid && data_in[6:3] == `START)
              begin
                $display("*****************");
                $display("* START PRESSED *");
                $display("*****************");
                write <= 0;
                address <= `ADDR_SWITCHES;
                key_valid <= 0;
                state <= PANEL_START_WAIT_ADDR;
              end
            else if (key_valid && data_in[6:3] == `CONTINUE)
              begin
                $display("********************");
                $display("* CONTINUE PRESSED *");
                $display("********************");
                write <= 0;
                running <= 1;
                address <= register[PC];
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                key_valid <= 0;
                state <= WAIT_INSTR;
              end
            else if (key_valid && data_in[6:3] == `INST_STEP)
              begin
                $display("*********************");
                $display("* INST_STEP PRESSED *");
                $display("*********************");
                write <= 0;
                address <= register[PC];
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                key_valid <= 0;
                state <= WAIT_INSTR;
              end
            else if (key_valid && data_in[6:3] == `EXAMINE)
              begin
                $display("*******************");
                $display("* EXAMINE PRESSED *");
                $display("*******************");
                write <= 0;
                address <= `ADDR_SWITCHES;
                key_valid <= 0;
                state <= PANEL_EXAMINE_WAIT_ADDR;
              end
            else if (key_valid && data_in[6:3] == `EXAMINE_NEXT)
              begin
                $display("************************");
                $display("* EXAMINE_NEXT PRESSED *");
                $display("************************");
                write <= 0;
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                key_valid <= 0;
                state <= PANEL_EXAMINE_WAIT_NEXT;
              end
            else if (key_valid && data_in[6:3] == `EXAMINE_REGISTER)
              begin
                $display("****************************");
                $display("* EXAMINE_REGISTER PRESSED *");
                $display("****************************");
                write <= 0;
                address <= `CMD_AND_REG_SWITCHES;
                key_valid <= 0;
                state <= PANEL_EXAMINE_REG_WAIT_REG;
              end
            else if (key_valid && data_in[6:3] == `DEPOSIT)
              begin
                $display("*******************");
                $display("* DEPOSIT PRESSED *");
                $display("*******************");
                write <= 0;
                address <= `ADDR_SWITCHES;
                key_valid <= 0;
                state <= PANEL_DEPOSIT_WAIT_DATA;
              end
            else if (key_valid && data_in[6:3] == `DEPOSIT_NEXT)
              begin
                $display("************************");
                $display("* DEPOSIT_NEXT PRESSED *");
                $display("************************");
                write <= 0;
                address <= `ADDR_SWITCHES;
                operationType <= `ALU_OP;
                operation <= `ADD_OP;
                operand1 <= register[PC];
                operand2 <= 1;
                key_valid <= 0;
                state <= PANEL_DEPOSIT_WAIT_NEXT;
              end
            else if (key_valid && data_in[6:3] == `DEPOSIT_REGISTER)
              begin
                $display("****************************");
                $display("* DEPOSIT_REGISTER PRESSED *");
                $display("****************************");
                write <= 0;
                address <= `CMD_AND_REG_SWITCHES;
                key_valid <= 0;
                state <= PANEL_DEPOSIT_REG_WAIT_REG;
              end
            else
              begin
                key_valid <= (data_in[6:3] == `NONE);
                state <= STOPPED;
              end
          end
        PANEL_START_WAIT_ADDR:
          begin
            $display("PANEL_START_WAIT_ADDR");
            write <= 0;
            running <= 1;
            register[PC] <= data_in;
            address <= data_in;
            operationType <= `ALU_OP;
            operation <= `ADD_OP;
            operand1 <= data_in;
            operand2 <= 1;
            state <= WAIT_INSTR;
          end
        PANEL_EXAMINE_WAIT_ADDR:
          begin
            $display("PANEL_EXAMINE_WAIT_ADDR");
            write <= 0;
            state <= PANEL_EXAMINE_SET_ADDR;
          end
          PANEL_EXAMINE_SET_ADDR:
            begin
              $display("PANEL_EXAMINE_SET_ADDR");
              write <= 0;
              register[PC] <= data_in;
              address <= data_in;
              state <= PANEL_WAIT_DATA;
            end
        PANEL_EXAMINE_WAIT_NEXT:
          begin
            $display("PANEL_EXAMINE_WAIT_NEXT");
            write <= 0;
            register[PC] <= result;
            address <= result;
            state <= PANEL_WAIT_DATA;
          end
        PANEL_DEPOSIT_WAIT_DATA:
            begin
              $display("PANEL_DEPOSIT_WAIT_DATA");
              write <= 0;
              state <= PANEL_DEPOSIT_WRITE_DATA;
            end
        PANEL_DEPOSIT_WRITE_DATA:
          begin
            $display("PANEL_DEPOSIT_WRITE_DATA");
            write <= 1;
            address <= register[PC];
            data_out <= data_in;
            state <= PANEL_FETCH_DATA;
          end
        PANEL_DEPOSIT_WAIT_NEXT:
          begin
            $display("PANEL_DEPOSIT_WAIT_NEXT");
            write <= 0;
            register[PC] <= result;
            state <= PANEL_DEPOSIT_WRITE_DATA;
          end
        PANEL_DEPOSIT_WAIT_WRITE_MEM:
          begin
            $display("PANEL_DEPOSIT_WAIT_WRITE_MEM");
            write <= 0;
            state <= STOPPED;
          end
        PANEL_EXAMINE_REG_WAIT_REG:
          begin
            $display("PANEL_EXAMINE_REG_WAIT_REG");
            write <= 0;
            state <= PANEL_SHOW_REG;
          end
        PANEL_DEPOSIT_REG_WAIT_REG:
          begin
            $display("PANEL_DEPOSIT_REG_WAIT_REG - destReg: %d, data_in = %04X", destReg, data_in);
            write <= 0;
            state <= PANEL_DEPOSIT_REG_FETCH_DATA;
          end
         PANEL_DEPOSIT_REG_FETCH_DATA:
          begin
            $display("PANEL_DEPOSIT_REG_FETCH_DATA - destReg: %d, data_in = %04X", destReg, data_in);
            write <= 0;
            destReg <= data_in[2:0];
            address <= `ADDR_SWITCHES;
            state <= PANEL_DEPOSIT_REG_WAIT_DATA;
          end
        PANEL_DEPOSIT_REG_WAIT_DATA:
          begin
            $display("PANEL_DEPOSIT_REG_WAIT_DATA - destReg: %d, data_in = %04X", destReg, data_in);
            write <= 0;
            state <= PANEL_DEPOSIT_REG_WRITE_DATA;
          end
        PANEL_DEPOSIT_REG_WRITE_DATA:
          begin
            $display("PANEL_DEPOSIT_REG_WRITE_DATA - destReg: %d, data_in = %04X", destReg, data_in);
            write <= 1;
            register[destReg] <= data_in;
            data_out <= data_in;
            address <= `DATA_LEDS;
            state <= PANEL_SHOW_ADDR;
          end
        PANEL_SHOW_REG:
          begin
            $display("PANEL_SHOW_REG");
            write <= 1;
            data_out <= register[data_in[2:0]];
            address <= `DATA_LEDS;
            state <= PANEL_SHOW_ADDR;
          end
        PANEL_FETCH_DATA:
          begin
            $display("PANEL_FETCH_DATA");
            write <= 0;
            address <= register[PC];
            state <= PANEL_WAIT_DATA;
          end
        PANEL_WAIT_DATA:
          begin
            $display("PANEL_WAIT_DATA");
            write <= 0;
            state <= PANEL_SHOW_DATA;
          end
        PANEL_SHOW_DATA:
          begin
            $display("PANEL_SHOW_DATA");
            write <= 1;
            data_out <= data_in;
            address <= `DATA_LEDS;
            state <= PANEL_SHOW_ADDR;
          end
        PANEL_SHOW_ADDR:
          begin
            $display("PANEL_SHOW_ADDR");
            write <= 1;
            address <= `ADDR_LEDS;
            data_out <= register[PC];
            state <= STOPPED;
          end
      endcase
      $display(".  State=%02X,R0=%04X,R1=%04X,R2=%04X,R3=%04X,R4=%04X,R5=%04X,R6=%04X,R7=%04X,C=%B,Z=%B,N=%B,Address=%04x,data_in=%04X,write=%01X",state,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7],carry,zero,negative,address,data_in,write);
    end
endmodule

`endif
