`ifndef K16RAM_V
`define K16RAM_V

module K16SinglePortRam (din, addr, write_en, clk, dout);// 4096x16
  parameter addr_width = 12;
  parameter data_width = 16;
  input [addr_width-1:0] addr;
  input [data_width-1:0] din;
  input write_en, clk;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout; // Register for output.
  reg [data_width-1:0] mem [(1<<addr_width)-1:0];
  always @(posedge clk)
    begin
      if (write_en)
        mem[(addr)] <= din;
      dout <= mem[addr]; // Output register controlled by clock.
    end
  // The default program is the example "C: ROM library with custom characters"
  // from K16ExampleCode.html (Generate Verilog in K16.html). The CPU waits for
  // START, so the start screen stays until then. Another program goes here the
  // same way, or is entered on the front panel.
  initial
    begin
    mem[0] = 16'h7afe;
    mem[1] = 16'h790f;
    mem[2] = 16'hbc6e;
    mem[3] = 16'h9fff;
    mem[4] = 16'h280c;
    mem[5] = 16'h0b08;
    mem[6] = 16'h6e05;
    mem[7] = 16'h1b32;
    mem[8] = 16'h6200;
    mem[9] = 16'he100;
    mem[10] = 16'h9c5b;
    mem[11] = 16'hc100;
    mem[12] = 16'h2001;
    mem[13] = 16'h2001;
    mem[14] = 16'h0408;
    mem[15] = 16'h60a8;
    mem[16] = 16'h6101;
    mem[17] = 16'h0010;
    mem[18] = 16'he17e;
    mem[19] = 16'h6200;
    mem[20] = 16'he17f;
    mem[21] = 16'h9c45;
    mem[22] = 16'h6202;
    mem[23] = 16'hc57f;
    mem[24] = 16'hbd45;
    mem[25] = 16'h660f;
    mem[26] = 16'h0012;
    mem[27] = 16'he17d;
    mem[28] = 16'h6202;
    mem[29] = 16'hc500;
    mem[30] = 16'hbd3f;
    mem[31] = 16'h660f;
    mem[32] = 16'h0012;
    mem[33] = 16'he17c;
    mem[34] = 16'hc17f;
    mem[35] = 16'h6604;
    mem[36] = 16'hbd3c;
    mem[37] = 16'h0088;
    mem[38] = 16'h0008;
    mem[39] = 16'h4f88;
    mem[40] = 16'hc17f;
    mem[41] = 16'h6604;
    mem[42] = 16'hbd36;
    mem[43] = 16'h0408;
    mem[44] = 16'hc17e;
    mem[45] = 16'h0010;
    mem[46] = 16'h6600;
    mem[47] = 16'he400;
    mem[48] = 16'hc17d;
    mem[49] = 16'hc57d;
    mem[50] = 16'hbd2b;
    mem[51] = 16'h200c;
    mem[52] = 16'hc17c;
    mem[53] = 16'hc57c;
    mem[54] = 16'hbd27;
    mem[55] = 16'h0408;
    mem[56] = 16'h200d;
    mem[57] = 16'h0010;
    mem[58] = 16'h66e1;
    mem[59] = 16'h6f80;
    mem[60] = 16'h0036;
    mem[61] = 16'h04b6;
    mem[62] = 16'h001e;
    mem[63] = 16'h4798;
    mem[64] = 16'hc17f;
    mem[65] = 16'h6604;
    mem[66] = 16'hbd1e;
    mem[67] = 16'h0408;
    mem[68] = 16'hc17e;
    mem[69] = 16'h0010;
    mem[70] = 16'h200c;
    mem[71] = 16'hc000;
    mem[72] = 16'h200c;
    mem[73] = 16'hc17f;
    mem[74] = 16'h6604;
    mem[75] = 16'hbd15;
    mem[76] = 16'h0088;
    mem[77] = 16'h0408;
    mem[78] = 16'h6204;
    mem[79] = 16'hbd0e;
    mem[80] = 16'h0408;
    mem[81] = 16'h620e;
    mem[82] = 16'hbd11;
    mem[83] = 16'h0408;
    mem[84] = 16'h200d;
    mem[85] = 16'h0015;
    mem[86] = 16'h2c0d;
    mem[87] = 16'he180;
    mem[88] = 16'hc17f;
    mem[89] = 16'h000c;
    mem[90] = 16'he17f;
    mem[91] = 16'hc17f;
    mem[92] = 16'h6610;
    mem[93] = 16'h6f80;
    mem[94] = 16'h0036;
    mem[95] = 16'h04b6;
    mem[96] = 16'h001e;
    mem[97] = 16'h4781;
    mem[98] = 16'h9fb3;
    mem[99] = 16'hc100;
    mem[100] = 16'h000c;
    mem[101] = 16'he100;
    mem[102] = 16'hc100;
    mem[103] = 16'h6610;
    mem[104] = 16'h6f80;
    mem[105] = 16'h0036;
    mem[106] = 16'h04b6;
    mem[107] = 16'h001e;
    mem[108] = 16'h4781;
    mem[109] = 16'h9f9d;
    mem[110] = 16'h1908;
    mem[111] = 16'h280d;
    mem[112] = 16'h3c0d;
    mem[113] = 16'h280c;
    mem[114] = 16'h0b08;
    mem[115] = 16'h6e05;
    mem[116] = 16'h1b32;
    mem[117] = 16'h6214;
    mem[118] = 16'he100;
    mem[119] = 16'h6264;
    mem[120] = 16'he17f;
    mem[121] = 16'h6202;
    mem[122] = 16'he17e;
    mem[123] = 16'h6201;
    mem[124] = 16'he17d;
    mem[125] = 16'h6220;
    mem[126] = 16'h670f;
    mem[127] = 16'hbcea;
    mem[128] = 16'h60a0;
    mem[129] = 16'h6101;
    mem[130] = 16'h200c;
    mem[131] = 16'h6280;
    mem[132] = 16'h240d;
    mem[133] = 16'hbcf6;
    mem[134] = 16'h60a4;
    mem[135] = 16'h6101;
    mem[136] = 16'h200c;
    mem[137] = 16'h6281;
    mem[138] = 16'h240d;
    mem[139] = 16'hbcf0;
    mem[140] = 16'h60e9;
    mem[141] = 16'h6101;
    mem[142] = 16'h200c;
    mem[143] = 16'h6208;
    mem[144] = 16'h6601;
    mem[145] = 16'hbce4;
    mem[146] = 16'h1b0c;
    mem[147] = 16'h630c;
    mem[148] = 16'hbcd8;
    mem[149] = 16'h6280;
    mem[150] = 16'hbcdc;
    mem[151] = 16'h630e;
    mem[152] = 16'hbcd4;
    mem[153] = 16'h6281;
    mem[154] = 16'hbcd8;
    mem[155] = 16'h630f;
    mem[156] = 16'hbcd0;
    mem[157] = 16'h60fa;
    mem[158] = 16'h6101;
    mem[159] = 16'h200c;
    mem[160] = 16'h6201;
    mem[161] = 16'h6603;
    mem[162] = 16'hbcd3;
    mem[163] = 16'h1b0c;
    mem[164] = 16'h6200;
    mem[165] = 16'h200c;
    mem[166] = 16'h6230;
    mem[167] = 16'h200c;
    mem[168] = 16'h6250;
    mem[169] = 16'h200c;
    mem[170] = 16'h6200;
    mem[171] = 16'h660c;
    mem[172] = 16'hbcdb;
    mem[173] = 16'h1b0c;
    mem[174] = 16'h1b0c;
    mem[175] = 16'h1b0c;
    mem[176] = 16'h6207;
    mem[177] = 16'h200c;
    mem[178] = 16'h6230;
    mem[179] = 16'h200c;
    mem[180] = 16'h6250;
    mem[181] = 16'h200c;
    mem[182] = 16'h6200;
    mem[183] = 16'h660c;
    mem[184] = 16'hbccc;
    mem[185] = 16'h1b0c;
    mem[186] = 16'h1b0c;
    mem[187] = 16'h1b0c;
    mem[188] = 16'h6203;
    mem[189] = 16'h200c;
    mem[190] = 16'h6212;
    mem[191] = 16'h200c;
    mem[192] = 16'h621e;
    mem[193] = 16'h200c;
    mem[194] = 16'h6228;
    mem[195] = 16'h6624;
    mem[196] = 16'hbcc6;
    mem[197] = 16'h1b0c;
    mem[198] = 16'h1b0c;
    mem[199] = 16'h1b0c;
    mem[200] = 16'h6202;
    mem[201] = 16'h200c;
    mem[202] = 16'h6214;
    mem[203] = 16'h200c;
    mem[204] = 16'h6246;
    mem[205] = 16'h200c;
    mem[206] = 16'h620a;
    mem[207] = 16'h6632;
    mem[208] = 16'hbcb1;
    mem[209] = 16'h1b0c;
    mem[210] = 16'h1b0c;
    mem[211] = 16'h1b0c;
    mem[212] = 16'h6200;
    mem[213] = 16'he17c;
    mem[214] = 16'h9c17;
    mem[215] = 16'h6205;
    mem[216] = 16'h200c;
    mem[217] = 16'hbcc3;
    mem[218] = 16'h662e;
    mem[219] = 16'hbc8b;
    mem[220] = 16'h0088;
    mem[221] = 16'h0408;
    mem[222] = 16'h620d;
    mem[223] = 16'h0010;
    mem[224] = 16'h200c;
    mem[225] = 16'hbcbb;
    mem[226] = 16'h664e;
    mem[227] = 16'hbc83;
    mem[228] = 16'h0088;
    mem[229] = 16'h0408;
    mem[230] = 16'h6201;
    mem[231] = 16'h0010;
    mem[232] = 16'h240d;
    mem[233] = 16'hbc95;
    mem[234] = 16'h1b0c;
    mem[235] = 16'hc17c;
    mem[236] = 16'h000c;
    mem[237] = 16'he17c;
    mem[238] = 16'hc17c;
    mem[239] = 16'h6664;
    mem[240] = 16'h6f80;
    mem[241] = 16'h0036;
    mem[242] = 16'h04b6;
    mem[243] = 16'h001e;
    mem[244] = 16'h43e2;
    mem[245] = 16'hbf0e;
    mem[246] = 16'h60a8;
    mem[247] = 16'h6101;
    mem[248] = 16'h200c;
    mem[249] = 16'h6200;
    mem[250] = 16'h240d;
    mem[251] = 16'hbc92;
    mem[252] = 16'h6200;
    mem[253] = 16'hbc96;
    mem[254] = 16'hbc9b;
    mem[255] = 16'h6200;
    mem[256] = 16'hbc96;
    mem[257] = 16'hc100;
    mem[258] = 16'hc57e;
    mem[259] = 16'h0010;
    mem[260] = 16'he100;
    mem[261] = 16'hc17f;
    mem[262] = 16'hc57d;
    mem[263] = 16'h0010;
    mem[264] = 16'he17f;
    mem[265] = 16'hc100;
    mem[266] = 16'h0008;
    mem[267] = 16'h5388;
    mem[268] = 16'hc100;
    mem[269] = 16'h6630;
    mem[270] = 16'h6501;
    mem[271] = 16'h6f80;
    mem[272] = 16'h0036;
    mem[273] = 16'h04b6;
    mem[274] = 16'h008e;
    mem[275] = 16'h4795;
    mem[276] = 16'hc17e;
    mem[277] = 16'h0007;
    mem[278] = 16'h000c;
    mem[279] = 16'he17e;
    mem[280] = 16'h6ce8;
    mem[281] = 16'h6d01;
    mem[282] = 16'hc180;
    mem[283] = 16'h000c;
    mem[284] = 16'h6ce8;
    mem[285] = 16'h6d01;
    mem[286] = 16'he180;
    mem[287] = 16'h6ce8;
    mem[288] = 16'h6d01;
    mem[289] = 16'hc180;
    mem[290] = 16'h660c;
    mem[291] = 16'hbc43;
    mem[292] = 16'h0088;
    mem[293] = 16'h0408;
    mem[294] = 16'h623c;
    mem[295] = 16'h0010;
    mem[296] = 16'hbc6e;
    mem[297] = 16'hc17f;
    mem[298] = 16'h6630;
    mem[299] = 16'h6f80;
    mem[300] = 16'h0036;
    mem[301] = 16'h04b6;
    mem[302] = 16'h001e;
    mem[303] = 16'h4387;
    mem[304] = 16'hc17f;
    mem[305] = 16'h66e0;
    mem[306] = 16'h6f80;
    mem[307] = 16'h0036;
    mem[308] = 16'h04b6;
    mem[309] = 16'h008e;
    mem[310] = 16'h4795;
    mem[311] = 16'hc17d;
    mem[312] = 16'h0007;
    mem[313] = 16'h000c;
    mem[314] = 16'he17d;
    mem[315] = 16'h6ce8;
    mem[316] = 16'h6d01;
    mem[317] = 16'hc180;
    mem[318] = 16'h000c;
    mem[319] = 16'h6ce8;
    mem[320] = 16'h6d01;
    mem[321] = 16'he180;
    mem[322] = 16'h6ce8;
    mem[323] = 16'h6d01;
    mem[324] = 16'hc180;
    mem[325] = 16'h660c;
    mem[326] = 16'hbc20;
    mem[327] = 16'h0088;
    mem[328] = 16'h0408;
    mem[329] = 16'h6248;
    mem[330] = 16'h0010;
    mem[331] = 16'hbc4b;
    mem[332] = 16'hc17f;
    mem[333] = 16'h200c;
    mem[334] = 16'h6200;
    mem[335] = 16'hc500;
    mem[336] = 16'hbc40;
    mem[337] = 16'h1b0c;
    mem[338] = 16'h620a;
    mem[339] = 16'h6603;
    mem[340] = 16'hbc1b;
    mem[341] = 16'h6ce8;
    mem[342] = 16'h6d01;
    mem[343] = 16'hc180;
    mem[344] = 16'hbc20;
    mem[345] = 16'h9fa4;
    mem[346] = 16'h6200;
    mem[347] = 16'h1908;
    mem[348] = 16'h280d;
    mem[349] = 16'h3c0d;
    mem[350] = 16'h6ce1;
    mem[351] = 16'h6df1;
    mem[352] = 16'h8c00;
    mem[353] = 16'h6cf9;
    mem[354] = 16'h6df1;
    mem[355] = 16'h8c00;
    mem[356] = 16'h6c10;
    mem[357] = 16'h6df2;
    mem[358] = 16'h8c00;
    mem[359] = 16'h6cea;
    mem[360] = 16'h6df1;
    mem[361] = 16'h8c00;
    mem[362] = 16'h6cc2;
    mem[363] = 16'h6df2;
    mem[364] = 16'h8c00;
    mem[365] = 16'h6ccd;
    mem[366] = 16'h6df2;
    mem[367] = 16'h8c00;
    mem[368] = 16'h6cd2;
    mem[369] = 16'h6df2;
    mem[370] = 16'h8c00;
    mem[371] = 16'h6cd6;
    mem[372] = 16'h6df2;
    mem[373] = 16'h8c00;
    mem[374] = 16'h6cf6;
    mem[375] = 16'h6df2;
    mem[376] = 16'h8c00;
    mem[377] = 16'h6c04;
    mem[378] = 16'h6df3;
    mem[379] = 16'h8c00;
    mem[380] = 16'h6c74;
    mem[381] = 16'h6df3;
    mem[382] = 16'h8c00;
    mem[383] = 16'h6c9a;
    mem[384] = 16'h6df0;
    mem[385] = 16'h8c00;
    mem[386] = 16'h6cc9;
    mem[387] = 16'h6df0;
    mem[388] = 16'h8c00;
    mem[389] = 16'h6c15;
    mem[390] = 16'h6df1;
    mem[391] = 16'h8c00;
    mem[392] = 16'h6c2f;
    mem[393] = 16'h6df1;
    mem[394] = 16'h8c00;
    mem[395] = 16'h6c3d;
    mem[396] = 16'h6df1;
    mem[397] = 16'h8c00;
    mem[398] = 16'h6c92;
    mem[399] = 16'h6df1;
    mem[400] = 16'h8c00;
    mem[401] = 16'h6c9c;
    mem[402] = 16'h6df1;
    mem[403] = 16'h8c00;
    mem[404] = 16'h6ca5;
    mem[405] = 16'h6df1;
    mem[406] = 16'h8c00;
    mem[407] = 16'h6c00;
    mem[408] = 16'h6df0;
    mem[409] = 16'h8c00;
    mem[410] = 16'h6c6e;
    mem[411] = 16'h6df0;
    mem[412] = 16'h8c00;
    mem[413] = 16'h6c45;
    mem[414] = 16'h6df0;
    mem[415] = 16'h8c00;
    mem[416] = 16'hff66;
    mem[417] = 16'hffff;
    mem[418] = 16'h3c7e;
    mem[419] = 16'h0018;
    mem[420] = 16'h423c;
    mem[421] = 16'h81a5;
    mem[422] = 16'h99a5;
    mem[423] = 16'h3c42;
    mem[424] = 16'h0000;
    mem[425] = 16'h0000;
    mem[426] = 16'h0000;
    mem[427] = 16'h0000;
    mem[428] = 16'h0000;
    mem[429] = 16'h0000;
    mem[430] = 16'h0000;
    mem[431] = 16'h0000;
    mem[432] = 16'h0000;
    mem[433] = 16'h0000;
    mem[434] = 16'h0000;
    mem[435] = 16'h0000;
    mem[436] = 16'h0000;
    mem[437] = 16'h0000;
    mem[438] = 16'h0000;
    mem[439] = 16'h0000;
    mem[440] = 16'h0000;
    mem[441] = 16'h0000;
    mem[442] = 16'h0000;
    mem[443] = 16'h0000;
    mem[444] = 16'h0000;
    mem[445] = 16'h0000;
    mem[446] = 16'h0000;
    mem[447] = 16'h0000;
    mem[448] = 16'h0000;
    mem[449] = 16'h0000;
    mem[450] = 16'h0000;
    mem[451] = 16'h0000;
    mem[452] = 16'h0000;
    mem[453] = 16'h0000;
    mem[454] = 16'h0000;
    mem[455] = 16'h0000;
    mem[456] = 16'h0000;
    mem[457] = 16'h0000;
    mem[458] = 16'h0000;
    mem[459] = 16'h0000;
    mem[460] = 16'h0000;
    mem[461] = 16'h0000;
    mem[462] = 16'h0000;
    mem[463] = 16'h0000;
    mem[464] = 16'h0000;
    mem[465] = 16'h0000;
    mem[466] = 16'h0000;
    mem[467] = 16'h0000;
    mem[468] = 16'h0000;
    mem[469] = 16'h0000;
    mem[470] = 16'h0000;
    mem[471] = 16'h0000;
    mem[472] = 16'h0000;
    mem[473] = 16'h0000;
    mem[474] = 16'h0000;
    mem[475] = 16'h0000;
    mem[476] = 16'h0000;
    mem[477] = 16'h0000;
    mem[478] = 16'h0000;
    mem[479] = 16'h0000;
    mem[480] = 16'h0000;
    mem[481] = 16'h0000;
    mem[482] = 16'h0000;
    mem[483] = 16'h0000;
    mem[484] = 16'h0000;
    mem[485] = 16'h0000;
    mem[486] = 16'h0000;
    mem[487] = 16'h0000;
    mem[488] = 16'h0000;
    mem[489] = 16'h004b;
    mem[490] = 16'h0031;
    mem[491] = 16'h0036;
    mem[492] = 16'h0020;
    mem[493] = 16'h0052;
    mem[494] = 16'h004f;
    mem[495] = 16'h004d;
    mem[496] = 16'h0020;
    mem[497] = 16'h006c;
    mem[498] = 16'h0069;
    mem[499] = 16'h0062;
    mem[500] = 16'h0072;
    mem[501] = 16'h0061;
    mem[502] = 16'h0072;
    mem[503] = 16'h0079;
    mem[504] = 16'h0020;
    mem[505] = 16'h0000;
    mem[506] = 16'h0042;
    mem[507] = 16'h006f;
    mem[508] = 16'h0075;
    mem[509] = 16'h006e;
    mem[510] = 16'h0063;
    mem[511] = 16'h0065;
    mem[512] = 16'h0073;
    mem[513] = 16'h003a;
    mem[514] = 16'h0000;
    end
