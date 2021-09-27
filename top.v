// Pong VGA game
// (c) fpga4fun.com

`include "registerToPixel.v"
`include "alu.v"
`include "sprite.v"

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

  // player position
  reg [9:0] player_x = 100;
  reg [9:0] player_y = 150;

  // car bitmap ROM and associated wires
  wire [3:0] spriteLine;
  wire [63:0] spriteBits;

  spriteBitmap bitmap(.line(spriteLine),
                      .bits(spriteBits));

  // convert player X/Y to 9 bits and compare to CRT hpos/vpos
  wire vstart = player_y == vpos;
  wire hstart = player_x == hpos;

  wire redPixel;
  wire greenPixel;
  wire bluePixel;
  wire alphaPixel;
  wire in_progress;	// 1 = rendering taking place on scanline

  // sprite renderer module
  SpriteRenderer renderer(.theClk(clk),
                          .vstart(vstart),
                          .load(vga_h_sync),
                          .hstart(hstart),
                          .theSpriteLine(spriteLine),
                          .theSpriteBits(spriteBits),
                          .red(redPixel),
                          .green(greenPixel),
                          .blue(bluePixel),
                          .alpha(alphaPixel),
                          .in_progress(in_progress));

  wire carry = 0;
  wire carryOut;
  wire zeroOut;
  wire negativeOut;
  wire [15:0] result;
  reg enableAlu = 1'b1;
  reg enableShift = 1'b0;
  reg enableLoad = 1'b0;
  Alu alu1(.operand1(register[1]),
           .operand2(register[2]),
           .carryIn(carry),
           .operationType(`ALU_OP),
           .operation(`AND_OP),
           .result(result),
           .carryOut(carryOut),
           .zeroOut(zeroOut),
           .negativeOut(negativeOut));

  always @(posedge vga_v_sync)
  begin
    register[0]++;
    register[1] = register[1] + 2;
    register[2] = register[2] + 3;
    register[3] = register[3] + 4;
    register[4] = register[4] + 5;
    register[5] = register[5] + 6;
    register[6] = carryOut;
    register[7] = result[15:0];
  end

  wire pixel;

  wire [4:0] column = hpos[6:2];
  wire [2:0] line = vpos[4:2];

  registerToPixel r1(.register(register[vpos[7:5]]),
                     .line(line),
                     .column(column),
                     .pixel(pixel));
  wire r = (redPixel || !alphaPixel) && display_on;
  wire g = (greenPixel || !alphaPixel) && display_on;
  wire b = (bluePixel || !alphaPixel) && display_on;

/*
  wire r = display_on && ((redPixel && alphaPixel && in_progress));
  wire g = display_on && (pixel && (hpos[9:7] == 3'b010)) || (greenPixel && alphaPixel);
  wire b = display_on && ((bluePixel && alphaPixel));
*/
  reg vga_R, vga_G, vga_B;
  always @(posedge clk)
  begin
  	vga_R <= r;
  	vga_G <= g;
  	vga_B <= b;
  end

endmodule
