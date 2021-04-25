// Pong VGA game
// (c) fpga4fun.com

`include "registerToPixel.v"
`include "alu.v"

module pong(clk_16, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B, quadA, quadB, USBPU);

  input clk_16;
  output vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B;
  input quadA, quadB;
  output USBPU;

  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  wire locked, clk;

  reg[15:0] register [0:7];

  assign USBPU = 0;

  SB_PLL40_CORE #(
                  .FEEDBACK_PATH("SIMPLE"),
                  .DIVR(4'b0000),         // DIVR =  0
                  .DIVF(7'b0110001),      // DIVF = 49
                  .DIVQ(3'b101),          // DIVQ =  5
                  .FILTER_RANGE(3'b001)   // FILTER_RANGE = 1
                 ) uut (
                  .LOCK(locked),
                  .RESETB(1'b1),
                  .BYPASS(1'b0),
                  .REFERENCECLK(clk_16),
                  .PLLOUTCORE(clk)
                 );

  hvsync_generator syncgen(.clk(clk),
                           .vga_h_sync(vga_h_sync),
                           .vga_v_sync(vga_v_sync),
                           .display_on(display_on),
                           .hpos(hpos),
                           .vpos(vpos));

  wire [15:0] result;
  Alu alu1(.operand1(register[1]),
           .operand2(register[2]),
           .operation(4'b011),
           .result(result));

  always @(posedge vga_v_sync)
  begin
    register[0]++;
    register[1] = register[1] + 2;
    register[2] = register[2] + 3;
    register[3] = register[3] + 4;
    register[4] = register[4] + 5;
    register[5] = register[5] + 6;
    register[6] = register[6] + 7;
    register[7] = result;
  end

  wire pixel;

  wire [4:0] column = hpos[6:2];
  wire [2:0] line = vpos[4:2];

  registerToPixel r1(.register(register[vpos[7:5]]),
                     .line(line),
                     .column(column),
                     .pixel(pixel));

  wire r = display_on && 0;
  wire g = display_on && pixel && (hpos[9:7] == 3'b010);
  wire b = display_on && 0;

  reg vga_R, vga_G, vga_B;
  always @(posedge clk)
  begin
  	vga_R <= r;
  	vga_G <= g;
  	vga_B <= b;
  end

endmodule
