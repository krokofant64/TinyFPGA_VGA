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
  output reg [2:0]  io_addr = 0;
  input  [3:0]      io_switches;
  input  [2:0]      io_reg_switches;
  output reg        sound = 0;

  reg [15:0] addr_leds = 0;
  reg [15:0] data_leds = 0;
  reg [15:0] addr_switches = 0;
  reg [15:0] ctrl_switches = 0;
  reg [2:0]  reg_switches = 0;
  reg [31:0] counter = 0;
  reg [15:0] sound_divisor = 0;
  reg [19:0] io_clck_counter = 0;
  reg [21:0] sound_counter = 0;

  localparam DIVISOR = 25000000 / 50;
  always @(posedge clk)
    begin
       counter <= counter + 1;
       io_clck_counter <= io_clck_counter + 20'd1;
       sound_counter <= sound_counter + 26'd1;
       if (io_clck_counter >= (DIVISOR - 1))
         io_clck_counter <= 32'd0;
       io_clk <= (io_clck_counter < DIVISOR / 2) ? 1'b1 : 1'b0;
       if (sound_divisor != 0 && sound_counter >= {sound_divisor, 5'b0})
         begin
           sound_counter <= 26'd0;
           sound = ~sound;
        end
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
        4: ctrl_switches[3:0]   <= ~io_switches;
        5: ctrl_switches[7:4]   <= ~io_switches;
        6: ctrl_switches[11:8]  <= ~io_switches;
        7: ctrl_switches[15:12] <= ~io_switches;
      endcase
    end

always @(posedge io_clk)
  begin
    stop <= ctrl_switches[2];
    reset <= ctrl_switches[3];
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
            $display("Read ADDR_SWITCHES");
            dout <= addr_switches;
          end
        3'h1: // CTRL_SWITCHES
          begin
            $display("Read CTRL_SWITCHES");
            if (ctrl_switches[0])
              begin
                dout <= `EXAMINE_REGISTER;
              end
            else if (ctrl_switches[1])
              begin
                dout <= `DEPOSIT_REGISTER;
              end
            else if (ctrl_switches[4])
              begin
                dout <= `CONTINUE;
              end
            else if (ctrl_switches[5])
              begin
                dout <= `START;
              end
            else if (ctrl_switches[6])
              begin
                dout <= `DEPOSIT_NEXT;
              end
            else if (ctrl_switches[7])
              begin
                dout <= `DEPOSIT;
              end
            else if (ctrl_switches[8])
              begin
                dout <= `EXAMINE_NEXT;
              end
            else if (ctrl_switches[9])
              begin
                dout <= `EXAMINE;
              end
            else if (ctrl_switches[10])
              begin
                dout <= `INST_STEP;
              end
            else
              begin
                dout <= `NONE;
              end
          end
        3'h2: // ADDR_LEDS
          begin
            $display("Read or write ADDR_LEDS");
            if (write_en)
              begin
                $display("Write ADDR_LEDS");
                addr_leds <= din;
              end;
            dout <= addr_leds;
          end
        3'h3: // DATA_LEDS
          begin
          $display("Read or write DATA_LEDS");
            if (write_en)
              begin
                $display("Write DATA_LEDS");
                data_leds <= din;
              end
            dout <= data_leds;
          end
        3'h4: // REG_SWITCHES
          begin
            $display("Read REG_SWITCHES");
            dout <= { 13'b0, reg_switches};
          end
        3'h5: // Counter HI
          begin
            $display("Read COUNTER_HI");
            dout <= counter[31:16];
          end
        3'h6: // Counter low
          begin
          $display("Read COUNTER_LO");
            dout <= counter[15:0];
          end
        3'h7:
          begin
            $display("Read SOUND_DIVISOR");
            if (write_en)
              begin
                $display("Write SOUND_DIVISOR");
                sound_divisor <= din;
              end;
            dout <= sound_divisor;
          end
      endcase
    end
endmodule

`endif
