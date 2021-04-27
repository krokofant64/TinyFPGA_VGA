`ifndef REGISTERTOPIXEL_V
`define REGISTERTOPIXEL_V

module digitToPixel(digit, line, bits);

  input [3:0] digit;	// digit 0-9
  input [2:0] line;		// vertical offset (0-7)
  output [7:0] bits;	// output (8 bits)

  reg [7:0] bitarray[0:15][0:7]; // ROM array (16 x 8 x 8 bits)

  assign bits = bitarray[digit][line];	// assign module output

  integer i,j;
  initial begin

    // zero
    bitarray[0][0] <= 8'h7C;
    bitarray[0][1] <= 8'hC6;
    bitarray[0][2] <= 8'hCE;
    bitarray[0][3] <= 8'hDE;
    bitarray[0][4] <= 8'hF6;
    bitarray[0][5] <= 8'hE6;
    bitarray[0][6] <= 8'h7C;
    bitarray[0][7] <= 8'h00;

    // one
    bitarray[1][0] <= 8'h30;
    bitarray[1][1] <= 8'h70;
    bitarray[1][2] <= 8'h30;
    bitarray[1][3] <= 8'h30;
    bitarray[1][4] <= 8'h30;
    bitarray[1][5] <= 8'h30;
    bitarray[1][6] <= 8'hfc;
    bitarray[1][7] <= 8'h00;

    // two
    bitarray[2][0] <= 8'h78;
    bitarray[2][1] <= 8'hCC;
    bitarray[2][2] <= 8'h0C;
    bitarray[2][3] <= 8'h38;
    bitarray[2][4] <= 8'h60;
    bitarray[2][5] <= 8'hC4;
    bitarray[2][6] <= 8'hFC;
    bitarray[2][7] <= 8'h00;

    // three
    bitarray[3][0] <= 8'h78;
    bitarray[3][1] <= 8'hCC;
    bitarray[3][2] <= 8'h0C;
    bitarray[3][3] <= 8'h38;
    bitarray[3][4] <= 8'h0C;
    bitarray[3][5] <= 8'hCC;
    bitarray[3][6] <= 8'h78;
    bitarray[3][7] <= 8'h00;

    // four
    bitarray[4][0] <= 8'h1C;
    bitarray[4][1] <= 8'h3C;
    bitarray[4][2] <= 8'h6C;
    bitarray[4][3] <= 8'hCC;
    bitarray[4][4] <= 8'hFE;
    bitarray[4][5] <= 8'h0C;
    bitarray[4][6] <= 8'h1E;
    bitarray[4][7] <= 8'h00;

    // five
    bitarray[5][0] <= 8'hFC;
    bitarray[5][1] <= 8'hC0;
    bitarray[5][2] <= 8'hF8;
    bitarray[5][3] <= 8'h0C;
    bitarray[5][4] <= 8'h0C;
    bitarray[5][5] <= 8'hCC;
    bitarray[5][6] <= 8'h78;
    bitarray[5][7] <= 8'h00;

    // six
    bitarray[6][0] <= 8'h38;
    bitarray[6][1] <= 8'h60;
    bitarray[6][2] <= 8'hC0;
    bitarray[6][3] <= 8'hF8;
    bitarray[6][4] <= 8'hCC;
    bitarray[6][5] <= 8'hCC;
    bitarray[6][6] <= 8'h78;
    bitarray[6][7] <= 8'h00;

    // seven
    bitarray[7][0] <= 8'hFC;
    bitarray[7][1] <= 8'hCC;
    bitarray[7][2] <= 8'h0C;
    bitarray[7][3] <= 8'h18;
    bitarray[7][4] <= 8'h30;
    bitarray[7][5] <= 8'h30;
    bitarray[7][6] <= 8'h30;
    bitarray[7][7] <= 8'h00;

    // eight
    bitarray[8][0] <= 8'h78;
    bitarray[8][1] <= 8'hCC;
    bitarray[8][2] <= 8'hCC;
    bitarray[8][3] <= 8'h78;
    bitarray[8][4] <= 8'hCC;
    bitarray[8][5] <= 8'hCC;
    bitarray[8][6] <= 8'h78;
    bitarray[8][7] <= 8'h00;

    // nine
    bitarray[9][0] <= 8'h78;
    bitarray[9][1] <= 8'hCC;
    bitarray[9][2] <= 8'hCC;
    bitarray[9][3] <= 8'h7C;
    bitarray[9][4] <= 8'h0C;
    bitarray[9][5] <= 8'h18;
    bitarray[9][6] <= 8'h70;
    bitarray[9][7] <= 8'h00;

    // A
    bitarray[10][0] <= 8'h30;
    bitarray[10][1] <= 8'h78;
    bitarray[10][2] <= 8'hCC;
    bitarray[10][3] <= 8'hCC;
    bitarray[10][4] <= 8'hFC;
    bitarray[10][5] <= 8'hCC;
    bitarray[10][6] <= 8'hCC;
    bitarray[10][7] <= 8'h00;

    // B
    bitarray[11][0] <= 8'hFC;
    bitarray[11][1] <= 8'h66;
    bitarray[11][2] <= 8'h66;
    bitarray[11][3] <= 8'h7C;
    bitarray[11][4] <= 8'h66;
    bitarray[11][5] <= 8'h66;
    bitarray[11][6] <= 8'hFC;
    bitarray[11][7] <= 8'h00;

    // C
    bitarray[12][0] <= 8'h3C;
    bitarray[12][1] <= 8'h66;
    bitarray[12][2] <= 8'hC0;
    bitarray[12][3] <= 8'hC0;
    bitarray[12][4] <= 8'hC0;
    bitarray[12][5] <= 8'h66;
    bitarray[12][6] <= 8'h3C;
    bitarray[12][7] <= 8'h00;

    // D
    bitarray[13][0] <= 8'h78;
    bitarray[13][1] <= 8'h6C;
    bitarray[13][2] <= 8'h66;
    bitarray[13][3] <= 8'h66;
    bitarray[13][4] <= 8'h66;
    bitarray[13][5] <= 8'h6C;
    bitarray[13][6] <= 8'h78;
    bitarray[13][7] <= 8'h00;

    // E
    bitarray[14][0] <= 8'hFE;
    bitarray[14][1] <= 8'h62;
    bitarray[14][2] <= 8'h68;
    bitarray[14][3] <= 8'h78;
    bitarray[14][4] <= 8'h68;
    bitarray[14][5] <= 8'h62;
    bitarray[14][6] <= 8'hFE;
    bitarray[14][7] <= 8'h00;

    // F
    bitarray[15][0] <= 8'hFE;
    bitarray[15][1] <= 8'h62;
    bitarray[15][2] <= 8'h68;
    bitarray[15][3] <= 8'h78;
    bitarray[15][4] <= 8'h68;
    bitarray[15][5] <= 8'h60;
    bitarray[15][6] <= 8'hF0;
    bitarray[15][7] <= 8'h00;
  end
endmodule

module registerToPixel(register, line, column, pixel);
  input [15:0] register;
  input [2:0] line;
  input [4:0] column;
  output pixel;

  reg [3:0] digit;

  always @(register, line, column, pixel)
  begin
    case (column[4:3])
      2'b00: digit = register[15:12];
      2'b01: digit = register[11:8];
      2'b10: digit = register[7:4];
      2'b11: digit = register[3:0];
    endcase
  end

  wire [7:0] bits;

  digitToPixel numbers(.digit(digit),
                       .line(line),
                       .bits(bits));

  assign pixel = bits[~column[2:0]];
endmodule

`endif
