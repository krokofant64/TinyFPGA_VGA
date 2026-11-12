// ----------------------------------------------------------------------------
// K16Psg: the sound chip like the AY-3-8910. Register widths and read back,
// the tick rate, tone periods, noise, mixer, volume levels, and all 16
// envelope shapes against a reference written from the AY's description.
//
// The chip under test ticks every 2 clocks (TICK_INCREMENT = 0x8000) instead
// of every 113 for faster simulation; a second instance checks the real rate.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Psg.v"

module K16Psg_tb();
`include "K16Test.vh"

  reg clk = 0;
  always #20 clk = ~clk; // 25 MHz

  reg        reset = 0;
  reg  [3:0] addr = 0;
  reg  [7:0] din = 0;
  reg        write_en = 0;
  wire [7:0] dout;
  wire [9:0] level;

  K16Psg #(.TICK_INCREMENT(16'h8000)) psg(.clk(clk), .reset(reset), .addr(addr), .din(din), .write_en(write_en), .dout(dout), .level(level));

  // The real tick rate
  wire [7:0] dout2;
  wire [9:0] level2;
  K16Psg psg2(.clk(clk), .reset(1'b0), .addr(4'd0), .din(8'd0), .write_en(1'b0), .dout(dout2), .level(level2));

  task write;
    input [3:0] register;
    input [7:0] value;
    begin
      @(negedge clk);
      addr = register;
      din = value;
      write_en = 1;
      @(negedge clk);
      write_en = 0;
    end
  endtask

  task read;
    input [3:0] register;
    output [7:0] value;
    begin
      @(negedge clk);
      addr = register;
      @(negedge clk);
      value = dout;
    end
  endtask

  // Ticks until a signal changes
  task ticks_until_change;
    input integer which;            // 0 = tone A, 1 = tone B, 2 = tone C
    output integer count;
    reg old;
    begin
      count = 0;
      old = which == 0 ? psg.tone_a : which == 1 ? psg.tone_b : psg.tone_c;
      while ((which == 0 ? psg.tone_a : which == 1 ? psg.tone_b : psg.tone_c) == old)
        begin
          @(posedge clk);
          #1;
          if (tick_seen)
            count = count + 1;
        end
    end
  endtask

  // Envelope reference: volume at step k (0 = right after writing R13)
  function [3:0] envelope_reference;
    input [3:0] shape;
    input integer k;
    reg attack, alternate, hold, cont, direction;
    begin
      cont = shape[3];
      attack = shape[2];
      alternate = shape[1];
      hold = shape[0];
      if (k < 16)
        envelope_reference = attack ? k : 15 - k;
      else if (!cont)
        envelope_reference = 0;
      else if (hold)
        envelope_reference = (attack ? 4'd15 : 4'd0) ^ (alternate ? 4'd15 : 4'd0);
      else
        begin
          direction = attack ^ (alternate & ((k / 16) % 2));
          envelope_reference = direction ? k % 16 : 15 - k % 16;
        end
    end
  endfunction

  reg [7:0] value;
  reg [3:0] shape;
  integer i;
  integer k;
  integer count;
  integer count2;
  integer ones;
  integer changes;
  reg [16:0] lfsr_start;
  reg [3:0] expected;
  reg mismatch;

  // The generators act at a clock edge when tick is 1 before it. tick_seen
  // and step_seen tell after an edge that a tick or an envelope step was
  // done at that edge.
  wire step_event = psg.tick && psg.half && psg.count_env >= psg.period_env - 16'd1;
  reg  tick_seen = 0;
  reg  step_seen = 0;
  always @(posedge clk)
    begin
      step_seen <= step_event;
      tick_seen <= psg.tick;
    end

  initial
    begin
      test_section("PSG: registers read back with the AY's widths");
      for (i = 0; i < 16; i = i + 1)
        write(i, 8'hFF);
      for (i = 0; i < 16; i = i + 1)
        begin
          read(i, value);
          $sformat(test_message, "R%0d", i);
          check_equal(value, i == 0 || i == 2 || i == 4 || i == 11 || i == 12 ? 8'hFF :
                             i == 1 || i == 3 || i == 5 || i == 13 ? 8'h0F :
                             i == 6 || i == 8 || i == 9 || i == 10 ? 8'h1F :
                             i == 7 ? 8'h3F : 8'h00, test_message);
        end
      for (i = 0; i < 14; i = i + 1)
        write(i, 8'h00);
      write(13, 8'h00);

      test_section("PSG: tick rate 25 MHz * 581 / 65536");
      count = 0;
      for (i = 0; i < 65536; i = i + 1)
        begin
          @(posedge clk);
          #1;
          if (psg2.tick)
            count = count + 1;
        end
      check(count >= 580 && count <= 582, "ticks in 65536 clocks = 581");

      test_section("PSG: tone periods");
      write(7, 8'h38);                // Tones on, noise off
      write(0, 8'd5);
      write(2, 8'd0);
      write(3, 8'd1);                 // B: 256
      write(4, 8'd0);                 // C: 0 counts like 1
      ticks_until_change(0, count);
      ticks_until_change(0, count);
      check_equal(count, 5, "A: half period = 5 ticks");
      ticks_until_change(0, count);
      check_equal(count, 5, "A: next half period");
      ticks_until_change(1, count);
      ticks_until_change(1, count);
      check_equal(count, 256, "B: coarse 1 = 256 ticks");
      ticks_until_change(2, count);
      ticks_until_change(2, count);
      check_equal(count, 1, "C: period 0 = 1 tick");

      test_section("PSG: volume levels and mixer");
      write(7, 8'h3E);                // Only tone A
      write(8, 8'd15);
      write(9, 8'd15);
      write(10, 8'd15);
      wait (psg.tone_a == 1);
      repeat (2) @(posedge clk);
      #1;
      check_equal(level, 255 + 510, "A high at volume 15 = 255, plus B and C");
      wait (psg.tone_a == 0);
      repeat (2) @(posedge clk);
      #1;
      check_equal(level, 255 + 255, "A low: B and C (tone and noise off) are constantly on");
      write(9, 8'd0);
      write(10, 8'd0);
      write(8, 8'd8);
      wait (psg.tone_a == 1);
      repeat (2) @(posedge clk);
      #1;
      check_equal(level, 32, "A at volume 8 = 32");
      write(8, 8'd0);
      repeat (3) @(posedge clk);
      #1;
      check_equal(level, 0, "all volumes 0");
      // The volume table rises with every level
      mismatch = 0;
      for (i = 1; i < 16; i = i + 1)
        if (psg.volume(i) <= psg.volume(i - 1))
          mismatch = 1;
      check(!mismatch && psg.volume(0) == 0 && psg.volume(15) == 255, "volume table 0 .. 255, rising");

      test_section("PSG: noise");
      write(6, 8'd3);
      write(7, 8'h37);                // Only noise on A
      write(8, 8'd15);
      // The LFSR shifts every 2 * 3 ticks
      count = 0;
      count2 = 0;
      lfsr_start = psg.lfsr;
      while (psg.lfsr == lfsr_start)
        begin
          @(posedge clk);
          #1;
        end
      lfsr_start = psg.lfsr;
      while (psg.lfsr == lfsr_start)
        begin
          @(posedge clk);
          #1;
          if (tick_seen)
            count = count + 1;
        end
      check_equal(count, 6, "LFSR shifts every 2 * period ticks");
      // Many different bits, about as many 1s as 0s, no short cycle
      ones = 0;
      changes = 0;
      lfsr_start = psg.lfsr;
      mismatch = 0;
      for (i = 0; i < 2000; i = i + 1)
        begin
          value[0] = psg.lfsr[0];
          @(psg.lfsr);
          #1;
          ones = ones + psg.lfsr[0];
          if (psg.lfsr[0] != value[0])
            changes = changes + 1;
          if (psg.lfsr == lfsr_start || psg.lfsr == 0)
            mismatch = 1;
        end
      $sformat(test_message, "noise: 1s in 2000 shifts = %0d, changes %0d", ones, changes);
      check(ones > 850 && ones < 1150 && changes > 800 && changes < 1200 && !mismatch, test_message);
      write(8, 8'd0);
      write(7, 8'h3F);

      test_section("PSG: envelope shapes");
      write(11, 8'd1);
      write(12, 8'd0);
      for (i = 0; i < 16; i = i + 1)
        begin
          shape = i;
          write(13, shape);
          #1;
          mismatch = 0;
          for (k = 0; k < 48; k = k + 1)
            begin
              if (k > 0)
                begin
                  // Wait for the next envelope step
                  @(posedge clk);
                  #1;
                  while (!step_seen)
                    begin
                      @(posedge clk);
                      #1;
                    end
                end
              expected = envelope_reference(shape, k);
              if (psg.env_volume !== expected && !mismatch)
                begin
                  mismatch = 1;
                  $sformat(test_message, "shape %0d step %0d: expected %0d, got %0d", shape, k, expected, psg.env_volume);
                  check(0, test_message);
                end
            end
          if (!mismatch)
            begin
              $sformat(test_message, "shape %0d", shape);
              check(1, test_message);
            end
        end

      test_section("PSG: envelope as volume");
      write(7, 8'h3E);                // Tone A
      write(0, 8'd200);
      write(8, 8'h10);
      write(13, 8'd13);               // Attack, then hold at 15
      repeat (200) @(posedge clk);
      wait (psg.tone_a == 1);
      repeat (2) @(posedge clk);
      #1;
      check_equal(level, 255, "envelope held at 15 = 255");
      write(13, 8'd0);                // Decay, then 0
      repeat (200) @(posedge clk);
      #1;
      check_equal(level, 0, "envelope decayed to 0");

      test_section("PSG: reset");
      write(7, 8'h3E);                // Tone A at volume 15
      write(0, 8'd3);
      write(8, 8'd15);
      write(11, 8'd5);
      write(13, 8'd14);
      ones = 0;
      for (i = 0; i < 100; i = i + 1)
        begin
          @(posedge clk);
          #1;
          if (level == 255)
            ones = ones + 1;
        end
      check(ones > 20, "a tone plays before the reset");
      @(negedge clk);
      reset = 1;
      repeat (3) @(negedge clk);
      check(psg.env_holding == 1 && psg.env_step == 15 && psg.lfsr == 1 && psg.tone_a == 0 && psg.count_a == 0,
            "generators as at power-up");
      reset = 0;
      mismatch = 0;
      for (i = 0; i < 16; i = i + 1)
        begin
          read(i, value);
          if (value != 0)
            mismatch = 1;
        end
      check(!mismatch, "all registers 0 after the reset");
      ones = 0;
      for (i = 0; i < 2000; i = i + 1)
        begin
          @(posedge clk);
          #1;
          if (level != 0)
            ones = ones + 1;
        end
      check_equal(ones, 0, "silent after the reset");

      test_done;
    end

  initial
    begin
      #200000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
