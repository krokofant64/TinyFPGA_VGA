// ----------------------------------------------------------------------------
// Complete computer (top.v): the memory map. A program reads and writes at
// the boundaries of RAM (0x0000 .. 0x0FFF), ROM (0xF000 .. 0xF1FF), frame
// buffer (0x8000 .. 0x87FF), and I/O (0xFFF8 .. 0xFFFF), checks that writes
// to ROM and unmapped addresses are ignored and that unmapped addresses
// read as 0x9FFF (HLT), and finally executes unmapped memory.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "top.v"

// Simulation stand-in for the iCE40 PLL: passes the reference clock through
module SB_PLL40_CORE #(parameter FEEDBACK_PATH = "", DIVR = 0, DIVF = 0, DIVQ = 0, FILTER_RANGE = 0)
  (output LOCK, input RESETB, input BYPASS, input REFERENCECLK, output PLLOUTCORE);
  assign PLLOUTCORE = REFERENCECLK;
  assign LOCK = 1;
endmodule

module K16MemoryMap_tb();
`include "K16Test.vh"

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
  reg [15:0] first_instruction;

  initial
    begin
      // After the memories' own initial blocks
      #1;
      for (i = 0; i < 4096; i = i + 1)
        dut.ram.mem[i] = 16'h0000;
      // Program
      // ; Memory map test: reads and writes at the boundaries of RAM, ROM, frame
      // ; buffer, and I/O, and stores what it read at 0x0E00 (R5) for the testbench.
      // ; Ends by jumping to unmapped memory, which reads as HLT.
      dut.ram.mem['h0000] = 16'h7b0f; //          LDHZ SP 0x0F
      dut.ram.mem['h0001] = 16'h770e; //          LDHZ R5 0x0E            ; results
      dut.ram.mem['h0002] = 16'h6034; //          LDL R0 0x1234.L
      dut.ram.mem['h0003] = 16'h6112; //          LDH R0 0x1234.H         ; R0 = 0x1234
      dut.ram.mem['h0004] = 16'h0c07; //          NOT R3 R0               ; R3 = 0xEDCB
      //          ; RAM: last word
      dut.ram.mem['h0005] = 16'h64ff; //          LDL R1 0x0FFF.L
      dut.ram.mem['h0006] = 16'h650f; //          LDH R1 0x0FFF.H
      dut.ram.mem['h0007] = 16'he080; //          STO R0 [R1]
      dut.ram.mem['h0008] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0009] = 16'hea80; //          STO R2 [R5 +0]          ; 0x1234
      //          ; 0x1000 is not RAM: reads 0x9FFF, writes are ignored
      dut.ram.mem['h000a] = 16'h048c; //          INC R1 R1
      dut.ram.mem['h000b] = 16'hec80; //          STO R3 [R1]
      dut.ram.mem['h000c] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h000d] = 16'hea81; //          STO R2 [R5 +1]          ; 0x9FFF
      dut.ram.mem['h000e] = 16'h6600; //          LDLZ R1 0
      dut.ram.mem['h000f] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0010] = 16'hea82; //          STO R2 [R5 +2]          ; RAM 0x0000 unchanged (first instruction)
      //          ; ROM: first and last word, writes are ignored
      dut.ram.mem['h0011] = 16'h67f0; //          LDHZ R1 0xF0
      dut.ram.mem['h0012] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0013] = 16'hea83; //          STO R2 [R5 +3]          ; rom[0]
      dut.ram.mem['h0014] = 16'he080; //          STO R0 [R1]
      dut.ram.mem['h0015] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0016] = 16'hea84; //          STO R2 [R5 +4]          ; still rom[0]
      dut.ram.mem['h0017] = 16'h64ff; //          LDL R1 0xF1FF.L
      dut.ram.mem['h0018] = 16'h65f1; //          LDH R1 0xF1FF.H
      dut.ram.mem['h0019] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h001a] = 16'hea85; //          STO R2 [R5 +5]          ; rom[0x1FF]
      dut.ram.mem['h001b] = 16'h048c; //          INC R1 R1               ; 0xF200 is not ROM
      dut.ram.mem['h001c] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h001d] = 16'hea86; //          STO R2 [R5 +6]          ; 0x9FFF
      //          ; Frame buffer: first and last word, and the word after it
      dut.ram.mem['h001e] = 16'h6780; //          LDHZ R1 0x80
      dut.ram.mem['h001f] = 16'he080; //          STO R0 [R1]
      dut.ram.mem['h0020] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0021] = 16'hea87; //          STO R2 [R5 +7]          ; 0x1234
      dut.ram.mem['h0022] = 16'h64ff; //          LDL R1 0x87FF.L
      dut.ram.mem['h0023] = 16'h6587; //          LDH R1 0x87FF.H
      dut.ram.mem['h0024] = 16'hec80; //          STO R3 [R1]
      dut.ram.mem['h0025] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0026] = 16'hea88; //          STO R2 [R5 +8]          ; 0xEDCB
      dut.ram.mem['h0027] = 16'h048c; //          INC R1 R1               ; 0x8800 is not frame buffer
      dut.ram.mem['h0028] = 16'he080; //          STO R0 [R1]
      dut.ram.mem['h0029] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h002a] = 16'hea89; //          STO R2 [R5 +9]          ; 0x9FFF
      //          ; 0x7FFF (below the frame buffer) is not mapped
      dut.ram.mem['h002b] = 16'h64ff; //          LDL R1 0x7FFF.L
      dut.ram.mem['h002c] = 16'h657f; //          LDH R1 0x7FFF.H
      dut.ram.mem['h002d] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h002e] = 16'hea8a; //          STO R2 [R5 +10]         ; 0x9FFF
      //          ; I/O: LEDs and sound divisor can be read back
      dut.ram.mem['h002f] = 16'h64fa; //          LDL R1 0xFFFA.L
      dut.ram.mem['h0030] = 16'h65ff; //          LDH R1 0xFFFA.H
      dut.ram.mem['h0031] = 16'he080; //          STO R0 [R1]
      dut.ram.mem['h0032] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0033] = 16'hea8b; //          STO R2 [R5 +11]         ; address LEDs 0x1234
      dut.ram.mem['h0034] = 16'h048c; //          INC R1 R1
      dut.ram.mem['h0035] = 16'hec80; //          STO R3 [R1]
      dut.ram.mem['h0036] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0037] = 16'hea8c; //          STO R2 [R5 +12]         ; data LEDs 0xEDCB
      dut.ram.mem['h0038] = 16'h64ff; //          LDL R1 0xFFFF.L
      dut.ram.mem['h0039] = 16'h65ff; //          LDH R1 0xFFFF.H
      dut.ram.mem['h003a] = 16'h70e8; //          LDL R4 1000.L
      dut.ram.mem['h003b] = 16'h7103; //          LDH R4 1000.H
      dut.ram.mem['h003c] = 16'hf080; //          STO R4 [R1]
      dut.ram.mem['h003d] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h003e] = 16'hea8d; //          STO R2 [R5 +13]         ; sound divisor 1000
      dut.ram.mem['h003f] = 16'h7200; //          LDLZ R4 0
      dut.ram.mem['h0040] = 16'hf080; //          STO R4 [R1]             ; sound off
      //          ; Cycle counter: two reads of the low word, one LD apart
      dut.ram.mem['h0041] = 16'h64fe; //          LDL R1 0xFFFE.L
      dut.ram.mem['h0042] = 16'h65ff; //          LDH R1 0xFFFE.H
      dut.ram.mem['h0043] = 16'hc880; //          LD R2 [R1]
      dut.ram.mem['h0044] = 16'hcc80; //          LD R3 [R1]
      dut.ram.mem['h0045] = 16'h11a2; //          SUB R4 R3 R2
      dut.ram.mem['h0046] = 16'hf28e; //          STO R4 [R5 +14]         ; 6 clocks (one LD)
      //          ; Execute unmapped memory: reads as HLT
      dut.ram.mem['h0047] = 16'h6740; //          LDHZ R1 0x40
      dut.ram.mem['h0048] = 16'h8400; //          JMP [R1]
      first_instruction = dut.ram.mem[0];

      // Power-up values the hardware has, but the simulator does not know
      dut.video.hvsync_gen.hpos = 0;
      dut.video.hvsync_gen.vpos = 0;
      dut.video.row_index = 0;
      dut.video.col_index = 0;

      // Start at address 0
      #1000;
      @(negedge clk);
      dut.cpu.register[7] = 16'h0000;
      dut.cpu.running = 1;
      dut.cpu.state = dut.cpu.FETCH_INSTR;
      @(negedge clk);
      wait (dut.cpu.running == 0);

      test_section("Memory map: RAM");
      check_equal(dut.ram.mem[16'h0E00], 16'h1234, "last RAM word (0x0FFF) read back");
      check_equal(dut.ram.mem[16'h0E01], 16'h9FFF, "0x1000 reads as 0x9FFF");
      check_equal(dut.ram.mem[16'h0E02], first_instruction, "writing 0x1000 does not change RAM 0x0000");
      check_equal(dut.ram.mem[16'h0FFF], 16'h1234, "RAM 0x0FFF written");

      test_section("Memory map: ROM");
      check_equal(dut.ram.mem[16'h0E03], dut.rom.rom[0], "ROM 0xF000");
      check_equal(dut.ram.mem[16'h0E04], dut.rom.rom[0], "writing ROM is ignored");
      check_equal(dut.ram.mem[16'h0E05], dut.rom.rom[9'h1FF], "ROM 0xF1FF");
      check_equal(dut.ram.mem[16'h0E06], 16'h9FFF, "0xF200 reads as 0x9FFF");

      test_section("Memory map: frame buffer");
      check_equal(dut.ram.mem[16'h0E07], 16'h1234, "frame buffer 0x8000 read back");
      check_equal(dut.ram.mem[16'h0E08], 16'hEDCB, "frame buffer 0x87FF read back");
      check_equal(dut.ram.mem[16'h0E09], 16'h9FFF, "0x8800 reads as 0x9FFF");
      check_equal(dut.frame_buffer.mem[0], 16'h1234, "frame buffer word 0 written");
      check_equal(dut.frame_buffer.mem[11'h7FF], 16'hEDCB, "frame buffer word 0x7FF written (not overwritten by 0x8800)");
      check_equal(dut.ram.mem[16'h0E0A], 16'h9FFF, "0x7FFF reads as 0x9FFF");

      test_section("Memory map: I/O");
      check_equal(dut.ram.mem[16'h0E0B], 16'h1234, "address LEDs 0xFFFA read back");
      check_equal(dut.ram.mem[16'h0E0C], 16'hEDCB, "data LEDs 0xFFFB read back");
      check_equal(dut.ram.mem[16'h0E0D], 16'd1000, "sound divisor 0xFFFF read back");
      check_equal(dut.io.sound_divisor, 16'd0, "sound switched off again");
      check_equal(dut.ram.mem[16'h0E0E], 16'd6, "cycle counter: 6 clocks between two reads (one LD)");

      test_section("Memory map: executing unmapped memory");
      check_equal(dut.cpu.register[7], 16'h4001, "0x4000 executes as HLT");

      test_done;
    end

  initial
    begin
      #10000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
