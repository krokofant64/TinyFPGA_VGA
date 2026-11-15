// ----------------------------------------------------------------------------
// Complete computer (top.v): the monitor in ROM at 0xF400, over the serial
// port at 115200 baud. The testbench types command lines into serial_rx like a
// terminal, decodes serial_tx, and compares the text with the expected echo
// and output: the banner, storing words, showing words and a dump across a
// line of 8, running a program that returns, Backspace, lower case, ESC, and
// an unknown character.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "top.v"

// Simulation stand-in for the iCE40 PLL: passes the reference clock through
module SB_PLL40_CORE #(parameter FEEDBACK_PATH = "", DIVR = 0, DIVF = 0, DIVQ = 0, FILTER_RANGE = 0)
  (output LOCK, input RESETB, input BYPASS, input REFERENCECLK, output PLLOUTCORE);
  assign PLLOUTCORE = REFERENCECLK;
  assign LOCK = 1;
endmodule

module K16Monitor_tb();
`include "K16Test.vh"

  reg clk = 0;
  always #20 clk = ~clk; // 25 MHz

  localparam BIT = 217 * 40; // ns per bit at 115200 baud

  reg srx = 1;
  wire hs, vs, r, g, b, l0, l1, l2, l3, ioclk, a0, a1, a2, snd, sR, sG, sB;
  wire stx;
  K16Computer dut(.clk_16(clk), .vga_h_sync(hs), .vga_v_sync(vs), .vga_R(r), .vga_G(g), .vga_B(b),
                  .io_led0(l0), .io_led1(l1), .io_led2(l2), .io_led3(l3), .io_clk(ioclk),
                  .io_addr0(a0), .io_addr1(a1), .io_addr2(a2),
                  .sw_col4(1'b1), .sw_col3(1'b1), .sw_col2(1'b1), .sw_col1(1'b1),
                  .sw_reg3(1'b0), .sw_reg2(1'b0), .sw_reg1(1'b0),
                  .sound(snd), .statusR(sR), .statusG(sG), .statusB(sB),
                  .serial_tx(stx), .serial_rx(srx));

  // ------------------------------------------------------------ Receiver of serial_tx
  reg [7:0] text [0:2047];
  integer received = 0;
  integer framing = 0;
  time last_activity = 0;
  integer k;
  reg [7:0] byte_in;

  always @(negedge stx)
    begin
      #(BIT / 2);
      if (stx == 0)
        begin
          for (k = 0; k < 8; k = k + 1)
            begin
              #(BIT);
              byte_in[k] = stx;
            end
          #(BIT);
          if (stx != 1)
            framing = framing + 1;
          text[received] = byte_in;
          received = received + 1;
          last_activity = $time;
        end
    end

  // ------------------------------------------------------------ Terminal
  task send_byte;
    input [7:0] value;
    integer j;
    begin
      srx = 0;
      #(BIT);
      for (j = 0; j < 8; j = j + 1)
        begin
          srx = value[j];
          #(BIT);
        end
      srx = 1;
      #(BIT);
      last_activity = $time;
    end
  endtask

  // Sends the characters of a string (no NUL characters)
  task send_text;
    input [8*80-1:0] value;
    integer j;
    begin
      for (j = 79; j >= 0; j = j - 1)
        if (value[j*8 +: 8] != 0)
          send_byte(value[j*8 +: 8]);
    end
  endtask

  // Waits until the monitor has sent nothing for 4 character times
  task wait_quiet;
    begin
      #(BIT);
      while ($time - last_activity < 40 * BIT || stx == 0)
        #(BIT);
    end
  endtask

  // Compares the text received since mark with expected
  integer mark = 0;
  task expect_text;
    input [8*120-1:0] expected;
    input [8*60-1:0] what;
    integer j, length, start, errors;
    begin
      start = 119;
      while (start >= 0 && expected[start*8 +: 8] == 0)
        start = start - 1;
      length = start + 1;
      errors = 0;
      for (j = 0; j < length; j = j + 1)
        if (mark + j >= received || text[mark + j] !== expected[(start - j)*8 +: 8])
          errors = errors + 1;
      if (received - mark != length)
        errors = errors + 1;
      check(errors == 0, what);
      if (errors != 0)
        begin
          $fwrite(32'h8000_0002, "    got %0d characters:", received - mark);
          for (j = mark; j < received; j = j + 1)
            $fwrite(32'h8000_0002, " %h", text[j]);
          $fwrite(32'h8000_0002, "\n");
        end
      mark = received;
    end
  endtask

  // Types a line and waits for the monitor's answer
  task line;
    input [8*80-1:0] value;
    begin
      send_text(value);
      wait_quiet;
    end
  endtask

  integer i;

  initial
    begin
      // After the memories' own initial blocks
      #1;
      for (i = 0; i < 4096; i = i + 1)
        dut.ram.mem[i] = 16'h0000;

      // Power-up values the hardware has, but the simulator does not know
      dut.video.hvsync_gen.hpos = 0;
      dut.video.hvsync_gen.vpos = 0;
      dut.video.row_index = 0;
      dut.video.col_index = 0;

      // START at 0xF400, like the switches
      #1000;
      @(negedge clk);
      dut.cpu.register[7] = 16'hF400;
      dut.cpu.running = 1;
      dut.cpu.state = dut.cpu.FETCH_INSTR;
      #2000000;  // ClearScreen takes about 1 ms
      wait_quiet;

      test_section("Monitor: start");
      expect_text("\015\012K16 Monitor\015\012", "banner");
      check_equal(dut.serial.control, 0, "CONTROL: 115200 baud, no interrupts");
      check_equal(dut.frame_buffer.mem[0], 16'h074B, "screen: 'K' of the title, white");

      test_section("Monitor: store and show");
      line("800: 3C0D 1234\015");
      expect_text("800: 3C0D 1234\015\012", "store: only the echo");
      check_equal(dut.ram.mem[16'h0800], 16'h3C0D, "0x0800 stored");
      check_equal(dut.ram.mem[16'h0801], 16'h1234, "0x0801 stored");
      line(": 5\015");
      expect_text(": 5\015\012", "store at the next address: echo");
      check_equal(dut.ram.mem[16'h0802], 16'h0005, "0x0802 stored after ':'");
      line("800\015");
      expect_text("800\015\0120800: 3C0D\015\012", "show one word");
      line("800.802\015");
      expect_text("800.802\015\0120800: 3C0D 1234 0005\015\012", "dump of 3 words");
      line("806.809\015");
      expect_text("806.809\015\0120806: 0000 0000\015\0120808: 0000 0000\015\012", "dump across a line of 8");
      line("7F0: AAAA BBBB 801 802\015");
      expect_text("7F0: AAAA BBBB 801 802\015\012", "store, then 801 and 802 are data too");
      check_equal(dut.ram.mem[16'h07F0], 16'hAAAA, "0x07F0 stored");
      check_equal(dut.ram.mem[16'h07F2], 16'h0801, "0x07F2 stored: 801 is data");
      line("810: 1 2 812: 3\015");
      check_equal(dut.ram.mem[16'h0812], 16'h0003, "'812:' in a line sets a new store address");
      check_equal(dut.ram.mem[16'h0811], 16'h0002, "0x0811 stored");
      mark = received;

      test_section("Monitor: run");
      line("800R\015");
      expect_text("800R\015\012\015\012", "800R runs RET and comes back");
      check_equal(dut.cpu.register[6], 16'h0FFD, "SP after the return: 0x0FFE, minus the call of SerialRead");
      line("800\015");
      expect_text("800\015\0120800: 3C0D\015\012", "the monitor still answers");

      test_section("Monitor: editing");
      send_text("12");
      send_byte(8'h08);
      line("3\015");
      expect_text("12\010 \0103\015\0120013: 0000\015\012", "Backspace");
      line("7f0\015");
      expect_text("7F0\015\01207F0: AAAA\015\012", "lower case");
      send_text("800: 9999");
      send_byte(8'h1B);
      wait_quiet;
      expect_text("800: 9999\\\015\012", "ESC cancels the line");
      check_equal(dut.ram.mem[16'h0800], 16'h3C0D, "nothing stored after ESC");
      line("800 G 801\015");
      expect_text("800 G 801\015\0120800: 3C0D\015\012?\015\012", "unknown character: ?");
      line("\012\015");
      expect_text("\015\012", "LF is ignored, an empty line");

      check_equal(framing, 0, "no framing errors on serial_tx");
      test_done;
    end

  initial
    begin
      #200000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
