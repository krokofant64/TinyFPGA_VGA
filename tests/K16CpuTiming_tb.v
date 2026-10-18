// ----------------------------------------------------------------------------
// K16Cpu: clock cycles of every instruction class (from one instruction
// fetch to the next), interrupt entry, and that hold and the interrupt
// request freeze the CPU without changing the result.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Cpu.v"

module K16CpuTiming_tb();
`include "K16Test.vh"
`include "K16CpuBench.vh"

  integer start_cycle;
  integer measured;

  // Run the instruction at 0x0100 (followed by HLT) and measure the clocks
  // until the CPU fetches the next instruction
  task measure;
    input [15:0] instruction;
    begin
      mem[16'h0100] = instruction;
      mem[16'h0101] = 16'h9FFF; // HLT
      start_at(16'h0100);
      start_cycle = cycles;
      @(negedge clk);
      while (cpu.state != cpu.FETCH_INSTR && cycles - start_cycle < 100)
        @(negedge clk);
      measured = cycles - start_cycle;
      cpu.running = 0; // back to the front panel loop
      repeat (20) @(negedge clk);
    end
  endtask

  task check_cycles;
    input [15:0] instruction;
    input integer expected;
    input [8*40-1:0] name;
    begin
      measure(instruction);
      $sformat(test_message, "%0s takes %0d clocks", name, expected);
      check_equal(measured, expected, test_message);
    end
  endtask

  initial
    begin
      clear_memory;
      reset_cpu;
      cpu.register[0] = 16'h1234;
      cpu.register[1] = 16'h0300; // address for LD and STO

      test_section("CPU timing: ALU, register, and immediate instructions (4 clocks)");
      check_cycles(16'h0810, 4, "ADD R2 R0 R1");
      check_cycles(16'h0811, 4, "ADC R2 R0 R1");
      check_cycles(16'h0812, 4, "SUB R2 R0 R1");
      check_cycles(16'h0813, 4, "SBC R2 R0 R1");
      check_cycles(16'h0814, 4, "AND R2 R0 R1");
      check_cycles(16'h0815, 4, "OR R2 R0 R1");
      check_cycles(16'h0816, 4, "XOR R2 R0 R1");
      check_cycles(16'h0807, 4, "NOT R2 R0");
      check_cycles(16'h0808, 4, "LD R2 R0");
      check_cycles(16'h0809, 4, "LDL R2 R0");
      check_cycles(16'h080A, 4, "LDH R2 R0");
      check_cycles(16'h080B, 4, "SWP R2 R0");
      check_cycles(16'h080C, 4, "INC R2 R0");
      check_cycles(16'h080F, 4, "DEC R2 R0");
      check_cycles(16'h001E, 4, "CMP R0 R1");
      check_cycles(16'h2800, 4, "SHR R2 R0");
      check_cycles(16'h2801, 4, "SHL R2 R0");
      check_cycles(16'h2802, 4, "ASHR R2 R0");
      check_cycles(16'h2803, 4, "ROR R2 R0");
      check_cycles(16'h2804, 4, "ROL R2 R0");
      check_cycles(16'h6812, 4, "LDL R2 0x12");
      check_cycles(16'h6912, 4, "LDH R2 0x12");
      check_cycles(16'h6A12, 4, "LDLZ R2 0x12");
      check_cycles(16'h6B12, 4, "LDHZ R2 0x12");

      test_section("CPU timing: flag instructions (3 clocks)");
      check_cycles(16'h2008, 3, "CLC");
      check_cycles(16'h2009, 3, "SEC");
      check_cycles(16'h200A, 3, "CLI");
      check_cycles(16'h200B, 3, "SEI");
      cpu.enableInterrupt = 0;

      test_section("CPU timing: branches and jumps");
      cpu.flags[cpu.ZERO] = 0;
      check_cycles(16'h4B80, 3, "BZS [PC] (not taken)");
      cpu.flags[cpu.ZERO] = 1;
      check_cycles(16'h4B80, 4, "BZS [PC] (taken)");
      check_cycles(16'h9C00, 4, "JMP [PC]");
      cpu.register[6] = 16'h0200;
      check_cycles(16'hBC00, 5, "JSR [PC]");

      test_section("CPU timing: memory and stack instructions");
      check_cycles(16'hC880, 6, "LD R2 [R1]");
      check_cycles(16'hE880, 5, "STO R2 [R1]");
      cpu.register[6] = 16'h0200;
      check_cycles(16'h200C, 4, "PSH R0");
      check_cycles(16'h200E, 4, "PSF");
      cpu.register[6] = 16'h0200;
      check_cycles(16'h280D, 6, "POP R2");
      check_cycles(16'h200F, 6, "POF");
      cpu.register[6] = 16'h0200;
      mem[16'h0201] = 16'h0101;   // return address
      check_cycles(16'h3C0D, 6, "RET");

      test_section("CPU timing: interrupt entry (4 clocks to the first instruction of the handler)");
      mem[16'h0FFF] = 16'h0101;   // vector
      cpu.register[6] = 16'h0200;
      mem[16'h0100] = 16'h9FFF;
      start_at(16'h0100);
      cpu.handleInterrupt = 1;
      start_cycle = cycles;
      @(negedge clk);
      while (cpu.state != cpu.FETCH_INSTR && cycles - start_cycle < 100)
        @(negedge clk);
      check_equal(cycles - start_cycle, 4, "interrupt entry takes 4 clocks");
      check_equal(cpu.register[7], 16'h0101, "PC = interrupt vector");
      check_equal(cpu.register[6], 16'h01FF, "SP after pushing the return address");
      check_equal(mem[16'h0200], 16'h0100, "pushed return address");
      cpu.running = 0;
      repeat (20) @(negedge clk);

      test_section("CPU timing: hold and an interrupt request freeze the CPU");
      cpu.register[0] = 16'h1234;
      cpu.register[1] = 16'h1111;
      mem[16'h0100] = 16'h0810;   // ADD R2 R0 R1
      mem[16'h0101] = 16'h9FFF;
      start_at(16'h0100);
      start_cycle = cycles;
      @(negedge clk);
      @(negedge clk);
      hold = 1;                   // 3 clocks in the middle of the instruction
      repeat (3) @(negedge clk);
      hold = 0;
      while (cpu.state != cpu.FETCH_INSTR && cycles - start_cycle < 100)
        @(negedge clk);
      check_equal(cycles - start_cycle, 4 + 3, "ADD with 3 hold clocks takes 7 clocks");
      check_equal(cpu.register[2], 16'h2345, "ADD result with hold");
      cpu.running = 0;
      repeat (20) @(negedge clk);

      cpu.enableInterrupt = 1;    // the request is latched in an extra clock
      mem[16'h0FFF] = 16'h0101;
      cpu.register[6] = 16'h0200;
      start_at(16'h0100);
      start_cycle = cycles;
      @(negedge clk);
      @(negedge clk);
      interrupt = 1;
      @(negedge clk);
      interrupt = 0;
      while (cpu.state != cpu.FETCH_INSTR && cycles - start_cycle < 100)
        @(negedge clk);
      check_equal(cycles - start_cycle, 4 + 1, "ADD with an interrupt request takes 5 clocks");
      check_equal(cpu.register[2], 16'h2345, "ADD result with an interrupt request");
      check_equal(cpu.handleInterrupt, 1, "interrupt request latched");
      cpu.running = 0;

      test_done;
    end

  initial
    begin
      #10000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
