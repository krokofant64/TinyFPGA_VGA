`ifndef K16HVSYNCGENERATOR_H
`define K16HVSYNCGENERATOR_H

module K16HvsyncGenerator(clk, vga_h_sync, vga_v_sync, display_on, hpos, vpos);
input clk;
output vga_h_sync, vga_v_sync;
output display_on;
output reg [9:0] hpos;
output reg [9:0] vpos;

//////////////////////////////////////////////////
// 640 x 480 at 60 Hz: hpos 0 .. 799 (640 + 16 + 96 + 48), vpos 0 .. 524 (480 + 10 + 2 + 33)
wire hposmaxed = (hpos == 799);
wire vposmaxed = (vpos == 524);

always @(posedge clk)
if(hposmaxed)
	hpos <= 0;
else
	hpos <= hpos + 1;

always @(posedge clk)
begin
	if (hposmaxed)
	begin
		if(vposmaxed)
			vpos <= 0;
		else
			vpos <= vpos + 1;
	end
end

reg	vga_HS, vga_VS;
always @(posedge clk)
begin
	vga_HS <= (hpos >= (640 + 16) && (hpos < (640 + 16 + 96)));  // active for 96 clocks
	vga_VS <= (vpos >= (480 + 10) && (vpos < (480 + 10 + 2)));   // active for 2 lines
end

// Not registered: the pixels are generated from hpos and vpos directly, a
// registered display_on would shift the picture by one pixel
assign display_on = (hpos < 640) && (vpos < 480);

assign vga_h_sync = ~vga_HS;
assign vga_v_sync = ~vga_VS;

endmodule

`endif
