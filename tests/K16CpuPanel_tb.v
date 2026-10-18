// ----------------------------------------------------------------------------
// K16Cpu: the front panel commands (EXAMINE, EXAMINE NEXT, DEPOSIT,
// DEPOSIT NEXT, EXAMINE/DEPOSIT register, START, CONTINUE, INST STEP),
// one action per key press, the LEDs, the status LED, STOP, RESET, and HLT.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Cpu.v"

module K16CpuPanel_tb();
`include "K16Test.vh"
`include "K16CpuBench.vh"

  reg [15:0] r5;

  initial
    begin
      clear_memory;
      // 0x0010: LDLZ R0 5 / INC R0 R0 / HLT
      mem[16'h0010] = 16'h6205;
      mem[16'h0011] = 16'h000C;
      mem[16'h0012] = 16'h9FFF;
      // 0x0020: LDLZ R1 1 / LDLZ R2 2 / LDLZ R3 3 / HLT / LDLZ R4 4 / LDLZ R4 5 / HLT
      mem[16'h0020] = 16'h6601;
      mem[16'h0021] = 16'h6A02;
      mem[16'h0022] = 16'h6E03;
      mem[16'h0023] = 16'h9FFF;
      mem[16'h0024] = 16'h7204;
      mem[16'h0025] = 16'h7205;
      mem[16'h0026] = 16'h9FFF;
      // 0x0030: Loop: INC R5 R5 / JMP Loop
      mem[16'h0030] = 16'h168C;
      mem[16'h0031] = 16'h9FFE;

      test_section("Front panel: after reset");
      reset_cpu;
      check_equal(cpu.running, 0, "not running after reset");
      check_equal({statusR, statusG, statusB}, 3'b100, "status LED red");
      check_equal(cpu.register[6], 16'h0FFE, "SP after reset");
      check_equal(cpu.register[7], 16'h0000, "PC after reset");
      check_equal(addr_leds, 16'h0000, "address LEDs show PC");

      test_section("Front panel: EXAMINE and EXAMINE NEXT");
      addr_switches = 16'h0020;
      press(`EXAMINE);
      check_equal(cpu.register[7], 16'h0020, "EXAMINE sets PC");
      check_equal(addr_leds, 16'h0020, "EXAMINE: address LEDs");
      check_equal(data_leds, 16'h6601, "EXAMINE: data LEDs show the memory");
      press(`EXAMINE_NEXT);
      check_equal(cpu.register[7], 16'h0021, "EXAMINE NEXT increments PC");
      check_equal(addr_leds, 16'h0021, "EXAMINE NEXT: address LEDs");
      check_equal(data_leds, 16'h6A02, "EXAMINE NEXT: data LEDs");
      // Holding the switch performs the command only once
      @(negedge clk);
      panel_command = `EXAMINE_NEXT;
      repeat (500) @(negedge clk);
      panel_command = `NONE;
      repeat (40) @(negedge clk);
      check_equal(cpu.register[7], 16'h0022, "a held switch acts only once");

      test_section("Front panel: DEPOSIT and DEPOSIT NEXT");
      addr_switches = 16'h0040;
      press(`EXAMINE);
      addr_switches = 16'hABCD;
      press(`DEPOSIT);
      check_equal(mem[16'h0040], 16'hABCD, "DEPOSIT writes the switches to mem[PC]");
      check_equal(cpu.register[7], 16'h0040, "DEPOSIT keeps PC");
      check_equal(data_leds, 16'hABCD, "DEPOSIT: data LEDs");
      addr_switches = 16'h1111;
      press(`DEPOSIT_NEXT);
      addr_switches = 16'h2222;
      press(`DEPOSIT_NEXT);
      check_equal(mem[16'h0041], 16'h1111, "DEPOSIT NEXT writes mem[PC + 1]");
      check_equal(mem[16'h0042], 16'h2222, "second DEPOSIT NEXT");
      check_equal(cpu.register[7], 16'h0042, "DEPOSIT NEXT increments PC");
      check_equal(addr_leds, 16'h0042, "DEPOSIT NEXT: address LEDs");
      check_equal(mem[16'h0043], 16'h0000, "nothing else written");

      test_section("Front panel: DEPOSIT and EXAMINE register");
      register_knob = 3;
      addr_switches = 16'h5A5A;
      press(`DEPOSIT_REGISTER);
      check_equal(cpu.register[3], 16'h5A5A, "DEPOSIT register writes R3");
      check_equal(data_leds, 16'h5A5A, "DEPOSIT register: data LEDs");
      register_knob = 0;
      press(`EXAMINE_REGISTER);
      check_equal(data_leds, 16'h0000, "EXAMINE register R0");
      register_knob = 3;
      press(`EXAMINE_REGISTER);
      check_equal(data_leds, 16'h5A5A, "EXAMINE register R3");
      register_knob = 6;
      press(`EXAMINE_REGISTER);
      check_equal(data_leds, 16'h0FFE, "EXAMINE register SP");
      register_knob = 7;
      addr_switches = 16'h0020;
      press(`DEPOSIT_REGISTER);
      check_equal(cpu.register[7], 16'h0020, "DEPOSIT register writes PC");
      check_equal(addr_leds, 16'h0020, "address LEDs show the new PC");
      register_knob = 0;

      test_section("Front panel: START");
      addr_switches = 16'h0010;
      press(`START);
      wait_halt(1000);
      check_equal(halted, 1, "program halted");
      check_equal(cpu.register[0], 16'h0006, "program result R0");
      check_equal(cpu.register[7], 16'h0013, "PC after HLT");
      repeat (40) @(negedge clk);
      check_equal({statusR, statusG, statusB}, 3'b100, "status LED red after HLT");
      check_equal(addr_leds, 16'h0013, "address LEDs after HLT");

      test_section("Front panel: INST STEP and CONTINUE");
      addr_switches = 16'h0020;
      press(`EXAMINE);
      cpu.register[1] = 0;
      cpu.register[2] = 0;
      cpu.register[3] = 0;
      press(`INST_STEP);
      check_equal(cpu.register[1], 16'h0001, "first step executes LDLZ R1 1");
      check_equal(cpu.register[2], 16'h0000, "first step executes only one instruction");
      check_equal(cpu.register[7], 16'h0021, "PC after the first step");
      check_equal(cpu.running, 0, "not running after a step");
      check_equal(addr_leds, 16'h0021, "address LEDs after a step");
      press(`INST_STEP);
      check_equal(cpu.register[2], 16'h0002, "second step executes LDLZ R2 2");
      check_equal(cpu.register[3], 16'h0000, "second step executes only one instruction");
      press(`CONTINUE);
      wait_halt(1000);
      check_equal(halted, 1, "CONTINUE runs until HLT");
      check_equal(cpu.register[3], 16'h0003, "CONTINUE executed LDLZ R3 3");
      check_equal(cpu.register[7], 16'h0024, "PC after HLT");
      repeat (40) @(negedge clk);
      // After HLT, INST STEP must still execute only one instruction
      press(`INST_STEP);
      check_equal(cpu.register[4], 16'h0004, "step after HLT executes LDLZ R4 4");
      check_equal(cpu.register[7], 16'h0025, "step after HLT executes only one instruction");
      check_equal({statusR, statusG, statusB}, 3'b100, "status LED red after a step");

      test_section("Front panel: STOP");
      addr_switches = 16'h0030;
      cpu.register[5] = 0;
      @(negedge clk);
      panel_command = `START;
      repeat (300) @(negedge clk);
      panel_command = `NONE;
      check_equal(cpu.running, 1, "loop is running");
      check_equal({statusR, statusG, statusB}, 3'b010, "status LED green while running");
      stop = 1;
      @(negedge clk);
      stop = 0;
      repeat (40) @(negedge clk);
      check_equal(cpu.running, 0, "STOP stops the CPU");
      check(cpu.register[7] == 16'h0030 || cpu.register[7] == 16'h0031, "STOP: PC in the loop");
      check(cpu.register[5] > 0, "loop ran before STOP");
      r5 = cpu.register[5];
      repeat (300) @(negedge clk);
      check_equal(cpu.register[5], r5, "nothing executed after STOP");
      check_equal({statusR, statusG, statusB}, 3'b100, "status LED red after STOP");
      check_equal(addr_leds, cpu.register[7], "address LEDs show PC after STOP");
      press(`CONTINUE);
      repeat (200) @(negedge clk);
      check(cpu.register[5] > r5, "CONTINUE resumes the loop");
      stop = 1;
      @(negedge clk);
      stop = 0;
      repeat (40) @(negedge clk);
      check_equal(cpu.running, 0, "second STOP");

      test_section("Front panel: RESET while running");
      press(`CONTINUE);
      repeat (100) @(negedge clk);
      check_equal(cpu.running, 1, "running before RESET");
      cpu.flags = 4'b1111;
      cpu.enableInterrupt = 1;
      reset_cpu;
      check_equal(cpu.running, 0, "RESET stops the CPU");
      check_equal(cpu.register[5], 16'h0000, "RESET clears R5");
      check_equal(cpu.register[6], 16'h0FFE, "RESET sets SP");
      check_equal(cpu.register[7], 16'h0000, "RESET clears PC");
      check_equal(cpu.flags, 4'b0000, "RESET clears the flags");
      check_equal(cpu.enableInterrupt, 0, "RESET disables interrupts");
      check_equal({statusR, statusG, statusB}, 3'b100, "status LED red after RESET");

      test_done;
    end

  initial
    begin
      #10000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
