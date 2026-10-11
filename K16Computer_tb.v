// Testbench for the complete K16 computer (top.v).
//
// Checks that the CPU can read the frame buffer while the video fetches
// characters from it: the test program writes 512 frame buffer words and
// reads them back. Its read loop takes an odd number of clocks, so the reads
// hit every position of the video's 16-clock character fetch cycle.
// It also checks that every character latched by the video is correct.
//
// Run with Icarus Verilog:
//   iverilog -o K16Computer_tb.vvp K16Computer_tb.v
//   vvp K16Computer_tb.vvp > /dev/null
// The result is printed to stderr (the CPU prints its trace to stdout).

`timescale 1 ns/10 ps

`include "top.v"

// Simulation stand-in for the iCE40 PLL: passes the reference clock through
module SB_PLL40_CORE #(parameter FEEDBACK_PATH = "", DIVR = 0, DIVF = 0, DIVQ = 0, FILTER_RANGE = 0)
  (output LOCK, input RESETB, input BYPASS, input REFERENCECLK, output PLLOUTCORE);
  assign PLLOUTCORE = REFERENCECLK;
  assign LOCK = 1;
endmodule

module K16Computer_tb();
  reg clk = 0;
  always #20 clk = ~clk;

  wire hs, vs, r, g, b, l0, l1, l2, l3, ioclk, a0, a1, a2, snd, sR, sG, sB;
  K16Computer dut(.clk_16(clk), .vga_h_sync(hs), .vga_v_sync(vs), .vga_R(r), .vga_G(g), .vga_B(b),
                  .io_led0(l0), .io_led1(l1), .io_led2(l2), .io_led3(l3), .io_clk(ioclk),
                  .io_addr0(a0), .io_addr1(a1), .io_addr2(a2),
                  .sw_col4(1'b1), .sw_col3(1'b1), .sw_col2(1'b1), .sw_col1(1'b1),
                  .sw_reg3(1'b0), .sw_reg2(1'b0), .sw_reg1(1'b0),
                  .sound(snd), .statusR(sR), .statusG(sG), .statusB(sB));

  integer video_checks = 0;
  integer video_errors = 0;
  integer hold_cycles = 0;
  integer cycles = 0;

  // Every character the video latches must be the frame buffer content
  always @(posedge clk)
    if (dut.video.hpos[3:0] == 15 && !dut.frame_buffer_write)
      begin
        video_checks = video_checks + 1;
        if (dut.frame_buffer_dout_bus !== dut.frame_buffer.mem[dut.video.frame_buffer_addr])
          video_errors = video_errors + 1;
      end

  always @(posedge clk)
    if (dut.cpu.running)
      begin
        cycles = cycles + 1;
        if (dut.hold === 1'b1)
          hold_cycles = hold_cycles + 1;
      end

  initial
    begin
      // Power-up values the hardware has, but the simulator does not know
      dut.video.hvsync_gen.hpos = 0;
      dut.video.hvsync_gen.vpos = 0;
      dut.video.row_index = 0;
      dut.video.col_index = 0;

      // Test program
    //                              .org 0x0200
    dut.ram.mem['h200] = 16'h7600; // Start:   LDLZ R5 0          ; error count
    dut.ram.mem['h201] = 16'h725a; //          LDLZ R4 0x5A
    dut.ram.mem['h202] = 16'h715a; //          LDH  R4 0x5A       ; R4 = 0x5A5A
    dut.ram.mem['h203] = 16'h6780; //          LDHZ R1 0x80       ; R1 = 0x8000
    dut.ram.mem['h204] = 16'h6f82; //          LDHZ R3 0x82       ; R3 = 0x8200 (512 words)
    dut.ram.mem['h205] = 16'h08c6; // WrLoop:  XOR R2 R1 R4
    dut.ram.mem['h206] = 16'he880; //          STO R2 [R1]
    dut.ram.mem['h207] = 16'h048c; //          INC R1 R1
    dut.ram.mem['h208] = 16'h00be; //          CMP R1 R3
    dut.ram.mem['h209] = 16'h43fb; //          BCS WrLoop
    dut.ram.mem['h20a] = 16'h6780; //          LDHZ R1 0x80
    dut.ram.mem['h20b] = 16'hc880; // RdLoop:  LD R2 [R1]         ; read back from frame buffer
    dut.ram.mem['h20c] = 16'h0946; //          XOR R2 R2 R4
    dut.ram.mem['h20d] = 16'h011e; //          CMP R2 R1
    dut.ram.mem['h20e] = 16'h4f84; //          BZC Err
    dut.ram.mem['h20f] = 16'h048c; // Next:    INC R1 R1
    dut.ram.mem['h210] = 16'h00be; //          CMP R1 R3
    dut.ram.mem['h211] = 16'h43f9; //          BCS RdLoop
    dut.ram.mem['h212] = 16'h9fff; //          HLT
    dut.ram.mem['h213] = 16'h168c; // Err:     INC R5 R5
    dut.ram.mem['h214] = 16'h9ffa; //          JMP Next

      // Start the program at 0x0200 (like START on the front panel)
      #1000;
      @(negedge clk);
      dut.cpu.register[7] = 16'h0200;
      dut.cpu.running = 1;
      dut.cpu.state = 1; // FETCH_INSTR
      wait (dut.cpu.running == 0);

      $fdisplay(32'h8000_0002, "CPU read errors: %0d of 512, video errors: %0d of %0d, hold: %0d of %0d CPU clocks",
                dut.cpu.register[5], video_errors, video_checks, hold_cycles, cycles);
      if (dut.cpu.register[5] == 0 && video_errors == 0 && video_checks > 0)
        $fdisplay(32'h8000_0002, "PASS");
      else
        $fdisplay(32'h8000_0002, "FAIL");
      $finish;
    end

  initial
    begin
      #100000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
