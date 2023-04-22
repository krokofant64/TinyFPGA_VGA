`ifndef K16VIDEO_V
`define K16VIDEO_V

`include "K16CharRom.v"
`include "K16HvsyncGenerator.v"

module K16Video(clk, reset, interrupt, hsync, vsync, vga_R, vga_G, vga_B, frame_buffer_addr, want_read_frame_buffer, frame_buffer_data);
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

  reg vga_R;
  reg vga_G;
  reg vga_B;

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
      if (hpos[RANGE_HIGH:0] == LAST_PIXEL - 2 ||
          hpos[RANGE_HIGH:0] == LAST_PIXEL - 1)
        begin
          frame_buffer_addr <= row_index + {5'b00000, col_index};
          want_read_frame_buffer <= 1;
        end
     else
       begin
          want_read_frame_buffer <= 0;
       end
    end
  wire [7:0] char_bits;

  reg [15:0] character;

  always @(posedge clk)
    begin
      if (hpos[RANGE_HIGH:0] == LAST_PIXEL)
        begin
          character <= frame_buffer_data;
        end
    end

  K16CharRom rom(
    .character(character[7:0]),
    .line(vpos[RANGE_HIGH:RANGE_LOW]),
    .bits(char_bits));

  wire is_4pixel = character[15];
  wire [2:0] pixel0 = character[2:0];
  wire [2:0] pixel1 = character[5:3];
  wire [2:0] pixel2 = character[8:6];
  wire [2:0] pixel3 = character[11:9];
  wire [2:0] foreground = character[10:8];
  wire [2:0] background = character[13:11];
  wire pixel = char_bits[hpos[RANGE_HIGH:RANGE_LOW]];

  always @(*)

  case (is_4pixel)
    0:
      begin
        vga_R <= display_on && (pixel ? foreground[2] : background[2]);
        vga_G <= display_on && (pixel ? foreground[1] : background[1]);
        vga_B <= display_on && (pixel ? foreground[0] : background[0]);
      end
    1:
      begin
        case ({vpos[RANGE_HIGH], hpos[RANGE_HIGH]})
          0:
            begin
              vga_R <= display_on && pixel0[2];
              vga_G <= display_on && pixel0[1];
              vga_B <= display_on && pixel0[0];
            end
          1:
            begin
              vga_R <= display_on && pixel1[2];
              vga_G <= display_on && pixel1[1];
              vga_B <= display_on && pixel1[0];
            end
          2:
            begin
              vga_R <= display_on && pixel2[2];
              vga_G <= display_on && pixel2[1];
              vga_B <= display_on && pixel2[0];
            end
          3:
            begin
              vga_R <= display_on && pixel3[2];
              vga_G <= display_on && pixel3[1];
              vga_B <= display_on && pixel3[0];
            end
        endcase
      end
  endcase
endmodule
`endif
