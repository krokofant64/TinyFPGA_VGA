`ifndef K16VIDEO_V
`define K16VIDEO_V

`include "K16CharRom.v"
`include "K16HvsyncGenerator.v"
`include "K16Ram.v"

// Text and four-pixel graphics from the frame buffer, with 8 sprites on top.
//
// Sprites: 16 x 16 points, a point is 2 x 2 screen pixels (like a text pixel).
// Sprite n uses the frame buffer words 0x600 + 64 * n .. 0x600 + 64 * n + 63:
// 4 words per row, point 4 * k + i of a row in bits 4 * i + 3 .. 4 * i of word
// k. A point is transparent when bit 3 is 0, else bits 2 .. 0 are its color.
// Sprite 7 is on top, sprite 0 at the bottom.
//
// Registers (reg_addr): 2 * n     = X of sprite n: bit 15 enable, bits 9 .. 0 X
//                       2 * n + 1 = Y of sprite n: bits 8 .. 0 Y
// X and Y are signed and count points (0, 0 .. 319, 239 is the screen).
//
// The rows for the next line are read from the frame buffer during the
// horizontal blanking (hpos 640 .. 703, one read every second clock).
//
// Characters: 0 .. 127 are fixed (K16CharRom), 128 .. 255 can be changed. The
// CPU writes them through char_addr, char_din, and char_write; see
// K16CharacterRam for the format.
module K16Video(clk, reset, interrupt, hsync, vsync, vga_R, vga_G, vga_B, frame_buffer_addr, want_read_frame_buffer, frame_buffer_data,
                reg_addr, reg_din, reg_write, reg_dout, char_addr, char_din, char_write);
  input clk;
  input reset;
  output reg interrupt;
  output hsync;
  output vsync;
  output vga_R;
  output vga_G;
  output vga_B;
  output reg [10:0] frame_buffer_addr;
  output reg want_read_frame_buffer;
  input  [15:0] frame_buffer_data;
  input  [3:0]  reg_addr;
  input  [15:0] reg_din;
  input         reg_write;
  output reg [15:0] reg_dout;
  input  [8:0]  char_addr;
  input  [15:0] char_din;
  input         char_write;

  reg vga_R = 0;
  reg vga_G = 0;
  reg vga_B = 0;

  localparam SCREEN_WIDTH = 640;
  localparam SCREEN_HEIGHT = 480;
  localparam PIXEL_PER_BIT = 2;
  localparam PIXEL_PER_CHAR = 8 * PIXEL_PER_BIT;
  localparam LAST_PIXEL = (PIXEL_PER_CHAR - 1); // NOTE: Use 3 or 4 depending on number of PIXEL_PER_CHAR - 1
  localparam COLUMNS = SCREEN_WIDTH / PIXEL_PER_CHAR;
  localparam RANGE_HIGH = PIXEL_PER_BIT + 1;
  localparam RANGE_LOW = PIXEL_PER_BIT - 1;

  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;

  K16HvsyncGenerator hvsync_gen(
    .clk(clk),
    .vga_h_sync(hsync),
    .vga_v_sync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  // --------------------------------------------------------------------------
  // Sprite registers

  reg [255:0] sprite_regs = 0; // Register i in bits 16 * i + 15 .. 16 * i

  always @(posedge clk)
    begin
      if (reg_write)
        sprite_regs[{reg_addr, 4'b0000} +: 16] <= reg_din;
      reg_dout <= sprite_regs[{reg_addr, 4'b0000} +: 16];
    end

  // --------------------------------------------------------------------------
  // Sprite rows for the next line

  // Next line (in points) and whether it is visible
  wire [9:0] next_vpos = (vpos == 524) ? 10'd0 : vpos + 10'd1;
  wire       next_line_visible = next_vpos < SCREEN_HEIGHT;
  wire [10:0] next_point_line = {2'b00, next_vpos[9:1]};

  // Fetch slot: hpos 640 .. 703, every second clock; hpos[5:1] is the slot
  // number, bits 4 .. 2 of it the sprite, bits 1 .. 0 the word of the row
  wire       fetch_slot = hpos >= SCREEN_WIDTH && hpos < SCREEN_WIDTH + 64 && !hpos[0] && next_line_visible;
  wire [2:0] fetch_sprite = hpos[5:3];
  wire [1:0] fetch_word = hpos[2:1];
  wire       fetch_enable = sprite_regs[{fetch_sprite, 5'b00000} + 15];
  wire [8:0] fetch_y = sprite_regs[{fetch_sprite, 5'b10000} +: 9];
  wire [10:0] fetch_row = next_point_line - {{2{fetch_y[8]}}, fetch_y};
  wire       fetch_read = fetch_slot && fetch_enable && fetch_row[10:4] == 0;

  // The frame buffer output is registered: the word read in a slot is valid
  // two clocks later
  reg       fetch1 = 0, fetch2 = 0;
  reg       read1 = 0, read2 = 0;
  reg [4:0] slot1 = 0, slot2 = 0;
  reg [511:0] sprite_lines = 0; // Row of sprite n in bits 64 * n + 63 .. 64 * n

  always @(posedge clk)
    begin
      fetch1 <= fetch_slot;
      read1 <= fetch_read;
      slot1 <= hpos[5:1];
      fetch2 <= fetch1;
      read2 <= read1;
      slot2 <= slot1;
      if (fetch2)
        sprite_lines[{slot2, 4'b0000} +: 16] <= read2 ? frame_buffer_data : 16'h0000;
    end

  // --------------------------------------------------------------------------
  // Frame buffer reads: characters, and the sprite rows during the blanking

  reg [10:0] row_index;
  reg [5:0] col_index;

  always @(posedge clk)
    begin
      interrupt <= (vpos == 480 && hpos == 0);
      if (vpos == SCREEN_HEIGHT + 1)
        begin
          row_index <= 0;
          col_index <= 0;
        end
      else
        begin
          if (display_on)
            begin
              if (vpos[RANGE_HIGH:0] == LAST_PIXEL &&
                  hpos == SCREEN_WIDTH - 1)
                begin
                  row_index <= row_index + COLUMNS;
                  col_index <= 0;
                end
              else
                if (hpos == SCREEN_WIDTH - 1)
                  begin
                    col_index <= 0;
                  end
                else
                  if (hpos[RANGE_HIGH:0] == LAST_PIXEL - 3)
                    begin
                      col_index <= col_index + 1;
                    end
            end
        end
      if (fetch_read)
        begin
          frame_buffer_addr <= {2'b11, fetch_sprite, fetch_row[3:0], fetch_word};
          want_read_frame_buffer <= 1;
        end
      else if ((hpos[RANGE_HIGH:0] == LAST_PIXEL - 2 ||
                hpos[RANGE_HIGH:0] == LAST_PIXEL - 1) &&
               !(hpos >= SCREEN_WIDTH && hpos < SCREEN_WIDTH + 64))
        begin
          frame_buffer_addr <= row_index + {5'b00000, col_index};
          want_read_frame_buffer <= 1;
        end
     else
       begin
          want_read_frame_buffer <= 0;
       end
    end

  // --------------------------------------------------------------------------
  // Sprite pixel, computed one clock ahead for the next pixel

  wire [9:0] next_hpos = (hpos == 799) ? 10'd0 : hpos + 10'd1;
  wire [10:0] next_point_column = {2'b00, next_hpos[9:1]};

  wire [7:0] sprite_opaque;
  wire [23:0] sprite_colors; // Color of sprite n in bits 3 * n + 2 .. 3 * n

  genvar n;
  generate
    for (n = 0; n < 8; n = n + 1)
      begin : sprite
        wire        enable = sprite_regs[32 * n + 15];
        wire [9:0]  x = sprite_regs[32 * n +: 10];
        wire [10:0] offset = next_point_column - {x[9], x};
        wire [63:0] line = sprite_lines[64 * n +: 64];
        wire [3:0]  point = line[{offset[3:0], 2'b00} +: 4];
        assign sprite_opaque[n] = enable && offset[10:4] == 0 && point[3];
        assign sprite_colors[3 * n +: 3] = point[2:0];
      end
  endgenerate

  reg       sprite_on = 0;
  reg [2:0] sprite_color = 0;
  integer i;

  always @(posedge clk)
    begin
      sprite_on <= 0;
      sprite_color <= 0;
      for (i = 0; i < 8; i = i + 1)  // The last one wins: sprite 7 is on top
        if (sprite_opaque[i])
          begin
            sprite_on <= 1;
            sprite_color <= sprite_colors[3 * i +: 3];
          end
    end

  // --------------------------------------------------------------------------
  // Characters and four-pixel blocks

  wire [7:0] rom_bits;
  wire [15:0] char_ram_data;

  reg [15:0] character;

  always @(posedge clk)
    begin
      if (hpos[RANGE_HIGH:0] == LAST_PIXEL)
        begin
          character <= frame_buffer_data;
        end
    end

  K16CharRom rom(
    .character(character[6:0]),
    .line(vpos[RANGE_HIGH:RANGE_LOW]),
    .bits(rom_bits));

  // The output of the character RAM is registered, so it is read one clock
  // ahead: the character that is about to be loaded, the line that is about
  // to start. The data has to be valid together with them.
  wire [6:0] char_ram_character = (hpos[RANGE_HIGH:0] == LAST_PIXEL) ? frame_buffer_data[6:0] : character[6:0];
  wire [9:0] char_ram_vpos = (hpos == 799) ? next_vpos : vpos;

  K16CharacterRam char_ram(
    .din(char_din),
    .write_en(char_write),
    .waddr(char_addr),
    .wclk(clk),
    .raddr({char_ram_character, char_ram_vpos[RANGE_HIGH:RANGE_HIGH - 1]}),
    .rclk(clk),
    .dout(char_ram_data));

  wire [7:0] char_ram_bits = vpos[RANGE_LOW] ? char_ram_data[15:8] : char_ram_data[7:0];
  wire [7:0] char_bits = character[7] ? char_ram_bits : rom_bits;

  wire is_4pixel = character[15];
  wire [2:0] pixel0 = character[2:0];
  wire [2:0] pixel1 = character[5:3];
  wire [2:0] pixel2 = character[8:6];
  wire [2:0] pixel3 = character[11:9];
  wire [2:0] foreground = character[10:8];
  wire [2:0] background = character[13:11];
  wire pixel = char_bits[hpos[RANGE_HIGH:RANGE_LOW]];

  reg [2:0] color;

  always @(*)
    begin
      if (sprite_on)
        color = sprite_color;
      else if (is_4pixel)
        case ({vpos[RANGE_HIGH], hpos[RANGE_HIGH]})
          0: color = pixel0;
          1: color = pixel1;
          2: color = pixel2;
          3: color = pixel3;
        endcase
      else
        color = pixel ? foreground : background;
    end

  // The color outputs are registered, so the pins change only at the clock
  // edge and not while the logic above settles (which a monitor can show as
  // thin lines). The pixel of hpos appears one clock later, like the
  // registered sync signals of K16HvsyncGenerator.
  always @(posedge clk)
    begin
      vga_R <= display_on && color[2];
      vga_G <= display_on && color[1];
      vga_B <= display_on && color[0];
    end
endmodule
`endif
