`ifndef K16IO_V
`define K16IO_V

module K16Io(din, addr, write_en, clk, dout, stop, reset, io_leds, io_clk, io_addr, io_switches, io_reg_switches, sound);
  input [2:0]       addr;
  input [15:0]      din;
  input             write_en;
  input             clk;
  output reg [15:0] dout;
  output reg        stop;
  output reg        reset;
  output reg [3:0]  io_leds;
  output reg        io_clk;
  output reg [2:0]  io_addr;
  input  [3:0]      io_switches;
  input  [2:0]      io_reg_switches;
  output reg        sound;

  reg [15:0] addr_leds;
  reg [15:0] data_leds;
  reg [15:0] addr_switches;
  reg [15:0] ctrl_switches;
  reg [2:0]  reg_switches;
  reg [31:0] counter;

 localparam DIVISOR = 25000000 / 50;
  always @(posedge clk)
    begin
       counter <= counter + 32'd1;
       if (counter >= (DIVISOR - 1))
         counter <= 32'd0;
       io_clk <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
    end

  always @(posedge io_clk)
    begin
      io_addr <= io_addr + 1;
    end

  always @(posedge io_clk)
    begin
      case (io_addr)
        0: io_leds <= addr_leds[3:0];
        1: io_leds <= addr_leds[7:4];
        2: io_leds <= addr_leds[11:8];
        3: io_leds <= addr_leds[15:12];
        4: io_leds <= data_leds[3:0];
        5: io_leds <= data_leds[7:4];
        6: io_leds <= data_leds[11:8];
        7: io_leds <= data_leds[15:12];
      endcase
    end

  always @(posedge io_clk)
    begin
      case (io_addr)
        0: addr_switches[3:0]   <= io_switches;
        1: addr_switches[7:4]   <= io_switches;
        2: addr_switches[11:8]  <= io_switches;
        3: addr_switches[15:12] <= io_switches;
        4: ctrl_switches[3:0]   <= io_switches;
        5: ctrl_switches[7:4]   <= io_switches;
        6: ctrl_switches[11:8]  <= io_switches;
        7: ctrl_switches[15:12] <= io_switches;
      endcase
    end

always @(posedge io_clk)
  begin
    stop <= ctrl_switches[0];
    reset <= ctrl_switches[1];
    sound <= 0;
  end

 always @(posedge io_clk)
   begin
     reg_switches <= io_reg_switches;
   end

  always @(posedge clk)
    begin
      case (addr)
        3'h0: // ADDR_SWITCHES
          begin
            dout <= addr_switches;
          end
        3'h1: // CTRL_SWITCHES
          begin
            dout <= ctrl_switches;
          end
        3'h2: // ADDR_LEDS
          begin
            if (write_en)
              addr_leds <= din;
            dout <= addr_leds;
          end
        3'h3: // DATA_LEDS
          begin
            if (write_en)
              data_leds <= din;
            dout <= data_leds;
          end
        3'h4: // REG_SWITCHES
          begin
            dout <= { 13'b0, reg_switches};
          end
        3'h5: // Counter HI
          begin
            dout <= counter[31:16];
          end
        3'h6: // Counter low
          begin
            dout <= counter[15:0];
          end
        3'h7:
          begin
            dout <= 16'hEAEA;
          end
      endcase
    end
endmodule

`endif
