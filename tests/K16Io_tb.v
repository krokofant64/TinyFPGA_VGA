// ----------------------------------------------------------------------------
// K16Io: scanning of the switch matrix (address switches, control switches
// with inverted inputs, register knob), the command code for the CPU
// (0xFFFC) including the priority, STOP and RESET, multiplexing of the
// LEDs, the cycle counter, and the sound divider.
//
// The I/O scan clock is 8 clocks instead of 500000 (parameter DIVISOR).
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Cpu.v"   // command codes (`START, ...)
`include "K16Io.v"

module K16Io_tb();
`include "K16Test.vh"

  localparam DIVISOR = 8;
  localparam SCAN = 8 * DIVISOR;    // clocks for scanning all 8 matrix lines

  reg clk = 0;
  always #20 clk = ~clk; // 25 MHz

  reg  [2:0]  addr = 0;
  reg  [15:0] din = 0;
  reg         write_en = 0;
  wire [15:0] dout;
  wire        io_stop;
  wire        io_reset;
  wire [3:0]  io_leds;
  wire        io_clk;
  wire [2:0]  io_addr;
  wire        sound;
  reg  [2:0]  io_reg_switches = 0;

  // Switch matrix: line n (io_addr) returns nibble n; lines 0 .. 3 are the
  // address switches, lines 4 .. 7 the control switches (active low)
  reg [15:0] address_switches = 0;
  reg [15:0] control_switches = 0;   // 1 = pressed
  wire [31:0] matrix = {~control_switches, address_switches};
  wire [3:0]  io_switches = matrix[io_addr * 4 +: 4];

  K16Io #(.DIVISOR(DIVISOR)) io(.din(din), .addr(addr), .write_en(write_en), .clk(clk), .dout(dout),
                                .stop(io_stop), .reset(io_reset), .io_leds(io_leds), .io_clk(io_clk),
                                .io_addr(io_addr), .io_switches(io_switches),
                                .io_reg_switches(io_reg_switches), .sound(sound));

  task read;
    input [2:0] register;
    output [15:0] value;
    begin
      @(negedge clk);
      addr = register;
      @(negedge clk);
      @(negedge clk);
      value = dout;
    end
  endtask

  task write;
    input [2:0] register;
    input [15:0] value;
    begin
      @(negedge clk);
      addr = register;
      din = value;
      write_en = 1;
      @(negedge clk);
      write_en = 0;
    end
  endtask

  task scan;
    begin
      repeat (3 * SCAN) @(negedge clk);
    end
  endtask

  // The command for a pressed control switch
  task check_command;
    input [15:0] pressed;
    input [3:0]  command;
    input [8*40-1:0] name;
    reg [15:0] value;
    begin
      control_switches = pressed;
      io_reg_switches = 5;
      scan;
      read(4, value);
      $sformat(test_message, "0xFFFC for %0s", name);
      check_equal(value, {9'b0, command, 3'd5}, test_message);
    end
  endtask

  reg [15:0] value;
  reg [15:0] value2;
  integer i;
  integer start;
  integer toggle1;
  integer toggle2;
  reg [3:0] expected_leds;

  initial
    begin
      test_section("I/O: scan lines");
      @(posedge io_clk);
      #1;
      for (i = 1; i <= 8; i = i + 1)
        begin
          value = io_addr;
          @(posedge io_clk);
          #1;
          $sformat(test_message, "scan line after %0d", value);
          check_equal(io_addr, (value + 1) % 8, test_message);
        end

      test_section("I/O: address and control switches");
      address_switches = 16'hA5C3;
      control_switches = 16'h0000;
      scan;
      read(0, value);
      check_equal(value, 16'hA5C3, "0xFFF8 address switches");
      read(1, value);
      check_equal(value, 16'h0000, "0xFFF9 no control switch pressed");
      control_switches = 16'h0201;
      scan;
      read(1, value);
      check_equal(value, 16'h0201, "0xFFF9 pressed control switches (inputs are active low)");
      address_switches = 16'h0000;
      scan;
      read(0, value);
      check_equal(value, 16'h0000, "0xFFF8 address switches changed");

      test_section("I/O: commands for the CPU (0xFFFC)");
      check_command(16'h0000, `NONE,             "no switch");
      check_command(16'h0001, `EXAMINE_REGISTER, "EXAMINE register");
      check_command(16'h0002, `DEPOSIT_REGISTER, "DEPOSIT register");
      check_command(16'h0010, `CONTINUE,         "CONTINUE");
      check_command(16'h0020, `START,            "START");
      check_command(16'h0040, `DEPOSIT_NEXT,     "DEPOSIT NEXT");
      check_command(16'h0080, `DEPOSIT,          "DEPOSIT");
      check_command(16'h0100, `EXAMINE_NEXT,     "EXAMINE NEXT");
      check_command(16'h0200, `EXAMINE,          "EXAMINE");
      check_command(16'h0400, `INST_STEP,        "INST STEP");
      check_command(16'h0003, `EXAMINE_REGISTER, "EXAMINE and DEPOSIT register (priority)");
      check_command(16'h0410, `CONTINUE,         "CONTINUE and INST STEP (priority)");
      check_command(16'h0004, `NONE,             "STOP");
      check_command(16'h0008, `NONE,             "RESET");
      io_reg_switches = 3'd6;
      control_switches = 0;
      scan;
      read(4, value);
      check_equal(value[2:0], 3'd6, "register knob");

      test_section("I/O: STOP and RESET");
      control_switches = 16'h0004;
      scan;
      check_equal({io_stop, io_reset}, 2'b10, "STOP");
      control_switches = 16'h0008;
      scan;
      check_equal({io_stop, io_reset}, 2'b01, "RESET");
      control_switches = 16'h0000;
      scan;
      check_equal({io_stop, io_reset}, 2'b00, "released");

      test_section("I/O: LEDs");
      write(2, 16'h1234);
      write(3, 16'hABCD);
      read(2, value);
      check_equal(value, 16'h1234, "0xFFFA address LEDs read back");
      read(3, value);
      check_equal(value, 16'hABCD, "0xFFFB data LEDs read back");
      scan;
      // While scan line n is selected, the LEDs show nibble n: 0 .. 3 of the
      // address LEDs, 4 .. 7 of the data LEDs
      for (i = 0; i < 8; i = i + 1)
        begin
          @(posedge io_clk);
          repeat (DIVISOR / 2) @(negedge clk);
          expected_leds = {16'hABCD, 16'h1234} >> (io_addr * 4);
          $sformat(test_message, "LEDs on scan line %0d", io_addr);
          check_equal(io_leds, expected_leds, test_message);
        end

      test_section("I/O: cycle counter");
      read(6, value);
      repeat (100) @(negedge clk);
      read(6, value2);
      check_equal(value2 - value, 100 + 3, "low word counts clocks");
      io.counter = 32'h0001FFF0;
      repeat (40) @(negedge clk);
      read(5, value);
      check_equal(value, 16'h0002, "high word");

      test_section("I/O: sound");
      read(7, value);
      check_equal(value, 16'h0000, "no sound after power-up");
      write(7, 16'd10);
      read(7, value);
      check_equal(value, 16'd10, "0xFFFF divisor read back");
      @(sound);
      start = $time;
      @(sound);
      toggle1 = ($time - start) / 40;
      @(sound);
      toggle2 = ($time - start) / 40 - toggle1;
      $sformat(test_message, "half period = 32 * divisor clocks (+-1), got %0d and %0d", toggle1, toggle2);
      check(toggle1 >= 319 && toggle1 <= 321 && toggle2 >= 319 && toggle2 <= 321, test_message);
      write(7, 16'd0);
      repeat (100) @(negedge clk);
      value = sound;
      repeat (2000) @(negedge clk);
      check_equal(sound, value, "divisor 0 stops the sound");

      test_done;
    end

  initial
    begin
      #10000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
