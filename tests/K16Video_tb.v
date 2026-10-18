// ----------------------------------------------------------------------------
// K16Video: VGA timing (640 x 480 at 60 Hz: 800 clocks per line with a
// 96 clock sync pulse after a 16 clock front porch, 525 lines per frame
// with a 2 line sync pulse after a 10 line front porch), the interrupt at
// the start of the vertical blanking, the frame buffer read pattern (the
// CPU stalls while the video reads), and every pixel of a frame with
// characters in all colors and four-pixel blocks.
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

  K16Video video(.clk(clk), .reset(1'b0), .interrupt(interrupt), .hsync(hsync), .vsync(vsync),
                 .vga_R(vga_R), .vga_G(vga_G), .vga_B(vga_B),
                 .frame_buffer_addr(frame_buffer_addr), .want_read_frame_buffer(want_read_frame_buffer),
                 .frame_buffer_data(frame_buffer_data));

  K16DualPortRam frame_buffer(.din(16'h0000), .write_en(1'b0), .waddr(11'd0), .wclk(clk),
                              .raddr(frame_buffer_addr), .rclk(clk), .dout(frame_buffer_data));

  wire [9:0] hpos = video.hpos;
  wire [9:0] vpos = video.vpos;

  // Frame buffer content: characters with all foreground and background
  // colors, and every 7th cell a block of four pixels
  integer cell_index;
  reg [15:0] word;
  initial
    begin
      for (cell_index = 0; cell_index < 2048; cell_index = cell_index + 1)
        begin
          if (cell_index % 7 == 3)
            word = 16'h8000 | (cell_index * 16'h0B6D);   // four pixels
          else
            word = ((cell_index / 8) % 8 << 11) | (cell_index % 8 << 8) | ((cell_index * 5) % 128);
          frame_buffer.mem[cell_index] = word;
        end
      // Power-up values the hardware has, but the simulator does not know
      video.hvsync_gen.hpos = 0;
      video.hvsync_gen.vpos = 0;
      video.row_index = 0;
      video.col_index = 0;
    end

  // Expected color of the pixel at x, y (0 .. 639, 0 .. 479)
  function [2:0] expected_pixel;
    input [9:0] x;
    input [9:0] y;
    reg [15:0] w;
    reg [7:0] bits;
    begin
      w = frame_buffer.mem[(y / 16) * 40 + x / 16];
      if (w[15])
        case ({y[3], x[3]})
          2'b00: expected_pixel = w[2:0];
          2'b01: expected_pixel = w[5:3];
          2'b10: expected_pixel = w[8:6];
          2'b11: expected_pixel = w[11:9];
        endcase
      else
        begin
          bits = video.rom.bitarray[w[7:0]][(y / 2) % 8];
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
      if (want_read_frame_buffer)
        begin
          read_run = previous_read ? read_run + 1 : 1;
          if (!previous_read && gap_run < min_gap_run)
            min_gap_run = gap_run;
          if (read_run > max_read_run)
            max_read_run = read_run;
        end
      else
        gap_run = previous_read ? 1 : gap_run + 1;

      // Pixels of the second frame (the first one starts without the
      // characters fetched during the blanking before it)
      if (frame == 1)
        begin
          if (hpos < 640 && vpos < 480)
            begin
              if ({vga_R, vga_G, vga_B} !== expected_pixel(hpos, vpos))
                begin
                  pixel_errors = pixel_errors + 1;
                  if (pixel_errors <= 5)
                    $fdisplay(32'h8000_0002, "  pixel %0d, %0d: color %0d, expected %0d", hpos, vpos,
                              {vga_R, vga_G, vga_B}, expected_pixel(hpos, vpos));
                end
            end
          else if ({vga_R, vga_G, vga_B} !== 3'b000)
            begin
              blank_errors = blank_errors + 1;
              if (blank_errors <= 5)
                $fdisplay(32'h8000_0002, "  blanking at %0d, %0d: color %0d, expected 0", hpos, vpos, {vga_R, vga_G, vga_B});
            end
        end

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
      check(hsync_start_hpos >= 656 && hsync_start_hpos <= 658, "horizontal sync starts 16 clocks after the last pixel");
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

      test_section("Video: pixels of a complete frame");
      check_equal(pixel_errors, 0, "pixels with the wrong color (of 640 x 480)");
      check_equal(blank_errors, 0, "pixels outside the picture that are not black");

      test_done;
    end

  initial
    begin
      #200000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
