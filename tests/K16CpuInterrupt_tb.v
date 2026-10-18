// ----------------------------------------------------------------------------
// K16Cpu: interrupts. Entry (push PC, clear I, jump to the vector at 0x0FFF),
// return, requests ignored while interrupts are disabled and in the handler,
// a request while hold is active, a request while the CPU is stopped, and a
// stress test with random interrupt requests and random hold clocks.
//
// Every test runs the same workload, which must produce the same results as
// without interrupts: the handler must not change registers or flags.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Cpu.v"

module K16CpuInterrupt_tb();
`include "K16Test.vh"
`include "K16CpuBench.vh"

  localparam ISR       = 16'h001E;   // address of Isr
  localparam ISR_COUNT = 16'h0028;   // address of IsrCount

  task load_program;
    begin
      clear_memory;
      // ; Workload for the interrupt tests: a pseudo random sequence that passes the
      // ; carry flag between instructions, so an interrupt handler that changed
      // ; registers or flags would change the results at 0x0E00 .. 0x0EC7.
      mem['h0000] = 16'h7b0f; //          LDHZ SP 0x0F            ; SP = 0x0F00
      mem['h0001] = 16'h601e; //          LDL R0 Isr.L
      mem['h0002] = 16'h6100; //          LDH R0 Isr.H
      mem['h0003] = 16'h64ff; //          LDL R1 0x0FFF.L
      mem['h0004] = 16'h650f; //          LDH R1 0x0FFF.H
      mem['h0005] = 16'he080; //          STO R0 [R1]             ; interrupt vector
      mem['h0006] = 16'h6200; //          LDLZ R0 0
      mem['h0007] = 16'he3a0; //          STO R0 IsrCount
      mem['h0008] = 16'h200b; //          SEI
      mem['h0009] = 16'h6231; //          LDLZ R0 0x31            ; R0 = state
      mem['h000a] = 16'h670e; //          LDHZ R1 0x0E            ; R1 = result pointer
      mem['h000b] = 16'h6ac8; //          LDLZ R2 200             ; R2 = loop counter
      mem['h000c] = 16'hbc06; // Loop:    JSR Step
      mem['h000d] = 16'he080; //          STO R0 [R1]
      mem['h000e] = 16'h048c; //          INC R1 R1
      mem['h000f] = 16'h090f; //          DEC R2 R2
      mem['h0010] = 16'h4ffb; //          BZC Loop
      mem['h0011] = 16'h200a; //          CLI
      mem['h0012] = 16'h9fff; //          HLT
      //
      mem['h0013] = 16'h2c0c; // Step:    PSH R3
      mem['h0014] = 16'h2c01; //          SHL R3 R0
      mem['h0015] = 16'h0031; //          ADC R0 R0 R3            ; uses the carry of SHL
      mem['h0016] = 16'h2c03; //          ROR R3 R0               ; uses the carry of ADC
      mem['h0017] = 16'h0036; //          XOR R0 R0 R3
      mem['h0018] = 16'h6e5b; //          LDLZ R3 0x5B
      mem['h0019] = 16'h0030; //          ADD R0 R0 R3
      mem['h001a] = 16'h4781; //          BCC NoCarry
      mem['h001b] = 16'h000c; //          INC R0 R0
      mem['h001c] = 16'h2c0d; // NoCarry: POP R3
      mem['h001d] = 16'h3c0d; //          RET
      //
      // ; Interrupt handler: counts the interrupts in IsrCount
      mem['h001e] = 16'h200e; // Isr:     PSF
      mem['h001f] = 16'h200c; //          PSH R0
      mem['h0020] = 16'hc387; //          LD R0 IsrCount
      mem['h0021] = 16'h000c; //          INC R0 R0
      mem['h0022] = 16'he385; //          STO R0 IsrCount
      mem['h0023] = 16'h000e; //          CMP R0 R0               ; changes the flags (restored by POF)
      mem['h0024] = 16'h200d; //          POP R0
      mem['h0025] = 16'h200f; //          POF
      mem['h0026] = 16'h200b; //          SEI
      mem['h0027] = 16'h3c0d; //          RET
      mem['h0028] = 16'h0000; // IsrCount: .data 0
    end
  endtask

  // Count interrupt entries
  integer entries = 0;
  reg [5:0] previous_state = 0;
  always @(posedge clk)
    begin
      if (cpu.state == cpu.INTERRUPT_WAIT_WRITE_STACK && previous_state != cpu.INTERRUPT_WAIT_WRITE_STACK)
        entries = entries + 1;
      previous_state <= cpu.state;
    end

  // Random interrupt requests and hold clocks for the stress test
  reg     stress = 0;
  integer seed;
  always @(negedge clk)
    if (stress)
      begin
        hold <= ($random(seed) & 7) == 0;
        interrupt <= ($random(seed) % 150) == 0;
      end

  reg [15:0] golden[0:199];
  reg [15:0] golden_r0;
  integer i;
  integer errors;
  integer start_cycle;
  reg [15:0] return_address;
  reg [15:0] sp_before;

  task start_program;
    begin
      reset_cpu;
      load_program;
      entries = 0;
      start_at(16'h0000);
    end
  endtask

  task request_interrupt;
    begin
      @(negedge clk);
      interrupt = 1;
      @(negedge clk);
      interrupt = 0;
    end
  endtask

  // Wait until interrupts are enabled and the CPU is about to fetch an
  // instruction
  task wait_enabled;
    begin
      @(negedge clk);
      while (!(cpu.enableInterrupt && cpu.state == cpu.FETCH_INSTR))
        @(negedge clk);
    end
  endtask

  task wait_fetch;
    input [15:0] fetch_address;
    begin
      start_cycle = cycles;
      @(negedge clk);
      while (!(cpu.state == cpu.FETCH_INSTR && cpu.register[7] == fetch_address) && cycles - start_cycle < 10000)
        @(negedge clk);
    end
  endtask

  // The results must be the same as without interrupts
  task check_results;
    input [8*60-1:0] name;
    begin
      wait_halt(200000);
      $sformat(test_message, "%0s: program halted", name);
      check_equal(halted, 1, test_message);
      errors = 0;
      for (i = 0; i < 200; i = i + 1)
        if (mem[16'h0E00 + i] !== golden[i])
          errors = errors + 1;
      $sformat(test_message, "%0s: results unchanged", name);
      check_equal(errors, 0, test_message);
      $sformat(test_message, "%0s: R0 unchanged", name);
      check_equal(cpu.register[0], golden_r0, test_message);
      $sformat(test_message, "%0s: SP back at 0x0F00", name);
      check_equal(cpu.register[6], 16'h0F00, test_message);
      $sformat(test_message, "%0s: IsrCount = number of interrupt entries", name);
      check_equal(mem[ISR_COUNT], entries, test_message);
    end
  endtask

  initial
    begin
      test_section("Interrupts: workload without interrupts");
      start_program;
      wait_halt(200000);
      check_equal(halted, 1, "program halted");
      for (i = 0; i < 200; i = i + 1)
        golden[i] = mem[16'h0E00 + i];
      golden_r0 = cpu.register[0];
      check(golden[0] != golden[1] && golden[198] != golden[199], "results differ from each other");
      check_equal(mem[ISR_COUNT], 0, "no interrupts");

      test_section("Interrupts: requests while interrupts are disabled are ignored");
      start_program;
      repeat (5) @(negedge clk);
      check_equal(cpu.enableInterrupt, 0, "interrupts still disabled");
      request_interrupt;
      check_equal(cpu.handleInterrupt, 0, "request not latched");
      check_results("disabled");
      check_equal(entries, 0, "no interrupt entry");

      test_section("Interrupts: entry, return, and no nesting");
      start_program;
      wait_enabled;
      repeat (37) @(negedge clk);   // somewhere in the workload
      sp_before = cpu.register[6];
      request_interrupt;
      wait_fetch(ISR);
      check_equal(cpu.register[7], ISR, "jumps to the vector");
      check(cycles - start_cycle <= 12, "handler starts at most 12 clocks after the request");
      check_equal(cpu.enableInterrupt, 0, "entry disables interrupts");
      check_equal(entries, 1, "one entry");
      return_address = mem[cpu.register[6] + 1];
      check(return_address >= 16'h000C && return_address < ISR, "pushed return address is in the workload");
      // A request in the handler (interrupts disabled) is ignored
      request_interrupt;
      wait_fetch(return_address);
      check_equal(cpu.register[7], return_address, "RET returns to the interrupted instruction");
      check_equal(cpu.enableInterrupt, 1, "handler enabled interrupts again");
      check_results("one interrupt");
      check_equal(entries, 1, "no nested interrupt");

      test_section("Interrupts: request while hold is active");
      start_program;
      wait_enabled;
      repeat (20) @(negedge clk);
      hold = 1;
      repeat (3) @(negedge clk);
      request_interrupt;
      repeat (5) @(negedge clk);
      hold = 0;
      check_results("during hold");
      check_equal(entries, 1, "the request during hold was handled");

      test_section("Interrupts: request while the CPU is stopped");
      start_program;
      wait_enabled;
      repeat (20) @(negedge clk);
      stop = 1;
      @(negedge clk);
      stop = 0;
      repeat (40) @(negedge clk);
      check_equal(cpu.running, 0, "CPU stopped");
      request_interrupt;
      repeat (40) @(negedge clk);
      check_equal(cpu.handleInterrupt, 1, "request latched while stopped");
      check_equal(entries, 0, "not handled while stopped");
      press(`CONTINUE);
      check_results("while stopped");
      check_equal(entries, 1, "handled after CONTINUE");

      test_section("Interrupts: random interrupt requests and hold clocks");
      for (seed = 1; seed <= 3; seed = seed + 1)
        begin
          start_program;
          stress = 1;
          wait_halt(400000);
          stress = 0;
          hold = 0;
          interrupt = 0;
          $sformat(test_message, "seed %0d: many interrupts (%0d)", seed, entries);
          check(entries > 10, test_message);
          $sformat(test_message, "random, seed %0d", seed);
          check_results(test_message);
        end

      test_done;
    end

  initial
    begin
      #100000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
