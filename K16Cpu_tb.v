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

  ram[0] = 16'h0480;

  $monitor("clk=%b,reset=%b,hold=%b,busy=%b,address=%04X,data_in=%04X,data_out=%04X,write=%b",clk,reset,hold,busy,address,data_in,data_out,write);

  clk = 1;
  reset = 1;

  #1
  clk = 0;
  reset = 0;

  #2
  clk = 1;
  reset = 0;

  #3
  clk = 0;
  reset = 0;

  #4
  clk = 1;
  reset = 0;

  #5
  clk = 0;
  reset = 0;

  #6
  clk = 1;
  reset = 0;

  #7
  clk = 0;
  reset = 0;
  #8
  clk = 1;
  reset = 0;

  #9
  clk = 0;
  reset = 0;


end
endmodule
