`include "K16Cpu.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test2();

reg         clk;
reg         reset;
wire        hold;
wire        busy;
wire [15:0] address;
reg [15:0] data_in;
wire [15:0] data_out;
wire        write;

always #1 clk = ~clk;

K16Cpu cpu(
  .clk(clk),
  .reset(reset),
  .hold(hold),
  .busy(busy),
  .address(address),
  .data_in(data_in),
  .data_out(data_out),
  .write(write));

  reg [15:0] ram[0:65535];

  always @(posedge clk)
    if (write) begin
      ram[address] <= data_out;
    end

  always @(posedge clk)
    data_in <= ram[address];

initial begin

  ram[0] = 16'h6257;
  ram[1] = 16'h0480;
  ram[2] = 16'h9FFF;

  $monitor("clk=%b,reset=%b,hold=%b,busy=%b,address=%04X,data_in=%04X,data_out=%04X,write=%b",clk,reset,hold,busy,address,data_in,data_out,write);

  // initialize testbench variables
  clk = 1;
  reset = 1;

  #1
  clk = 0;
  reset = 0;

  repeat (20) @(posedge clk);
  $finish;

end
endmodule
