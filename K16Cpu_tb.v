`include "K16Cpu.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

`define DISPLAY_PANEL $display("ADDR_SWITCHES: %04X, CTRL_SWITCHES: %04X, ADDR_LEDS: %04X, DATA_LEDS: %04X", ram[`ADDR_SWITCHES], ram[`CTRL_SWITCHES], ram[`ADDR_LEDS], ram[`DATA_LEDS]);
module test2();

reg         clk;
reg         reset;
reg         stop;
wire        hold;
wire        busy;
wire [15:0] address;
reg [15:0]  data_in;
wire [15:0] data_out;
wire        write;

always #1 clk = ~clk;

K16Cpu cpu(
  .clk(clk),
  .reset(reset),
  .stop(stop),
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

//  ram[0]  = 16'hC38B;
//  ram[1]  = 16'hCB8B;
//  ram[2]  = 16'h6600;
//  ram[3]  = 16'h6E10;
//  ram[4]  = 16'h2900;
//  ram[5]  = 16'h4781;
//  ram[6]  = 16'h0480;
//  ram[7]  = 16'h2480;
//  ram[8]  = 16'h2903;
//  ram[9]  = 16'h0D8F;
//  ram[10] = 16'h4FFA;
//  ram[11] = 16'h9FFF;

//  ram[12] = 16'h002A;
//  ram[13] = 16'h00F3;

// ram[0] = 16'hC383;
// ram[1] = 16'h000C;
// ram[2] = 16'hE381;
// ram[3] = 16'h9FFF;
// ram[4] = 16'h000A;

/*
ram[0] = 16'h7A10;
ram[1] = 16'hC386;
ram[2] = 16'hC786;
ram[3] = 16'hBC02;
ram[4] = 16'hEB85;
ram[5] = 16'h9FFF;
ram[6] = 16'h0810;
ram[7] = 16'h3C0D;
ram[8] = 16'h000A;
ram[9] = 16'h000D;

*/
ram[0]  = 16'h6B80;
ram[1]  = 16'h6704;
ram[2]  = 16'h6F01;
ram[3]  = 16'h120C;
ram[4]  = 16'h120C;
ram[5]  = 16'h120C;
ram[6]  = 16'hE500;
ram[7]  = 16'h04B0;
ram[8]  = 16'h090C;
ram[9]  = 16'h6980;
ram[10] = 16'h6504;
ram[11] = 16'h9FF7;

ram[`ADDR_SWITCHES] = 16'h0000;
ram[`CTRL_SWITCHES] = 16'h0000;
ram[`ADDR_LEDS] = 16'h0000;
ram[`DATA_LEDS] = 16'h0000;


  $monitor(".  clk=%b,reset=%b,hold=%b,busy=%b,address=%04X,data_in=%04X,data_out=%04X,write=%b,ADDR_SWITCHES=%04X,CTRL_SWITCHES=%04X,ADDR_LEDS=%04X,DATA_LEDS=%04X",clk,reset,hold,busy,address,data_in,data_out,write,ram[`ADDR_SWITCHES],ram[`CTRL_SWITCHES],ram[`ADDR_LEDS],ram[`DATA_LEDS]);

  // initialize testbench variables
  clk = 1;
  reset = 1;
  repeat (5) @(posedge clk);
  reset = 0;

  #1
  ram[`ADDR_SWITCHES] = 16'h0000;
  ram[`CTRL_SWITCHES] = `START;
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  clk = 0;
//  $display("Start - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `INST_STEP;
  $display("Inst_step - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);

  ram[`CTRL_SWITCHES] = `INST_STEP;
  $display("Inst_step - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `CONTINUE;
  $display("Continue - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);

  #10
  repeat (50) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  stop = 1;
  repeat (5) @(posedge clk);
  stop = 0;
  ram[`ADDR_SWITCHES] = 16'h0000;

  ram[`CTRL_SWITCHES] = `EXAMINE;
  $display("Examine - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `EXAMINE_NEXT;
  $display("Examine_next - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);

  ram[`ADDR_SWITCHES] = 16'h0010;
  ram[`CTRL_SWITCHES] = `EXAMINE;
  $display("Examine - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);
  ram[`ADDR_SWITCHES] = 16'h1234;
  ram[`CTRL_SWITCHES] = `DEPOSIT;
  $display("Deposit - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);
  ram[`ADDR_SWITCHES] = 16'habcd;
  ram[`CTRL_SWITCHES] = `DEPOSIT_NEXT;
  $display("Deposit_next - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);
  ram[`REG_SWITCHES] = 2;
  ram[`CTRL_SWITCHES] = `EXAMINE_REGISTER;
  $display("Examine_register - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (5) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (5) @(posedge clk);
  ram[`REG_SWITCHES] = 3;
  ram[`ADDR_SWITCHES] = 16'h5678;
  ram[`CTRL_SWITCHES] = `DEPOSIT_REGISTER;
  $display("Deposit_register - addr: %04x, reg: %04x", ram[`ADDR_SWITCHES], ram[`REG_SWITCHES]);
  repeat (10) @(posedge clk);
  ram[`CTRL_SWITCHES] = `NONE;
  repeat (10) @(posedge clk);

  $finish;

end
endmodule
