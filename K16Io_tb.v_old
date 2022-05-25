`include "K16Io.v"
/*
`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module test3();

reg         clk;
reg         reset;
wire [15:0] cpuInput0;
wire [15:0] cpuInput1;
reg [15:0] cpuOutput0;
reg [15:0] cpuOutput1;

wire [2:0] select;
wire [3:0] outputBits;
reg  [3:0] inputBits;
always #1 clk = ~clk;

K16Io io(
  .clk(clk),
  .reset(reset),
  .select(select),
  .outputBits(outputBits),
  .inputBits(inputBits),
  .cpuOutput0(cpuOutput0),
  .cpuOutput1(cpuOutput1),
  .cpuInput0(cpuInput0),
  .cpuInput1(cpuInput1));

initial begin

// initialize testbench variables
clk = 1;
reset = 1;

#500
reset = 0;
cpuOutput0 <= 16'h1234;
cpuOutput1 <= 16'h5678;
@(posedge clk);

$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);
@(posedge clk);
$display($time, " select = %0X, outputBits = %0X, inputBits = %0x", select, outputBits, inputBits);


  $finish;

end
endmodule
*/
