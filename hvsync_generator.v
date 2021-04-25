module hvsync_generator(clk, vga_h_sync, vga_v_sync, display_on, hpos, vpos);
input clk;
output vga_h_sync, vga_v_sync;
output reg display_on;
output reg [9:0] hpos;
output reg [9:0] vpos;

//////////////////////////////////////////////////
wire hposmaxed = (hpos == 800); // 16 + 48 + 96 + 640
wire vposmaxed = (vpos == 525); // 10 + 2 + 33 + 480

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
	vga_HS <= (hpos > (640 + 16) && (hpos < (640 + 16 + 96)));   // active for 96 clocks
	vga_VS <= (vpos > (480 + 10) && (vpos < (480 + 10 + 2)));   // active for 2 clocks
end

always @(posedge clk)
begin
		display_on <= (hpos < 640) && (vpos < 480);
end

assign vga_h_sync = ~vga_HS;
assign vga_v_sync = ~vga_VS;

endmodule
