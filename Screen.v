`ifndef SCREEN_V
`define SCREEN_V

module Screen(line, column, code);

  parameter Width = 640;
  parameter Height = 480;
  input [6:0] line;
  input [7:0] column;
  output [7:0] code;


  reg [Width*Height/64:0] charcode[7:0]; // RAM array (640 * 480 / 64 x 8 bits)

  assign code = charcode[line * Width + column];
endmodule
`endif
