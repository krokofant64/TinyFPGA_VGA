`ifndef SPRITE_V
`define SPRITE_V

module drawSprite(line, column, red, green, blue);
  input [3:0] line;
  input [3:0] column;
  output red;
  output green;
  output blue;

  reg [15:0] redbits[0:15]; // ROM array (16 x 16 bits)
  reg [15:0] greenbits[0:15]; // ROM array (16 x 16 bits)
  reg [15:0] bluebits[0:15]; // ROM array (16 x 16 bits)

  assign red = redbits[line][~column];
  assign green = greenbits[line][~column];
  assign blue = bluebits[line][~column];

  initial begin

    redbits[0]  <= 16'b1111111100000000;
    redbits[1]  <= 16'b1111111100000000;
    redbits[2]  <= 16'b1111111100000000;
    redbits[3]  <= 16'b1111111100000000;
    redbits[4]  <= 16'b1111111100000000;
    redbits[5]  <= 16'b1111111100000000;
    redbits[6]  <= 16'b1111111100000000;
    redbits[7]  <= 16'b1111111100000000;
    redbits[8]  <= 16'b1111111100000000;
    redbits[9]  <= 16'b1111111100000000;
    redbits[10] <= 16'b1111111100000000;
    redbits[11] <= 16'b1111111100000000;
    redbits[12] <= 16'b1111111100000000;
    redbits[13] <= 16'b1111111100000000;
    redbits[14] <= 16'b1111111100000000;
    redbits[15] <= 16'b1111111100000000;

    greenbits[0]  <= 16'b1111111111111111;
    greenbits[1]  <= 16'b1111111111111111;
    greenbits[2]  <= 16'b1111111111111111;
    greenbits[3]  <= 16'b1111111111111111;
    greenbits[4]  <= 16'b1111111111111111;
    greenbits[5]  <= 16'b1111111111111111;
    greenbits[6]  <= 16'b1111111111111111;
    greenbits[7]  <= 16'b1111111111111111;
    greenbits[8]  <= 16'b0000000000000000;
    greenbits[9]  <= 16'b0000000000000000;
    greenbits[10] <= 16'b0000000000000000;
    greenbits[11] <= 16'b0000000000000000;
    greenbits[12] <= 16'b0000000000000000;
    greenbits[13] <= 16'b0000000000000000;
    greenbits[14] <= 16'b0000000000000000;
    greenbits[15] <= 16'b0000000000000000;

    bluebits[0]  <= 16'b0000000000000000;
    bluebits[1]  <= 16'b0000000000000000;
    bluebits[2]  <= 16'b0000000000000000;
    bluebits[3]  <= 16'b0000000000000000;
    bluebits[4]  <= 16'b0000111111110000;
    bluebits[5]  <= 16'b0000111111110000;
    bluebits[6]  <= 16'b0000111111110000;
    bluebits[7]  <= 16'b0000111111110000;
    bluebits[8]  <= 16'b0000111111110000;
    bluebits[9]  <= 16'b0000111111110000;
    bluebits[10] <= 16'b0000111111110000;
    bluebits[11] <= 16'b0000111111110000;
    bluebits[12] <= 16'b0000000000000000;
    bluebits[13] <= 16'b0000000000000000;
    bluebits[14] <= 16'b0000000000000000;
    bluebits[15] <= 16'b0000000000000000;


  end
endmodule

`endif
