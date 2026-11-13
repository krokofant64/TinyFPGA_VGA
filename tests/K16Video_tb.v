// ----------------------------------------------------------------------------
// K16Video: VGA timing (640 x 480 at 60 Hz: 800 clocks per line with a
// 96 clock sync pulse after a 16 clock front porch, 525 lines per frame
// with a 2 line sync pulse after a 10 line front porch), the interrupt at
// the start of the vertical blanking, the frame buffer read pattern (the
// CPU stalls while the video reads), and every pixel of a frame with
// fixed and changeable characters in all colors and four-pixel blocks, and
// then a frame with changed characters and overlapping sprites (also partly
// outside the screen, and one disabled).
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Video.v"
`include "K16Ram.v"

module K16Video_tb();
`include "K16Test.vh"

  reg clk = 0;
  always #20 clk = ~clk; // 25 MHz

  wire        interrupt;
  wire        hsync;
  wire        vsync;
  wire        vga_R;
  wire        vga_G;
  wire        vga_B;
  wire [10:0] frame_buffer_addr;
  wire        want_read_frame_buffer;
  wire [15:0] frame_buffer_data;
  reg  [3:0]  reg_addr = 0;
  reg  [15:0] reg_din = 0;
  reg         reg_write = 0;
  wire [15:0] reg_dout;
  reg  [8:0]  char_addr = 0;
  reg  [15:0] char_din = 0;
  reg         char_write = 0;
  reg         video_reset = 0;

  K16Video video(.clk(clk), .reset(video_reset), .interrupt(interrupt), .hsync(hsync), .vsync(vsync),
                 .vga_R(vga_R), .vga_G(vga_G), .vga_B(vga_B),
                 .frame_buffer_addr(frame_buffer_addr), .want_read_frame_buffer(want_read_frame_buffer),
                 .frame_buffer_data(frame_buffer_data),
                 .reg_addr(reg_addr), .reg_din(reg_din), .reg_write(reg_write), .reg_dout(reg_dout),
                 .char_addr(char_addr), .char_din(char_din), .char_write(char_write));

  K16FrameBufferRam frame_buffer(.din(16'h0000), .write_en(1'b0), .waddr(11'd0), .wclk(clk),
                              .raddr(frame_buffer_addr), .rclk(clk), .dout(frame_buffer_data));

  wire [9:0] hpos = video.hpos;
  wire [9:0] vpos = video.vpos;

  // Frame buffer content: all characters with all foreground and background
  // colors, and every 7th cell a block of four pixels. Every line of every
  // changeable character is different.
  integer cell_index;
  reg [15:0] word;
  initial
    begin
      for (cell_index = 0; cell_index < 2048; cell_index = cell_index + 1)
        begin
          if (cell_index % 7 == 3)
            word = 16'h8000 | (cell_index * 16'h0B6D);   // four pixels
          else
            word = ((cell_index / 8) % 8 << 11) | (cell_index % 8 << 8) | ((cell_index * 5) % 256);
          frame_buffer.mem[cell_index] = word;
        end
      for (cell_index = 0; cell_index < 512; cell_index = cell_index + 1)
        video.char_ram.mem[cell_index] = 16'h9E37 * (cell_index + 1);
      // Power-up values the hardware has, but the simulator does not know
      video.hvsync_gen.hpos = 0;
      video.hvsync_gen.vpos = 0;
      video.row_index = 0;
      video.col_index = 0;
    end

  // Sprite registers as the testbench wrote them
  reg [15:0] sprite_x [0:7];
  reg [15:0] sprite_y [0:7];
  integer sprite_index;
  initial
    for (sprite_index = 0; sprite_index < 8; sprite_index = sprite_index + 1)
      begin
        sprite_x[sprite_index] = 0;
        sprite_y[sprite_index] = 0;
      end

  // Point of the topmost sprite at x, y (0 .. 639, 0 .. 479): bit 3 set if
  // a sprite covers the pixel, bits 2 .. 0 its color
  function [3:0] expected_sprite;
    input [9:0] x;
    input [9:0] y;
    integer n, sx, sy, column, row;
    reg [15:0] w;
    reg [3:0] point;
    begin
      expected_sprite = 0;
      for (n = 0; n < 8; n = n + 1)
        if (sprite_x[n][15])
          begin
            sx = sprite_x[n][9:0];
            if (sx >= 512) sx = sx - 1024;
            sy = sprite_y[n][8:0];
            if (sy >= 256) sy = sy - 512;
            column = x / 2 - sx;
            row = y / 2 - sy;
            if (column >= 0 && column < 16 && row >= 0 && row < 16)
              begin
                w = frame_buffer.mem['h600 + 64 * n + 4 * row + column / 4];
                point = w >> (4 * (column % 4));
                if (point[3])
                  expected_sprite = point;
              end
          end
    end
  endfunction

  // Number of sprites shown in point line ly (for the reads per frame)
  function integer sprites_in_line;
    input integer ly;
    integer n, sy;
    begin
      sprites_in_line = 0;
      for (n = 0; n < 8; n = n + 1)
        if (sprite_x[n][15])
          begin
            sy = sprite_y[n][8:0];
            if (sy >= 256) sy = sy - 512;
            if (ly - sy >= 0 && ly - sy < 16)
              sprites_in_line = sprites_in_line + 1;
          end
    end
  endfunction

  // Reads in a frame: 4 per visible sprite, for every screen line
  function integer expected_sprite_reads;
    input dummy;
    integer y;
    begin
      expected_sprite_reads = 0;
      for (y = 0; y < 480; y = y + 1)
        expected_sprite_reads = expected_sprite_reads + 4 * sprites_in_line(y / 2);
    end
  endfunction

  // Expected color of the pixel at x, y (0 .. 639, 0 .. 479)
  function [2:0] expected_pixel;
    input [9:0] x;
    input [9:0] y;
    reg [15:0] w;
    reg [7:0] bits;
    reg [15:0] char_word;
    reg [3:0] sprite_point;
    begin
      sprite_point = expected_sprite(x, y);
      w = frame_buffer.mem[(y / 16) * 40 + x / 16];
      if (sprite_point[3])
        expected_pixel = sprite_point[2:0];
      else if (w[15])
        case ({y[3], x[3]})
          2'b00: expected_pixel = w[2:0];
          2'b01: expected_pixel = w[5:3];
          2'b10: expected_pixel = w[8:6];
          2'b11: expected_pixel = w[11:9];
        endcase
      else
        begin
          if (w[7])
            begin
              char_word = video.char_ram.mem[{w[6:0], y[3:2]}];
              bits = y[1] ? char_word[15:8] : char_word[7:0];
            end
          else
            bits = video.rom.bitarray[w[6:0]][(y / 2) % 8];
          expected_pixel = bits[(x / 2) % 8] ? w[10:8] : w[13:11];
        end
    end
  endfunction

  // Measurements
  integer pixel_errors = 0;
  integer blank_errors = 0;
  integer read_errors = 0;
  integer clock_count = 0;
  integer hsync_fall = -1, hsync_period = -1, hsync_width = -1;
  integer vsync_fall = -1, vsync_period = -1, vsync_width = -1;
  integer hsync_start_hpos = -1, vsync_start_vpos = -1;
  integer interrupt_count = 0, interrupt_last = -1, interrupt_period = -1;
  integer interrupt_width = 0, interrupt_vpos = -1, interrupt_hpos = -1;
  integer read_run = 0, gap_run = 16, max_read_run = 0, min_gap_run = 1000;
  reg previous_hsync = 1, previous_vsync = 1, previous_interrupt = 0, previous_read = 0;
  integer frame = 0;
  integer sprite_reads = 0, sprite_read_run = 0, max_sprite_read_run = 0;
  integer sprite_pixels = 0;
  // The colors are registered: the pixel on the pins belongs to the hpos and
  // vpos of the clock before
  integer pixel_h = 0, pixel_v = 0;

  always @(negedge clk)
    begin
      clock_count = clock_count + 1;

      // Horizontal and vertical sync
      if (previous_hsync && !hsync)
        begin
          if (hsync_fall >= 0)
            hsync_period = clock_count - hsync_fall;
          hsync_fall = clock_count;
          hsync_start_hpos = hpos;
        end
      if (!previous_hsync && hsync)
        hsync_width = clock_count - hsync_fall;
      if (previous_vsync && !vsync)
        begin
          if (vsync_fall >= 0)
            vsync_period = clock_count - vsync_fall;
          vsync_fall = clock_count;
          vsync_start_vpos = vpos;
          frame = frame + 1;
        end
      if (!previous_vsync && vsync)
        vsync_width = clock_count - vsync_fall;

      // Interrupt
      if (interrupt)
        begin
          interrupt_width = previous_interrupt ? interrupt_width + 1 : 1;
          if (!previous_interrupt)
            begin
              interrupt_count = interrupt_count + 1;
              if (interrupt_last >= 0)
                interrupt_period = clock_count - interrupt_last;
              interrupt_last = clock_count;
              interrupt_vpos = vpos;
              interrupt_hpos = hpos;
            end
        end

      // Frame buffer reads: at most 2 clocks, then at least 14 clocks free
      // (the first 3 frames, without sprites)
      if (frame < 3 && want_read_frame_buffer)
        begin
          read_run = previous_read ? read_run + 1 : 1;
          if (!previous_read && gap_run < min_gap_run)
            min_gap_run = gap_run;
          if (read_run > max_read_run)
            max_read_run = read_run;
        end
      else if (frame < 3)
        gap_run = previous_read ? 1 : gap_run + 1;

      // Sprite rows: reads of 0x600 .. 0x7FF in the frame with sprites, never
      // two clocks in a row
      if (frame == 3)
        begin
          if (want_read_frame_buffer && frame_buffer_addr >= 'h600)
            begin
              sprite_reads = sprite_reads + 1;
              sprite_read_run = previous_read ? sprite_read_run + 1 : 1;
              if (sprite_read_run > max_sprite_read_run)
                max_sprite_read_run = sprite_read_run;
            end
          else
            sprite_read_run = 0;
        end

      // Pixels of the second frame (the first one starts without the
      // characters fetched during the blanking before it)
      if (frame == 1 || frame == 3 || frame == 4)
        begin
          if (frame == 3 && pixel_h < 640 && pixel_v < 480 && expected_sprite(pixel_h, pixel_v) >= 8)
            sprite_pixels = sprite_pixels + 1;
          if (pixel_h < 640 && pixel_v < 480)
            begin
              if ({vga_R, vga_G, vga_B} !== expected_pixel(pixel_h, pixel_v))
                begin
                  pixel_errors = pixel_errors + 1;
                  if (pixel_errors <= 5)
                    $fdisplay(32'h8000_0002, "  pixel %0d, %0d: color %0d, expected %0d", pixel_h, pixel_v,
                              {vga_R, vga_G, vga_B}, expected_pixel(pixel_h, pixel_v));
                end
            end
          else if ({vga_R, vga_G, vga_B} !== 3'b000)
            begin
              blank_errors = blank_errors + 1;
              if (blank_errors <= 5)
                $fdisplay(32'h8000_0002, "  blanking at %0d, %0d: color %0d, expected 0", pixel_h, pixel_v, {vga_R, vga_G, vga_B});
            end
        end

      pixel_h = hpos;
      pixel_v = vpos;
      previous_hsync = hsync;
      previous_vsync = vsync;
      previous_interrupt = interrupt;
      previous_read = want_read_frame_buffer;
    end

  initial
    begin
      // Two complete frames and the start of the third
      wait (frame == 3);

      test_section("Video: VGA timing 640 x 480 at 60 Hz");
      check_equal(hsync_period, 800, "clocks per line");
      check_equal(hsync_width, 96, "horizontal sync pulse (clocks)");
      // The last pixel is on the pins while hpos is 640, the sync falls 17
      // clocks later: 16 clocks front porch, 96 sync, 48 back porch
      check_equal(hsync_start_hpos, 657, "horizontal sync starts 16 clocks after the last pixel");
      check_equal(vsync_period, 800 * 525, "clocks per frame (525 lines)");
      check_equal(vsync_width, 2 * hsync_period, "vertical sync pulse (2 lines)");
      check_equal(vsync_start_vpos, 490, "vertical sync starts 10 lines after the last line");

      test_section("Video: interrupt at the start of the vertical blanking");
      check_equal(interrupt_count, 3, "one interrupt per frame");
      check_equal(interrupt_width, 1, "interrupt request lasts 1 clock");
      check_equal(interrupt_period, vsync_period, "interrupt period = frame period");
      check_equal(interrupt_vpos, 480, "interrupt in the first line after the picture");
      check(interrupt_hpos <= 2, "interrupt at the start of the line");

      test_section("Video: frame buffer reads leave the port free for the CPU");
      check_equal(max_read_run, 2, "video reads for at most 2 clocks");
      check(min_gap_run >= 14, "at least 14 free clocks between reads");

      test_section("Video: pixels of a complete frame (fixed and changeable characters)");
      check_equal(pixel_errors, 0, "pixels with the wrong color (of 640 x 480)");
      check_equal(blank_errors, 0, "pixels outside the picture that are not black");

      // Sprites, written during the vertical blanking before frame 3
      test_section("Video: sprite registers");
      @(negedge clk);
      write_sprite(0, 16'h8000, 16'h0000);        // top left corner
      write_sprite(1, 16'h8000 | 10'h3FB, 100);   // X = -5: partly left of the screen
      write_sprite(2, 16'h8000 | 310, 50);        // partly right of the screen
      write_sprite(3, 16'h8000 | 100, 9'h1F9);    // Y = -7: partly above the screen
      write_sprite(4, 16'h8000 | 200, 230);       // partly below the screen
      write_sprite(5, 16'hFC08, 16'hFE08);        // unused bits set, overlaps 0 and 6
      write_sprite(6, 16'h8000 | 10, 4);          // overlaps 0 and 5
      write_sprite(7, 16'h0000 | 150, 120);       // disabled
      // Changeable characters, written during the vertical blanking as well
      write_char(0, 16'hFF81);                    // first word of character 128
      write_char(511, 16'h7EC3);                  // last word of character 255
      check_equal(video.char_ram.mem[0], 16'hFF81, "character RAM word 0 written");
      check_equal(video.char_ram.mem[511], 16'h7EC3, "character RAM word 511 written");
      check_read(10, 16'hFC08, "register 10 (X of sprite 5) read back");
      check_read(11, 16'hFE08, "register 11 (Y of sprite 5) read back");
      check_read(15, 120, "register 15 (Y of sprite 7) read back");
      pixel_errors = 0;
      blank_errors = 0;
      wait (frame == 4);

      test_section("Video: frame with changed characters and sprites");
      check(sprite_pixels > 1000, "sprite points are visible (more than 1000 pixels)");
      check_equal(pixel_errors, 0, "pixels with the wrong color (of 640 x 480)");
      check_equal(blank_errors, 0, "pixels outside the picture that are not black");
      check_equal(sprite_reads, expected_sprite_reads(0), "sprite row reads: 4 per sprite and screen line");
      check_equal(max_sprite_read_run, 1, "sprite rows are read every second clock");

      // RESET during the vertical blanking before the picture of frame 4: all sprites off
      test_section("Video: RESET switches the sprites off");
      @(negedge clk);
      video_reset = 1;
      @(negedge clk);
      video_reset = 0;
      for (sprite_index = 0; sprite_index < 16; sprite_index = sprite_index + 1)
        check_read(sprite_index, 0, "register after RESET");
      for (sprite_index = 0; sprite_index < 8; sprite_index = sprite_index + 1)
        begin
          sprite_x[sprite_index] = 0;
          sprite_y[sprite_index] = 0;
        end
      pixel_errors = 0;
      blank_errors = 0;
      wait (frame == 5);
      check_equal(pixel_errors, 0, "pixels with the wrong color in the next frame (no sprites)");
      check_equal(blank_errors, 0, "pixels outside the picture that are not black");

      test_done;
    end

  task write_sprite;
    input integer n;
    input [15:0] x;
    input [15:0] y;
    begin
      reg_addr = 2 * n;
      reg_din = x;
      reg_write = 1;
      @(negedge clk);
      reg_addr = 2 * n + 1;
      reg_din = y;
      @(negedge clk);
      reg_write = 0;
      sprite_x[n] = x;
      sprite_y[n] = y;
    end
  endtask

  task write_char;
    input [8:0] address;
    input [15:0] value;
    begin
      char_addr = address;
      char_din = value;
      char_write = 1;
      @(negedge clk);
      char_write = 0;
    end
  endtask

  task check_read;
    input [3:0] address;
    input [15:0] value;
    input [8*120-1:0] text;
    begin
      reg_addr = address;
      @(negedge clk);
      check_equal(reg_dout, value, text);
    end
  endtask

  initial
    begin
      #300000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
