// Runs a program on the complete K16 computer until HLT and writes the final
// state in the same format as K16Emulate.js. Used by CompareWithEmulator.ps1.
//
// Needs on the include path: top.v (and the other modules) and program.vh
// (written by K16Emulate.js). Writes hardware.txt to the current folder.

`timescale 1 ns/10 ps

`include "top.v"

// Simulation stand-in for the iCE40 PLL: passes the reference clock through
module SB_PLL40_CORE #(parameter FEEDBACK_PATH = "", DIVR = 0, DIVF = 0, DIVQ = 0, FILTER_RANGE = 0)
  (output LOCK, input RESETB, input BYPASS, input REFERENCECLK, output PLLOUTCORE);
  assign PLLOUTCORE = REFERENCECLK;
  assign LOCK = 1;
endmodule

module K16Compare_tb();
  reg clk = 0;
  always #20 clk = ~clk; // 25 MHz

  wire hs, vs, r, g, b, l0, l1, l2, l3, ioclk, a0, a1, a2, snd, sR, sG, sB;
  K16Computer dut(.clk_16(clk), .vga_h_sync(hs), .vga_v_sync(vs), .vga_R(r), .vga_G(g), .vga_B(b),
                  .io_led0(l0), .io_led1(l1), .io_led2(l2), .io_led3(l3), .io_clk(ioclk),
                  .io_addr0(a0), .io_addr1(a1), .io_addr2(a2),
                  .sw_col4(1'b1), .sw_col3(1'b1), .sw_col2(1'b1), .sw_col1(1'b1),
                  .sw_reg3(1'b0), .sw_reg2(1'b0), .sw_reg1(1'b0),
                  .sound(snd), .statusR(sR), .statusG(sG), .statusB(sB));

  integer i;
  integer f;
  reg [15:0] address;

  initial
    begin
      // After the memories' own initial blocks: clear RAM and frame buffer
      #1;
      for (i = 0; i < 4096; i = i + 1)
        dut.ram.mem[i] = 16'h0000;
      for (i = 0; i < 2048; i = i + 1)
        dut.frame_buffer.mem[i] = 16'h0000;
`include "program.vh"

      // Power-up values the hardware has, but the simulator does not know
      dut.video.hvsync_gen.hpos = 0;
      dut.video.hvsync_gen.vpos = 0;
      dut.video.row_index = 0;
      dut.video.col_index = 0;

      // Start at address 0 (like START on the front panel)
      #1000;
      @(negedge clk);
      dut.cpu.register[7] = 16'h0000;
      dut.cpu.running = 1;
      dut.cpu.state = 1; // FETCH_INSTR
      @(negedge clk);
      wait (dut.cpu.running == 0);

      f = $fopen("hardware.txt", "w");
      for (i = 0; i < 8; i = i + 1)
        $fdisplay(f, "R%0d %04h", i, dut.cpu.register[i]);
      $fdisplay(f, "C %0d", dut.cpu.flags[0]);
      $fdisplay(f, "Z %0d", dut.cpu.flags[2]);
      $fdisplay(f, "N %0d", dut.cpu.flags[1]);
      $fdisplay(f, "O %0d", dut.cpu.flags[3]);
      $fdisplay(f, "I %0d", dut.cpu.enableInterrupt);
      for (i = 0; i < 4096; i = i + 1)
        begin
          address = i;
          $fdisplay(f, "RAM %04h %04h", address, dut.ram.mem[i]);
        end
      for (i = 0; i < 2048; i = i + 1)
        begin
          address = i;
          $fdisplay(f, "FB %04h %04h", address, dut.frame_buffer.mem[i]);
        end
      $fclose(f);
      $finish;
    end

  initial
    begin
      #400000000; // 10 million clocks
      $fdisplay(32'h8000_0002, "The program did not reach HLT");
      $finish;
    end
endmodule