endmodule

// Changeable characters 128 .. 255: 4 words per character, word k holds line
// 2 * k in bits 7 .. 0 and line 2 * k + 1 in bits 15 .. 8.
module K16CharacterRam(din, write_en, waddr, wclk, raddr, rclk, dout); // 512x16
  parameter addr_width = 9;
  parameter data_width = 16;
  input [addr_width-1:0] waddr, raddr;
  input [data_width-1:0] din;
  input write_en, wclk, rclk;
  output reg [data_width-1:0] dout;
  reg [data_width-1:0] mem [(1<<addr_width)-1:0];

  always @(posedge wclk) // Write memory.
    begin
      if (write_en)
        mem[waddr] <= din; // Using write address bus.
    end
  always @(posedge rclk) // Read memory.
    begin
      dout <= mem[raddr]; // Using read address bus.
    end

  // The start screen (tests\BuildBootScreen.ps1)
  initial
    begin
`include "K16BootChars.vh"
    end
endmodule

module K16FrameBufferRam(din, write_en, waddr, wclk, raddr, rclk, dout); // 2048x16
  parameter addr_width = 11;
  parameter data_width = 16;
  input [addr_width-1:0] waddr, raddr;
  input [data_width-1:0] din;
  input write_en, wclk, rclk;
  output reg [data_width-1:0] dout;
  reg [data_width-1:0] mem [(1<<addr_width)-1:0] ;

  always @(posedge wclk) // Write memory.
    begin
      if (write_en)
        mem[waddr] <= din; // Using write address bus.
    end
  always @(posedge rclk) // Read memory.
    begin
      dout <= mem[raddr]; // Using read address bus.
    end

  // The start screen (tests\BuildBootScreen.ps1). The rest of the memory, with the
  // sprite images and the variables of the ROM library, starts at 0.
  initial
    begin
`include "K16BootFrame.vh"
    end
endmodule

`endif
