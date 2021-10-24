`ifndef REGISTERTOPIXEL_V
`define REGISTERTOPIXEL_V

module CharacterToPixel(character, line, bits);

  input [7:0] character; // ASCII character 0 .. 128
  input [2:0] line;		   // vertical offset (0-7)
  output [7:0] bits;	   // output (8 bits)

  reg [7:0] bitarray[0:128][0:7]; // ROM array (128 x 8 x 8 bits)

  assign bits = bitarray[character][line];	// assign module output

  initial begin

    // ASCII   0
    bitarray[0][0] <= 8'h00;
    bitarray[0][1] <= 8'h00;
    bitarray[0][2] <= 8'h00;
    bitarray[0][3] <= 8'h00;
    bitarray[0][4] <= 8'h00;
    bitarray[0][5] <= 8'h00;
    bitarray[0][6] <= 8'h00;
    bitarray[0][7] <= 8'h00;
    // ASCII   1
    bitarray[1][0] <= 8'h00;
    bitarray[1][1] <= 8'h00;
    bitarray[1][2] <= 8'h00;
    bitarray[1][3] <= 8'h00;
    bitarray[1][4] <= 8'h00;
    bitarray[1][5] <= 8'h00;
    bitarray[1][6] <= 8'h00;
    bitarray[1][7] <= 8'h00;
    // ASCII   2
    bitarray[2][0] <= 8'h00;
    bitarray[2][1] <= 8'h00;
    bitarray[2][2] <= 8'h00;
    bitarray[2][3] <= 8'h00;
    bitarray[2][4] <= 8'h00;
    bitarray[2][5] <= 8'h00;
    bitarray[2][6] <= 8'h00;
    bitarray[2][7] <= 8'h00;
    // ASCII   3
    bitarray[3][0] <= 8'h00;
    bitarray[3][1] <= 8'h00;
    bitarray[3][2] <= 8'h00;
    bitarray[3][3] <= 8'h00;
    bitarray[3][4] <= 8'h00;
    bitarray[3][5] <= 8'h00;
    bitarray[3][6] <= 8'h00;
    bitarray[3][7] <= 8'h00;
    // ASCII   4
    bitarray[4][0] <= 8'h00;
    bitarray[4][1] <= 8'h00;
    bitarray[4][2] <= 8'h00;
    bitarray[4][3] <= 8'h00;
    bitarray[4][4] <= 8'h00;
    bitarray[4][5] <= 8'h00;
    bitarray[4][6] <= 8'h00;
    bitarray[4][7] <= 8'h00;
    // ASCII   5
    bitarray[5][0] <= 8'h00;
    bitarray[5][1] <= 8'h00;
    bitarray[5][2] <= 8'h00;
    bitarray[5][3] <= 8'h00;
    bitarray[5][4] <= 8'h00;
    bitarray[5][5] <= 8'h00;
    bitarray[5][6] <= 8'h00;
    bitarray[5][7] <= 8'h00;
    // ASCII   6
    bitarray[6][0] <= 8'h00;
    bitarray[6][1] <= 8'h00;
    bitarray[6][2] <= 8'h00;
    bitarray[6][3] <= 8'h00;
    bitarray[6][4] <= 8'h00;
    bitarray[6][5] <= 8'h00;
    bitarray[6][6] <= 8'h00;
    bitarray[6][7] <= 8'h00;
    // ASCII   7
    bitarray[7][0] <= 8'h00;
    bitarray[7][1] <= 8'h00;
    bitarray[7][2] <= 8'h00;
    bitarray[7][3] <= 8'h00;
    bitarray[7][4] <= 8'h00;
    bitarray[7][5] <= 8'h00;
    bitarray[7][6] <= 8'h00;
    bitarray[7][7] <= 8'h00;
    // ASCII   8
    bitarray[8][0] <= 8'h00;
    bitarray[8][1] <= 8'h00;
    bitarray[8][2] <= 8'h00;
    bitarray[8][3] <= 8'h00;
    bitarray[8][4] <= 8'h00;
    bitarray[8][5] <= 8'h00;
    bitarray[8][6] <= 8'h00;
    bitarray[8][7] <= 8'h00;
    // ASCII   9
    bitarray[9][0] <= 8'h00;
    bitarray[9][1] <= 8'h00;
    bitarray[9][2] <= 8'h00;
    bitarray[9][3] <= 8'h00;
    bitarray[9][4] <= 8'h00;
    bitarray[9][5] <= 8'h00;
    bitarray[9][6] <= 8'h00;
    bitarray[9][7] <= 8'h00;
    // ASCII  10
    bitarray[10][0] <= 8'h00;
    bitarray[10][1] <= 8'h00;
    bitarray[10][2] <= 8'h00;
    bitarray[10][3] <= 8'h00;
    bitarray[10][4] <= 8'h00;
    bitarray[10][5] <= 8'h00;
    bitarray[10][6] <= 8'h00;
    bitarray[10][7] <= 8'h00;
    // ASCII  11
    bitarray[11][0] <= 8'h00;
    bitarray[11][1] <= 8'h00;
    bitarray[11][2] <= 8'h00;
    bitarray[11][3] <= 8'h00;
    bitarray[11][4] <= 8'h00;
    bitarray[11][5] <= 8'h00;
    bitarray[11][6] <= 8'h00;
    bitarray[11][7] <= 8'h00;
    // ASCII  12
    bitarray[12][0] <= 8'h00;
    bitarray[12][1] <= 8'h00;
    bitarray[12][2] <= 8'h00;
    bitarray[12][3] <= 8'h00;
    bitarray[12][4] <= 8'h00;
    bitarray[12][5] <= 8'h00;
    bitarray[12][6] <= 8'h00;
    bitarray[12][7] <= 8'h00;
    // ASCII  13
    bitarray[13][0] <= 8'h00;
    bitarray[13][1] <= 8'h00;
    bitarray[13][2] <= 8'h00;
    bitarray[13][3] <= 8'h00;
    bitarray[13][4] <= 8'h00;
    bitarray[13][5] <= 8'h00;
    bitarray[13][6] <= 8'h00;
    bitarray[13][7] <= 8'h00;
    // ASCII  14
    bitarray[14][0] <= 8'h00;
    bitarray[14][1] <= 8'h00;
    bitarray[14][2] <= 8'h00;
    bitarray[14][3] <= 8'h00;
    bitarray[14][4] <= 8'h00;
    bitarray[14][5] <= 8'h00;
    bitarray[14][6] <= 8'h00;
    bitarray[14][7] <= 8'h00;
    // ASCII  15
    bitarray[15][0] <= 8'h00;
    bitarray[15][1] <= 8'h00;
    bitarray[15][2] <= 8'h00;
    bitarray[15][3] <= 8'h00;
    bitarray[15][4] <= 8'h00;
    bitarray[15][5] <= 8'h00;
    bitarray[15][6] <= 8'h00;
    bitarray[15][7] <= 8'h00;
    // ASCII  16
    bitarray[16][0] <= 8'h00;
    bitarray[16][1] <= 8'h00;
    bitarray[16][2] <= 8'h00;
    bitarray[16][3] <= 8'h00;
    bitarray[16][4] <= 8'h00;
    bitarray[16][5] <= 8'h00;
    bitarray[16][6] <= 8'h00;
    bitarray[16][7] <= 8'h00;
    // ASCII  17
    bitarray[17][0] <= 8'h00;
    bitarray[17][1] <= 8'h00;
    bitarray[17][2] <= 8'h00;
    bitarray[17][3] <= 8'h00;
    bitarray[17][4] <= 8'h00;
    bitarray[17][5] <= 8'h00;
    bitarray[17][6] <= 8'h00;
    bitarray[17][7] <= 8'h00;
    // ASCII  18
    bitarray[18][0] <= 8'h00;
    bitarray[18][1] <= 8'h00;
    bitarray[18][2] <= 8'h00;
    bitarray[18][3] <= 8'h00;
    bitarray[18][4] <= 8'h00;
    bitarray[18][5] <= 8'h00;
    bitarray[18][6] <= 8'h00;
    bitarray[18][7] <= 8'h00;
    // ASCII  19
    bitarray[19][0] <= 8'h00;
    bitarray[19][1] <= 8'h00;
    bitarray[19][2] <= 8'h00;
    bitarray[19][3] <= 8'h00;
    bitarray[19][4] <= 8'h00;
    bitarray[19][5] <= 8'h00;
    bitarray[19][6] <= 8'h00;
    bitarray[19][7] <= 8'h00;
    // ASCII  20
    bitarray[20][0] <= 8'h00;
    bitarray[20][1] <= 8'h00;
    bitarray[20][2] <= 8'h00;
    bitarray[20][3] <= 8'h00;
    bitarray[20][4] <= 8'h00;
    bitarray[20][5] <= 8'h00;
    bitarray[20][6] <= 8'h00;
    bitarray[20][7] <= 8'h00;
    // ASCII  21
    bitarray[21][0] <= 8'h00;
    bitarray[21][1] <= 8'h00;
    bitarray[21][2] <= 8'h00;
    bitarray[21][3] <= 8'h00;
    bitarray[21][4] <= 8'h00;
    bitarray[21][5] <= 8'h00;
    bitarray[21][6] <= 8'h00;
    bitarray[21][7] <= 8'h00;
    // ASCII  22
    bitarray[22][0] <= 8'h00;
    bitarray[22][1] <= 8'h00;
    bitarray[22][2] <= 8'h00;
    bitarray[22][3] <= 8'h00;
    bitarray[22][4] <= 8'h00;
    bitarray[22][5] <= 8'h00;
    bitarray[22][6] <= 8'h00;
    bitarray[22][7] <= 8'h00;
    // ASCII  23
    bitarray[23][0] <= 8'h00;
    bitarray[23][1] <= 8'h00;
    bitarray[23][2] <= 8'h00;
    bitarray[23][3] <= 8'h00;
    bitarray[23][4] <= 8'h00;
    bitarray[23][5] <= 8'h00;
    bitarray[23][6] <= 8'h00;
    bitarray[23][7] <= 8'h00;
    // ASCII  24
    bitarray[24][0] <= 8'h00;
    bitarray[24][1] <= 8'h00;
    bitarray[24][2] <= 8'h00;
    bitarray[24][3] <= 8'h00;
    bitarray[24][4] <= 8'h00;
    bitarray[24][5] <= 8'h00;
    bitarray[24][6] <= 8'h00;
    bitarray[24][7] <= 8'h00;
    // ASCII  25
    bitarray[25][0] <= 8'h00;
    bitarray[25][1] <= 8'h00;
    bitarray[25][2] <= 8'h00;
    bitarray[25][3] <= 8'h00;
    bitarray[25][4] <= 8'h00;
    bitarray[25][5] <= 8'h00;
    bitarray[25][6] <= 8'h00;
    bitarray[25][7] <= 8'h00;
    // ASCII  26
    bitarray[26][0] <= 8'h00;
    bitarray[26][1] <= 8'h00;
    bitarray[26][2] <= 8'h00;
    bitarray[26][3] <= 8'h00;
    bitarray[26][4] <= 8'h00;
    bitarray[26][5] <= 8'h00;
    bitarray[26][6] <= 8'h00;
    bitarray[26][7] <= 8'h00;
    // ASCII  27
    bitarray[27][0] <= 8'h00;
    bitarray[27][1] <= 8'h00;
    bitarray[27][2] <= 8'h00;
    bitarray[27][3] <= 8'h00;
    bitarray[27][4] <= 8'h00;
    bitarray[27][5] <= 8'h00;
    bitarray[27][6] <= 8'h00;
    bitarray[27][7] <= 8'h00;
    // ASCII  28
    bitarray[28][0] <= 8'h00;
    bitarray[28][1] <= 8'h00;
    bitarray[28][2] <= 8'h00;
    bitarray[28][3] <= 8'h00;
    bitarray[28][4] <= 8'h00;
    bitarray[28][5] <= 8'h00;
    bitarray[28][6] <= 8'h00;
    bitarray[28][7] <= 8'h00;
    // ASCII  29
    bitarray[29][0] <= 8'h00;
    bitarray[29][1] <= 8'h00;
    bitarray[29][2] <= 8'h00;
    bitarray[29][3] <= 8'h00;
    bitarray[29][4] <= 8'h00;
    bitarray[29][5] <= 8'h00;
    bitarray[29][6] <= 8'h00;
    bitarray[29][7] <= 8'h00;
    // ASCII  30
    bitarray[30][0] <= 8'h00;
    bitarray[30][1] <= 8'h00;
    bitarray[30][2] <= 8'h00;
    bitarray[30][3] <= 8'h00;
    bitarray[30][4] <= 8'h00;
    bitarray[30][5] <= 8'h00;
    bitarray[30][6] <= 8'h00;
    bitarray[30][7] <= 8'h00;
    // ASCII  31
    bitarray[31][0] <= 8'h00;
    bitarray[31][1] <= 8'h00;
    bitarray[31][2] <= 8'h00;
    bitarray[31][3] <= 8'h00;
    bitarray[31][4] <= 8'h00;
    bitarray[31][5] <= 8'h00;
    bitarray[31][6] <= 8'h00;
    bitarray[31][7] <= 8'h00;
    // ASCII  32 ( )
    bitarray[32][0] <= 8'h00;
    bitarray[32][1] <= 8'h00;
    bitarray[32][2] <= 8'h00;
    bitarray[32][3] <= 8'h00;
    bitarray[32][4] <= 8'h00;
    bitarray[32][5] <= 8'h00;
    bitarray[32][6] <= 8'h00;
    bitarray[32][7] <= 8'h00;
    // ASCII  33 (!)
    bitarray[33][0] <= 8'h18;
    bitarray[33][1] <= 8'h3C;
    bitarray[33][2] <= 8'h3C;
    bitarray[33][3] <= 8'h18;
    bitarray[33][4] <= 8'h18;
    bitarray[33][5] <= 8'h00;
    bitarray[33][6] <= 8'h18;
    bitarray[33][7] <= 8'h00;
    // ASCII  34 (")
    bitarray[34][0] <= 8'h36;
    bitarray[34][1] <= 8'h36;
    bitarray[34][2] <= 8'h00;
    bitarray[34][3] <= 8'h00;
    bitarray[34][4] <= 8'h00;
    bitarray[34][5] <= 8'h00;
    bitarray[34][6] <= 8'h00;
    bitarray[34][7] <= 8'h00;
    // ASCII  35 (#)
    bitarray[35][0] <= 8'h36;
    bitarray[35][1] <= 8'h36;
    bitarray[35][2] <= 8'h7F;
    bitarray[35][3] <= 8'h36;
    bitarray[35][4] <= 8'h7F;
    bitarray[35][5] <= 8'h36;
    bitarray[35][6] <= 8'h36;
    bitarray[35][7] <= 8'h00;
    // ASCII  36 ($)
    bitarray[36][0] <= 8'h0C;
    bitarray[36][1] <= 8'h3E;
    bitarray[36][2] <= 8'h03;
    bitarray[36][3] <= 8'h1E;
    bitarray[36][4] <= 8'h30;
    bitarray[36][5] <= 8'h1F;
    bitarray[36][6] <= 8'h0C;
    bitarray[36][7] <= 8'h00;
    // ASCII  37 (%)
    bitarray[37][0] <= 8'h00;
    bitarray[37][1] <= 8'h63;
    bitarray[37][2] <= 8'h33;
    bitarray[37][3] <= 8'h18;
    bitarray[37][4] <= 8'h0C;
    bitarray[37][5] <= 8'h66;
    bitarray[37][6] <= 8'h63;
    bitarray[37][7] <= 8'h00;
    // ASCII  38 (&)
    bitarray[38][0] <= 8'h1C;
    bitarray[38][1] <= 8'h36;
    bitarray[38][2] <= 8'h1C;
    bitarray[38][3] <= 8'h6E;
    bitarray[38][4] <= 8'h3B;
    bitarray[38][5] <= 8'h33;
    bitarray[38][6] <= 8'h6E;
    bitarray[38][7] <= 8'h00;
    // ASCII  39 (')
    bitarray[39][0] <= 8'h06;
    bitarray[39][1] <= 8'h06;
    bitarray[39][2] <= 8'h03;
    bitarray[39][3] <= 8'h00;
    bitarray[39][4] <= 8'h00;
    bitarray[39][5] <= 8'h00;
    bitarray[39][6] <= 8'h00;
    bitarray[39][7] <= 8'h00;
    // ASCII  40 (()
    bitarray[40][0] <= 8'h18;
    bitarray[40][1] <= 8'h0C;
    bitarray[40][2] <= 8'h06;
    bitarray[40][3] <= 8'h06;
    bitarray[40][4] <= 8'h06;
    bitarray[40][5] <= 8'h0C;
    bitarray[40][6] <= 8'h18;
    bitarray[40][7] <= 8'h00;
    // ASCII  41 ())
    bitarray[41][0] <= 8'h06;
    bitarray[41][1] <= 8'h0C;
    bitarray[41][2] <= 8'h18;
    bitarray[41][3] <= 8'h18;
    bitarray[41][4] <= 8'h18;
    bitarray[41][5] <= 8'h0C;
    bitarray[41][6] <= 8'h06;
    bitarray[41][7] <= 8'h00;
    // ASCII  42 (*)
    bitarray[42][0] <= 8'h00;
    bitarray[42][1] <= 8'h66;
    bitarray[42][2] <= 8'h3C;
    bitarray[42][3] <= 8'hFF;
    bitarray[42][4] <= 8'h3C;
    bitarray[42][5] <= 8'h66;
    bitarray[42][6] <= 8'h00;
    bitarray[42][7] <= 8'h00;
    // ASCII  43 (+)
    bitarray[43][0] <= 8'h00;
    bitarray[43][1] <= 8'h0C;
    bitarray[43][2] <= 8'h0C;
    bitarray[43][3] <= 8'h3F;
    bitarray[43][4] <= 8'h0C;
    bitarray[43][5] <= 8'h0C;
    bitarray[43][6] <= 8'h00;
    bitarray[43][7] <= 8'h00;
    // ASCII  44 (,)
    bitarray[44][0] <= 8'h00;
    bitarray[44][1] <= 8'h00;
    bitarray[44][2] <= 8'h00;
    bitarray[44][3] <= 8'h00;
    bitarray[44][4] <= 8'h00;
    bitarray[44][5] <= 8'h0C;
    bitarray[44][6] <= 8'h0C;
    bitarray[44][7] <= 8'h06;
    // ASCII  45 (-)
    bitarray[45][0] <= 8'h00;
    bitarray[45][1] <= 8'h00;
    bitarray[45][2] <= 8'h00;
    bitarray[45][3] <= 8'h3F;
    bitarray[45][4] <= 8'h00;
    bitarray[45][5] <= 8'h00;
    bitarray[45][6] <= 8'h00;
    bitarray[45][7] <= 8'h00;
    // ASCII  46 (.)
    bitarray[46][0] <= 8'h00;
    bitarray[46][1] <= 8'h00;
    bitarray[46][2] <= 8'h00;
    bitarray[46][3] <= 8'h00;
    bitarray[46][4] <= 8'h00;
    bitarray[46][5] <= 8'h0C;
    bitarray[46][6] <= 8'h0C;
    bitarray[46][7] <= 8'h00;
    // ASCII  47 (/)
    bitarray[47][0] <= 8'h60;
    bitarray[47][1] <= 8'h30;
    bitarray[47][2] <= 8'h18;
    bitarray[47][3] <= 8'h0C;
    bitarray[47][4] <= 8'h06;
    bitarray[47][5] <= 8'h03;
    bitarray[47][6] <= 8'h01;
    bitarray[47][7] <= 8'h00;
    // ASCII  48 (0)
    bitarray[48][0] <= 8'h3E;
    bitarray[48][1] <= 8'h63;
    bitarray[48][2] <= 8'h73;
    bitarray[48][3] <= 8'h7B;
    bitarray[48][4] <= 8'h6F;
    bitarray[48][5] <= 8'h67;
    bitarray[48][6] <= 8'h3E;
    bitarray[48][7] <= 8'h00;
    // ASCII  49 (1)
    bitarray[49][0] <= 8'h0C;
    bitarray[49][1] <= 8'h0E;
    bitarray[49][2] <= 8'h0C;
    bitarray[49][3] <= 8'h0C;
    bitarray[49][4] <= 8'h0C;
    bitarray[49][5] <= 8'h0C;
    bitarray[49][6] <= 8'h3F;
    bitarray[49][7] <= 8'h00;
    // ASCII  50 (2)
    bitarray[50][0] <= 8'h1E;
    bitarray[50][1] <= 8'h33;
    bitarray[50][2] <= 8'h30;
    bitarray[50][3] <= 8'h1C;
    bitarray[50][4] <= 8'h06;
    bitarray[50][5] <= 8'h33;
    bitarray[50][6] <= 8'h3F;
    bitarray[50][7] <= 8'h00;
    // ASCII  51 (3)
    bitarray[51][0] <= 8'h1E;
    bitarray[51][1] <= 8'h33;
    bitarray[51][2] <= 8'h30;
    bitarray[51][3] <= 8'h1C;
    bitarray[51][4] <= 8'h30;
    bitarray[51][5] <= 8'h33;
    bitarray[51][6] <= 8'h1E;
    bitarray[51][7] <= 8'h00;
    // ASCII  52 (4)
    bitarray[52][0] <= 8'h38;
    bitarray[52][1] <= 8'h3C;
    bitarray[52][2] <= 8'h36;
    bitarray[52][3] <= 8'h33;
    bitarray[52][4] <= 8'h7F;
    bitarray[52][5] <= 8'h30;
    bitarray[52][6] <= 8'h78;
    bitarray[52][7] <= 8'h00;
    // ASCII  53 (5)
    bitarray[53][0] <= 8'h3F;
    bitarray[53][1] <= 8'h03;
    bitarray[53][2] <= 8'h1F;
    bitarray[53][3] <= 8'h30;
    bitarray[53][4] <= 8'h30;
    bitarray[53][5] <= 8'h33;
    bitarray[53][6] <= 8'h1E;
    bitarray[53][7] <= 8'h00;
    // ASCII  54 (6)
    bitarray[54][0] <= 8'h1C;
    bitarray[54][1] <= 8'h06;
    bitarray[54][2] <= 8'h03;
    bitarray[54][3] <= 8'h1F;
    bitarray[54][4] <= 8'h33;
    bitarray[54][5] <= 8'h33;
    bitarray[54][6] <= 8'h1E;
    bitarray[54][7] <= 8'h00;
    // ASCII  55 (7)
    bitarray[55][0] <= 8'h3F;
    bitarray[55][1] <= 8'h33;
    bitarray[55][2] <= 8'h30;
    bitarray[55][3] <= 8'h18;
    bitarray[55][4] <= 8'h0C;
    bitarray[55][5] <= 8'h0C;
    bitarray[55][6] <= 8'h0C;
    bitarray[55][7] <= 8'h00;
    // ASCII  56 (8)
    bitarray[56][0] <= 8'h1E;
    bitarray[56][1] <= 8'h33;
    bitarray[56][2] <= 8'h33;
    bitarray[56][3] <= 8'h1E;
    bitarray[56][4] <= 8'h33;
    bitarray[56][5] <= 8'h33;
    bitarray[56][6] <= 8'h1E;
    bitarray[56][7] <= 8'h00;
    // ASCII  57 (9)
    bitarray[57][0] <= 8'h1E;
    bitarray[57][1] <= 8'h33;
    bitarray[57][2] <= 8'h33;
    bitarray[57][3] <= 8'h3E;
    bitarray[57][4] <= 8'h30;
    bitarray[57][5] <= 8'h18;
    bitarray[57][6] <= 8'h0E;
    bitarray[57][7] <= 8'h00;
    // ASCII  58 (:)
    bitarray[58][0] <= 8'h00;
    bitarray[58][1] <= 8'h0C;
    bitarray[58][2] <= 8'h0C;
    bitarray[58][3] <= 8'h00;
    bitarray[58][4] <= 8'h00;
    bitarray[58][5] <= 8'h0C;
    bitarray[58][6] <= 8'h0C;
    bitarray[58][7] <= 8'h00;
    // ASCII  59 (;)
    bitarray[59][0] <= 8'h00;
    bitarray[59][1] <= 8'h0C;
    bitarray[59][2] <= 8'h0C;
    bitarray[59][3] <= 8'h00;
    bitarray[59][4] <= 8'h00;
    bitarray[59][5] <= 8'h0C;
    bitarray[59][6] <= 8'h0C;
    bitarray[59][7] <= 8'h06;
    // ASCII  60 (<)
    bitarray[60][0] <= 8'h18;
    bitarray[60][1] <= 8'h0C;
    bitarray[60][2] <= 8'h06;
    bitarray[60][3] <= 8'h03;
    bitarray[60][4] <= 8'h06;
    bitarray[60][5] <= 8'h0C;
    bitarray[60][6] <= 8'h18;
    bitarray[60][7] <= 8'h00;
    // ASCII  61 (=)
    bitarray[61][0] <= 8'h00;
    bitarray[61][1] <= 8'h00;
    bitarray[61][2] <= 8'h3F;
    bitarray[61][3] <= 8'h00;
    bitarray[61][4] <= 8'h00;
    bitarray[61][5] <= 8'h3F;
    bitarray[61][6] <= 8'h00;
    bitarray[61][7] <= 8'h00;
    // ASCII  62 (>)
    bitarray[62][0] <= 8'h06;
    bitarray[62][1] <= 8'h0C;
    bitarray[62][2] <= 8'h18;
    bitarray[62][3] <= 8'h30;
    bitarray[62][4] <= 8'h18;
    bitarray[62][5] <= 8'h0C;
    bitarray[62][6] <= 8'h06;
    bitarray[62][7] <= 8'h00;
    // ASCII  63 (?)
    bitarray[63][0] <= 8'h1E;
    bitarray[63][1] <= 8'h33;
    bitarray[63][2] <= 8'h30;
    bitarray[63][3] <= 8'h18;
    bitarray[63][4] <= 8'h0C;
    bitarray[63][5] <= 8'h00;
    bitarray[63][6] <= 8'h0C;
    bitarray[63][7] <= 8'h00;
    // ASCII  64 (@)
    bitarray[64][0] <= 8'h3E;
    bitarray[64][1] <= 8'h63;
    bitarray[64][2] <= 8'h7B;
    bitarray[64][3] <= 8'h7B;
    bitarray[64][4] <= 8'h7B;
    bitarray[64][5] <= 8'h03;
    bitarray[64][6] <= 8'h1E;
    bitarray[64][7] <= 8'h00;
    // ASCII  65 (A)
    bitarray[65][0] <= 8'h0C;
    bitarray[65][1] <= 8'h1E;
    bitarray[65][2] <= 8'h33;
    bitarray[65][3] <= 8'h33;
    bitarray[65][4] <= 8'h3F;
    bitarray[65][5] <= 8'h33;
    bitarray[65][6] <= 8'h33;
    bitarray[65][7] <= 8'h00;
    // ASCII  66 (B)
    bitarray[66][0] <= 8'h3F;
    bitarray[66][1] <= 8'h66;
    bitarray[66][2] <= 8'h66;
    bitarray[66][3] <= 8'h3E;
    bitarray[66][4] <= 8'h66;
    bitarray[66][5] <= 8'h66;
    bitarray[66][6] <= 8'h3F;
    bitarray[66][7] <= 8'h00;
    // ASCII  67 (C)
    bitarray[67][0] <= 8'h3C;
    bitarray[67][1] <= 8'h66;
    bitarray[67][2] <= 8'h03;
    bitarray[67][3] <= 8'h03;
    bitarray[67][4] <= 8'h03;
    bitarray[67][5] <= 8'h66;
    bitarray[67][6] <= 8'h3C;
    bitarray[67][7] <= 8'h00;
    // ASCII  68 (D)
    bitarray[68][0] <= 8'h1F;
    bitarray[68][1] <= 8'h36;
    bitarray[68][2] <= 8'h66;
    bitarray[68][3] <= 8'h66;
    bitarray[68][4] <= 8'h66;
    bitarray[68][5] <= 8'h36;
    bitarray[68][6] <= 8'h1F;
    bitarray[68][7] <= 8'h00;
    // ASCII  69 (E)
    bitarray[69][0] <= 8'h7F;
    bitarray[69][1] <= 8'h46;
    bitarray[69][2] <= 8'h16;
    bitarray[69][3] <= 8'h1E;
    bitarray[69][4] <= 8'h16;
    bitarray[69][5] <= 8'h46;
    bitarray[69][6] <= 8'h7F;
    bitarray[69][7] <= 8'h00;
    // ASCII  70 (F)
    bitarray[70][0] <= 8'h7F;
    bitarray[70][1] <= 8'h46;
    bitarray[70][2] <= 8'h16;
    bitarray[70][3] <= 8'h1E;
    bitarray[70][4] <= 8'h16;
    bitarray[70][5] <= 8'h06;
    bitarray[70][6] <= 8'h0F;
    bitarray[70][7] <= 8'h00;
    // ASCII  71 (G)
    bitarray[71][0] <= 8'h3C;
    bitarray[71][1] <= 8'h66;
    bitarray[71][2] <= 8'h03;
    bitarray[71][3] <= 8'h03;
    bitarray[71][4] <= 8'h73;
    bitarray[71][5] <= 8'h66;
    bitarray[71][6] <= 8'h7C;
    bitarray[71][7] <= 8'h00;
    // ASCII  72 (H)
    bitarray[72][0] <= 8'h33;
    bitarray[72][1] <= 8'h33;
    bitarray[72][2] <= 8'h33;
    bitarray[72][3] <= 8'h3F;
    bitarray[72][4] <= 8'h33;
    bitarray[72][5] <= 8'h33;
    bitarray[72][6] <= 8'h33;
    bitarray[72][7] <= 8'h00;
    // ASCII  73 (I)
    bitarray[73][0] <= 8'h1E;
    bitarray[73][1] <= 8'h0C;
    bitarray[73][2] <= 8'h0C;
    bitarray[73][3] <= 8'h0C;
    bitarray[73][4] <= 8'h0C;
    bitarray[73][5] <= 8'h0C;
    bitarray[73][6] <= 8'h1E;
    bitarray[73][7] <= 8'h00;
    // ASCII  74 (J)
    bitarray[74][0] <= 8'h78;
    bitarray[74][1] <= 8'h30;
    bitarray[74][2] <= 8'h30;
    bitarray[74][3] <= 8'h30;
    bitarray[74][4] <= 8'h33;
    bitarray[74][5] <= 8'h33;
    bitarray[74][6] <= 8'h1E;
    bitarray[74][7] <= 8'h00;
    // ASCII  75 (K)
    bitarray[75][0] <= 8'h67;
    bitarray[75][1] <= 8'h66;
    bitarray[75][2] <= 8'h36;
    bitarray[75][3] <= 8'h1E;
    bitarray[75][4] <= 8'h36;
    bitarray[75][5] <= 8'h66;
    bitarray[75][6] <= 8'h67;
    bitarray[75][7] <= 8'h00;
    // ASCII  76 (L)
    bitarray[76][0] <= 8'h0F;
    bitarray[76][1] <= 8'h06;
    bitarray[76][2] <= 8'h06;
    bitarray[76][3] <= 8'h06;
    bitarray[76][4] <= 8'h46;
    bitarray[76][5] <= 8'h66;
    bitarray[76][6] <= 8'h7F;
    bitarray[76][7] <= 8'h00;
    // ASCII  77 (M)
    bitarray[77][0] <= 8'h63;
    bitarray[77][1] <= 8'h77;
    bitarray[77][2] <= 8'h7F;
    bitarray[77][3] <= 8'h7F;
    bitarray[77][4] <= 8'h6B;
    bitarray[77][5] <= 8'h63;
    bitarray[77][6] <= 8'h63;
    bitarray[77][7] <= 8'h00;
    // ASCII  78 (N)
    bitarray[78][0] <= 8'h63;
    bitarray[78][1] <= 8'h67;
    bitarray[78][2] <= 8'h6F;
    bitarray[78][3] <= 8'h7B;
    bitarray[78][4] <= 8'h73;
    bitarray[78][5] <= 8'h63;
    bitarray[78][6] <= 8'h63;
    bitarray[78][7] <= 8'h00;
    // ASCII  79 (O)
    bitarray[79][0] <= 8'h1C;
    bitarray[79][1] <= 8'h36;
    bitarray[79][2] <= 8'h63;
    bitarray[79][3] <= 8'h63;
    bitarray[79][4] <= 8'h63;
    bitarray[79][5] <= 8'h36;
    bitarray[79][6] <= 8'h1C;
    bitarray[79][7] <= 8'h00;
    // ASCII  80 (P)
    bitarray[80][0] <= 8'h3F;
    bitarray[80][1] <= 8'h66;
    bitarray[80][2] <= 8'h66;
    bitarray[80][3] <= 8'h3E;
    bitarray[80][4] <= 8'h06;
    bitarray[80][5] <= 8'h06;
    bitarray[80][6] <= 8'h0F;
    bitarray[80][7] <= 8'h00;
    // ASCII  81 (Q)
    bitarray[81][0] <= 8'h1E;
    bitarray[81][1] <= 8'h33;
    bitarray[81][2] <= 8'h33;
    bitarray[81][3] <= 8'h33;
    bitarray[81][4] <= 8'h3B;
    bitarray[81][5] <= 8'h1E;
    bitarray[81][6] <= 8'h38;
    bitarray[81][7] <= 8'h00;
    // ASCII  82 (R)
    bitarray[82][0] <= 8'h3F;
    bitarray[82][1] <= 8'h66;
    bitarray[82][2] <= 8'h66;
    bitarray[82][3] <= 8'h3E;
    bitarray[82][4] <= 8'h36;
    bitarray[82][5] <= 8'h66;
    bitarray[82][6] <= 8'h67;
    bitarray[82][7] <= 8'h00;
    // ASCII  83 (S)
    bitarray[83][0] <= 8'h1E;
    bitarray[83][1] <= 8'h33;
    bitarray[83][2] <= 8'h07;
    bitarray[83][3] <= 8'h0E;
    bitarray[83][4] <= 8'h38;
    bitarray[83][5] <= 8'h33;
    bitarray[83][6] <= 8'h1E;
    bitarray[83][7] <= 8'h00;
    // ASCII  84 (T)
    bitarray[84][0] <= 8'h3F;
    bitarray[84][1] <= 8'h2D;
    bitarray[84][2] <= 8'h0C;
    bitarray[84][3] <= 8'h0C;
    bitarray[84][4] <= 8'h0C;
    bitarray[84][5] <= 8'h0C;
    bitarray[84][6] <= 8'h1E;
    bitarray[84][7] <= 8'h00;
    // ASCII  85 (U)
    bitarray[85][0] <= 8'h33;
    bitarray[85][1] <= 8'h33;
    bitarray[85][2] <= 8'h33;
    bitarray[85][3] <= 8'h33;
    bitarray[85][4] <= 8'h33;
    bitarray[85][5] <= 8'h33;
    bitarray[85][6] <= 8'h3F;
    bitarray[85][7] <= 8'h00;
    // ASCII  86 (V)
    bitarray[86][0] <= 8'h33;
    bitarray[86][1] <= 8'h33;
    bitarray[86][2] <= 8'h33;
    bitarray[86][3] <= 8'h33;
    bitarray[86][4] <= 8'h33;
    bitarray[86][5] <= 8'h1E;
    bitarray[86][6] <= 8'h0C;
    bitarray[86][7] <= 8'h00;
    // ASCII  87 (W)
    bitarray[87][0] <= 8'h63;
    bitarray[87][1] <= 8'h63;
    bitarray[87][2] <= 8'h63;
    bitarray[87][3] <= 8'h6B;
    bitarray[87][4] <= 8'h7F;
    bitarray[87][5] <= 8'h77;
    bitarray[87][6] <= 8'h63;
    bitarray[87][7] <= 8'h00;
    // ASCII  88 (X)
    bitarray[88][0] <= 8'h63;
    bitarray[88][1] <= 8'h63;
    bitarray[88][2] <= 8'h36;
    bitarray[88][3] <= 8'h1C;
    bitarray[88][4] <= 8'h1C;
    bitarray[88][5] <= 8'h36;
    bitarray[88][6] <= 8'h63;
    bitarray[88][7] <= 8'h00;
    // ASCII  89 (Y)
    bitarray[89][0] <= 8'h33;
    bitarray[89][1] <= 8'h33;
    bitarray[89][2] <= 8'h33;
    bitarray[89][3] <= 8'h1E;
    bitarray[89][4] <= 8'h0C;
    bitarray[89][5] <= 8'h0C;
    bitarray[89][6] <= 8'h1E;
    bitarray[89][7] <= 8'h00;
    // ASCII  90 (Z)
    bitarray[90][0] <= 8'h7F;
    bitarray[90][1] <= 8'h63;
    bitarray[90][2] <= 8'h31;
    bitarray[90][3] <= 8'h18;
    bitarray[90][4] <= 8'h4C;
    bitarray[90][5] <= 8'h66;
    bitarray[90][6] <= 8'h7F;
    bitarray[90][7] <= 8'h00;
    // ASCII  91 ([)
    bitarray[91][0] <= 8'h1E;
    bitarray[91][1] <= 8'h06;
    bitarray[91][2] <= 8'h06;
    bitarray[91][3] <= 8'h06;
    bitarray[91][4] <= 8'h06;
    bitarray[91][5] <= 8'h06;
    bitarray[91][6] <= 8'h1E;
    bitarray[91][7] <= 8'h00;
    // ASCII  92 (\)
    bitarray[92][0] <= 8'h03;
    bitarray[92][1] <= 8'h06;
    bitarray[92][2] <= 8'h0C;
    bitarray[92][3] <= 8'h18;
    bitarray[92][4] <= 8'h30;
    bitarray[92][5] <= 8'h60;
    bitarray[92][6] <= 8'h40;
    bitarray[92][7] <= 8'h00;
    // ASCII  93 (])
    bitarray[93][0] <= 8'h1E;
    bitarray[93][1] <= 8'h18;
    bitarray[93][2] <= 8'h18;
    bitarray[93][3] <= 8'h18;
    bitarray[93][4] <= 8'h18;
    bitarray[93][5] <= 8'h18;
    bitarray[93][6] <= 8'h1E;
    bitarray[93][7] <= 8'h00;
    // ASCII  94 (^)
    bitarray[94][0] <= 8'h08;
    bitarray[94][1] <= 8'h1C;
    bitarray[94][2] <= 8'h36;
    bitarray[94][3] <= 8'h63;
    bitarray[94][4] <= 8'h00;
    bitarray[94][5] <= 8'h00;
    bitarray[94][6] <= 8'h00;
    bitarray[94][7] <= 8'h00;
    // ASCII  95 (_)
    bitarray[95][0] <= 8'h00;
    bitarray[95][1] <= 8'h00;
    bitarray[95][2] <= 8'h00;
    bitarray[95][3] <= 8'h00;
    bitarray[95][4] <= 8'h00;
    bitarray[95][5] <= 8'h00;
    bitarray[95][6] <= 8'h00;
    bitarray[95][7] <= 8'hFF;
    // ASCII  96 (`)
    bitarray[96][0] <= 8'h0C;
    bitarray[96][1] <= 8'h0C;
    bitarray[96][2] <= 8'h18;
    bitarray[96][3] <= 8'h00;
    bitarray[96][4] <= 8'h00;
    bitarray[96][5] <= 8'h00;
    bitarray[96][6] <= 8'h00;
    bitarray[96][7] <= 8'h00;
    // ASCII  97 (a)
    bitarray[97][0] <= 8'h00;
    bitarray[97][1] <= 8'h00;
    bitarray[97][2] <= 8'h1E;
    bitarray[97][3] <= 8'h30;
    bitarray[97][4] <= 8'h3E;
    bitarray[97][5] <= 8'h33;
    bitarray[97][6] <= 8'h6E;
    bitarray[97][7] <= 8'h00;
    // ASCII  98 (b)
    bitarray[98][0] <= 8'h07;
    bitarray[98][1] <= 8'h06;
    bitarray[98][2] <= 8'h06;
    bitarray[98][3] <= 8'h3E;
    bitarray[98][4] <= 8'h66;
    bitarray[98][5] <= 8'h66;
    bitarray[98][6] <= 8'h3B;
    bitarray[98][7] <= 8'h00;
    // ASCII  99 (c)
    bitarray[99][0] <= 8'h00;
    bitarray[99][1] <= 8'h00;
    bitarray[99][2] <= 8'h1E;
    bitarray[99][3] <= 8'h33;
    bitarray[99][4] <= 8'h03;
    bitarray[99][5] <= 8'h33;
    bitarray[99][6] <= 8'h1E;
    bitarray[99][7] <= 8'h00;
    // ASCII 100 (d)
    bitarray[100][0] <= 8'h38;
    bitarray[100][1] <= 8'h30;
    bitarray[100][2] <= 8'h30;
    bitarray[100][3] <= 8'h3E;
    bitarray[100][4] <= 8'h33;
    bitarray[100][5] <= 8'h33;
    bitarray[100][6] <= 8'h6E;
    bitarray[100][7] <= 8'h00;
    // ASCII 101 (e)
    bitarray[101][0] <= 8'h00;
    bitarray[101][1] <= 8'h00;
    bitarray[101][2] <= 8'h1E;
    bitarray[101][3] <= 8'h33;
    bitarray[101][4] <= 8'h3F;
    bitarray[101][5] <= 8'h03;
    bitarray[101][6] <= 8'h1E;
    bitarray[101][7] <= 8'h00;
    // ASCII 102 (f)
    bitarray[102][0] <= 8'h1C;
    bitarray[102][1] <= 8'h36;
    bitarray[102][2] <= 8'h06;
    bitarray[102][3] <= 8'h0F;
    bitarray[102][4] <= 8'h06;
    bitarray[102][5] <= 8'h06;
    bitarray[102][6] <= 8'h0F;
    bitarray[102][7] <= 8'h00;
    // ASCII 103 (g)
    bitarray[103][0] <= 8'h00;
    bitarray[103][1] <= 8'h00;
    bitarray[103][2] <= 8'h6E;
    bitarray[103][3] <= 8'h33;
    bitarray[103][4] <= 8'h33;
    bitarray[103][5] <= 8'h3E;
    bitarray[103][6] <= 8'h30;
    bitarray[103][7] <= 8'h1F;
    // ASCII 104 (h)
    bitarray[104][0] <= 8'h07;
    bitarray[104][1] <= 8'h06;
    bitarray[104][2] <= 8'h36;
    bitarray[104][3] <= 8'h6E;
    bitarray[104][4] <= 8'h66;
    bitarray[104][5] <= 8'h66;
    bitarray[104][6] <= 8'h67;
    bitarray[104][7] <= 8'h00;
    // ASCII 105 (i)
    bitarray[105][0] <= 8'h0C;
    bitarray[105][1] <= 8'h00;
    bitarray[105][2] <= 8'h0E;
    bitarray[105][3] <= 8'h0C;
    bitarray[105][4] <= 8'h0C;
    bitarray[105][5] <= 8'h0C;
    bitarray[105][6] <= 8'h1E;
    bitarray[105][7] <= 8'h00;
    // ASCII 106 (j)
    bitarray[106][0] <= 8'h30;
    bitarray[106][1] <= 8'h00;
    bitarray[106][2] <= 8'h30;
    bitarray[106][3] <= 8'h30;
    bitarray[106][4] <= 8'h30;
    bitarray[106][5] <= 8'h33;
    bitarray[106][6] <= 8'h33;
    bitarray[106][7] <= 8'h1E;
    // ASCII 107 (k)
    bitarray[107][0] <= 8'h07;
    bitarray[107][1] <= 8'h06;
    bitarray[107][2] <= 8'h66;
    bitarray[107][3] <= 8'h36;
    bitarray[107][4] <= 8'h1E;
    bitarray[107][5] <= 8'h36;
    bitarray[107][6] <= 8'h67;
    bitarray[107][7] <= 8'h00;
    // ASCII 108 (l)
    bitarray[108][0] <= 8'h0E;
    bitarray[108][1] <= 8'h0C;
    bitarray[108][2] <= 8'h0C;
    bitarray[108][3] <= 8'h0C;
    bitarray[108][4] <= 8'h0C;
    bitarray[108][5] <= 8'h0C;
    bitarray[108][6] <= 8'h1E;
    bitarray[108][7] <= 8'h00;
    // ASCII 109 (m)
    bitarray[109][0] <= 8'h00;
    bitarray[109][1] <= 8'h00;
    bitarray[109][2] <= 8'h33;
    bitarray[109][3] <= 8'h7F;
    bitarray[109][4] <= 8'h7F;
    bitarray[109][5] <= 8'h6B;
    bitarray[109][6] <= 8'h63;
    bitarray[109][7] <= 8'h00;
    // ASCII 110 (n)
    bitarray[110][0] <= 8'h00;
    bitarray[110][1] <= 8'h00;
    bitarray[110][2] <= 8'h1F;
    bitarray[110][3] <= 8'h33;
    bitarray[110][4] <= 8'h33;
    bitarray[110][5] <= 8'h33;
    bitarray[110][6] <= 8'h33;
    bitarray[110][7] <= 8'h00;
    // ASCII 111 (o)
    bitarray[111][0] <= 8'h00;
    bitarray[111][1] <= 8'h00;
    bitarray[111][2] <= 8'h1E;
    bitarray[111][3] <= 8'h33;
    bitarray[111][4] <= 8'h33;
    bitarray[111][5] <= 8'h33;
    bitarray[111][6] <= 8'h1E;
    bitarray[111][7] <= 8'h00;
    // ASCII 112 (p)
    bitarray[112][0] <= 8'h00;
    bitarray[112][1] <= 8'h00;
    bitarray[112][2] <= 8'h3B;
    bitarray[112][3] <= 8'h66;
    bitarray[112][4] <= 8'h66;
    bitarray[112][5] <= 8'h3E;
    bitarray[112][6] <= 8'h06;
    bitarray[112][7] <= 8'h0F;
    // ASCII 113 (q)
    bitarray[113][0] <= 8'h00;
    bitarray[113][1] <= 8'h00;
    bitarray[113][2] <= 8'h6E;
    bitarray[113][3] <= 8'h33;
    bitarray[113][4] <= 8'h33;
    bitarray[113][5] <= 8'h3E;
    bitarray[113][6] <= 8'h30;
    bitarray[113][7] <= 8'h78;
    // ASCII 114 (r)
    bitarray[114][0] <= 8'h00;
    bitarray[114][1] <= 8'h00;
    bitarray[114][2] <= 8'h3B;
    bitarray[114][3] <= 8'h6E;
    bitarray[114][4] <= 8'h66;
    bitarray[114][5] <= 8'h06;
    bitarray[114][6] <= 8'h0F;
    bitarray[114][7] <= 8'h00;
    // ASCII 115 (s)
    bitarray[115][0] <= 8'h00;
    bitarray[115][1] <= 8'h00;
    bitarray[115][2] <= 8'h3E;
    bitarray[115][3] <= 8'h03;
    bitarray[115][4] <= 8'h1E;
    bitarray[115][5] <= 8'h30;
    bitarray[115][6] <= 8'h1F;
    bitarray[115][7] <= 8'h00;
    // ASCII 116 (t)
    bitarray[116][0] <= 8'h08;
    bitarray[116][1] <= 8'h0C;
    bitarray[116][2] <= 8'h3E;
    bitarray[116][3] <= 8'h0C;
    bitarray[116][4] <= 8'h0C;
    bitarray[116][5] <= 8'h2C;
    bitarray[116][6] <= 8'h18;
    bitarray[116][7] <= 8'h00;
    // ASCII 117 (u)
    bitarray[117][0] <= 8'h00;
    bitarray[117][1] <= 8'h00;
    bitarray[117][2] <= 8'h33;
    bitarray[117][3] <= 8'h33;
    bitarray[117][4] <= 8'h33;
    bitarray[117][5] <= 8'h33;
    bitarray[117][6] <= 8'h6E;
    bitarray[117][7] <= 8'h00;
    // ASCII 118 (v)
    bitarray[118][0] <= 8'h00;
    bitarray[118][1] <= 8'h00;
    bitarray[118][2] <= 8'h33;
    bitarray[118][3] <= 8'h33;
    bitarray[118][4] <= 8'h33;
    bitarray[118][5] <= 8'h1E;
    bitarray[118][6] <= 8'h0C;
    bitarray[118][7] <= 8'h00;
    // ASCII 119 (w)
    bitarray[119][0] <= 8'h00;
    bitarray[119][1] <= 8'h00;
    bitarray[119][2] <= 8'h63;
    bitarray[119][3] <= 8'h6B;
    bitarray[119][4] <= 8'h7F;
    bitarray[119][5] <= 8'h7F;
    bitarray[119][6] <= 8'h36;
    bitarray[119][7] <= 8'h00;
    // ASCII 120 (x)
    bitarray[120][0] <= 8'h00;
    bitarray[120][1] <= 8'h00;
    bitarray[120][2] <= 8'h63;
    bitarray[120][3] <= 8'h36;
    bitarray[120][4] <= 8'h1C;
    bitarray[120][5] <= 8'h36;
    bitarray[120][6] <= 8'h63;
    bitarray[120][7] <= 8'h00;
    // ASCII 121 (y)
    bitarray[121][0] <= 8'h00;
    bitarray[121][1] <= 8'h00;
    bitarray[121][2] <= 8'h33;
    bitarray[121][3] <= 8'h33;
    bitarray[121][4] <= 8'h33;
    bitarray[121][5] <= 8'h3E;
    bitarray[121][6] <= 8'h30;
    bitarray[121][7] <= 8'h1F;
    // ASCII 122 (z)
    bitarray[122][0] <= 8'h00;
    bitarray[122][1] <= 8'h00;
    bitarray[122][2] <= 8'h3F;
    bitarray[122][3] <= 8'h19;
    bitarray[122][4] <= 8'h0C;
    bitarray[122][5] <= 8'h26;
    bitarray[122][6] <= 8'h3F;
    bitarray[122][7] <= 8'h00;
    // ASCII 123 ({)
    bitarray[123][0] <= 8'h38;
    bitarray[123][1] <= 8'h0C;
    bitarray[123][2] <= 8'h0C;
    bitarray[123][3] <= 8'h07;
    bitarray[123][4] <= 8'h0C;
    bitarray[123][5] <= 8'h0C;
    bitarray[123][6] <= 8'h38;
    bitarray[123][7] <= 8'h00;
    // ASCII 124 (|)
    bitarray[124][0] <= 8'h18;
    bitarray[124][1] <= 8'h18;
    bitarray[124][2] <= 8'h18;
    bitarray[124][3] <= 8'h00;
    bitarray[124][4] <= 8'h18;
    bitarray[124][5] <= 8'h18;
    bitarray[124][6] <= 8'h18;
    bitarray[124][7] <= 8'h00;
    // ASCII 125 (})
    bitarray[125][0] <= 8'h07;
    bitarray[125][1] <= 8'h0C;
    bitarray[125][2] <= 8'h0C;
    bitarray[125][3] <= 8'h38;
    bitarray[125][4] <= 8'h0C;
    bitarray[125][5] <= 8'h0C;
    bitarray[125][6] <= 8'h07;
    bitarray[125][7] <= 8'h00;
    // ASCII 126 (~)
    bitarray[126][0] <= 8'h6E;
    bitarray[126][1] <= 8'h3B;
    bitarray[126][2] <= 8'h00;
    bitarray[126][3] <= 8'h00;
    bitarray[126][4] <= 8'h00;
    bitarray[126][5] <= 8'h00;
    bitarray[126][6] <= 8'h00;
    bitarray[126][7] <= 8'h00;
    // ASCII 127
    bitarray[127][0] <= 8'h00;
    bitarray[127][1] <= 8'h00;
    bitarray[127][2] <= 8'h00;
    bitarray[127][3] <= 8'h00;
    bitarray[127][4] <= 8'h00;
    bitarray[127][5] <= 8'h00;
    bitarray[127][6] <= 8'h00;
    bitarray[127][7] <= 8'h00;
  end
endmodule

module RegisterToPixel(register, line, column, pixel);
  input [15:0] register;
  input [2:0] line;
  input [4:0] column;
  output pixel;

  reg [7:0] character;

  always @(register, line, column, pixel)
  begin
    case (column[4:3])
      2'b00: character = register[15:12] + 7'h30;
      2'b01: character = register[11:8]  + 7'h30;
      2'b10: character = register[7:4]   + 7'h30;
      2'b11: character = register[3:0]   + 7'h30;
    endcase
  end

  wire [7:0] bits;

  CharacterToPixel numbers(.character(character),
                       .line(line),
                       .bits(bits));

  assign pixel = bits[column[2:0]];
endmodule

`endif
