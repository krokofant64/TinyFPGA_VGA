`include "K16Cpu.v"
`include "K16Video.v"
`include "K16Ram.v"
`include "K16Rom.v"
`include "K16Io.v"

module K16Computer(clk_16,
            vga_h_sync,
            vga_v_sync,
            vga_R,
            vga_G,
            vga_B,
            io_led0,
            io_led1,
            io_led2,
            io_led3,
            io_clk,
            io_addr0,
            io_addr1,
            io_addr2,
            sw_col4,
            sw_col3,
            sw_col2,
            sw_col1,
            sw_reg3,
            sw_reg2,
            sw_reg1,
            sound,
            statusR,
            statusG,
            statusB);

  input clk_16;
  output vga_h_sync;
  output vga_v_sync;
  output vga_R;
  output vga_G;
  output vga_B;
  output io_led0;
  output io_led1;
  output io_led2;
  output io_led3;
  output io_clk;
  output io_addr0;
  output io_addr1;
  output io_addr2;
  input sw_col4;
  input sw_col3;
  input sw_col2;
  input sw_col1;
  input sw_reg3;
  input sw_reg2;
  input sw_reg1;
  output sound;
  output statusR;
  output statusG;
  output statusB;

  reg  [10:0] frame_buffer_waddr_bus;
  wire [10:0] frame_buffer_raddr_bus;
  reg  [15:0] frame_buffer_din_bus;
  wire [15:0] frame_buffer_dout_bus;
  reg         frame_buffer_write;

  wire [15:0] cpu_addr_bus;
  wire [15:0] cpu_dout_bus;
  reg  [15:0] cpu_din_bus;
  wire        cpu_write;

  reg  [11:0] ram_addr_bus;
  wire [15:0] ram_dout_bus;
  reg  [15:0] ram_din_bus;
  reg         ram_write;

  reg  [8:0]  rom_addr_bus;
  wire [15:0] rom_dout_bus;

  reg  [2:0]  io_addr_bus;
  wire [15:0] io_dout_bus;
  reg  [15:0] io_din_bus;
  reg         io_write;
  wire stop;
  wire reset;
  wire interrupt;
  wire hold;
  wire busy;

  wire locked, clk;

  SB_PLL40_CORE #(
                  .FEEDBACK_PATH("SIMPLE"),
                  .DIVR(4'b0000),         // DIVR =  0
                  .DIVF(7'b0110001),      // DIVF = 49
                  .DIVQ(3'b101),          // DIVQ =  5
                  .FILTER_RANGE(3'b001)   // FILTER_RANGE = 1
                 ) uut (
                  .LOCK(locked),
                  .RESETB(1'b1),
                  .BYPASS(1'b0),
                  .REFERENCECLK(clk_16),
                  .PLLOUTCORE(clk)
                 );

  K16Video video(
    .clk(clk),
    .reset(reset),
    .interrupt(interrupt),
    .hsync(vga_h_sync),
    .vsync(vga_v_sync),
    .vga_R(vga_R),
    .vga_G(vga_G),
    .vga_B(vga_B),
    .frame_buffer_addr(frame_buffer_raddr_bus),
    .want_read_frame_buffer(hold),
    .frame_buffer_data(frame_buffer_dout_bus));

  K16DualPortRam frame_buffer(
    .din(frame_buffer_din_bus),
    .write_en(frame_buffer_write),
    .waddr(frame_buffer_waddr_bus),
    .wclk(clk),
    .raddr(frame_buffer_raddr_bus),
    .rclk(clk),
    .dout(frame_buffer_dout_bus));

  K16SinglePortRam #(12) ram(
    .din(ram_din_bus),
    .addr(ram_addr_bus),
    .write_en(ram_write),
    .clk(clk),
    .dout(ram_dout_bus));

  K16Rom rom(
    .addr(rom_addr_bus),
    .clk(clk),
    .dout(rom_dout_bus)
    );

  K16Io io(
    .din(io_din_bus),
    .addr(io_addr_bus),
    .write_en(io_write),
    .clk(clk),
    .dout(io_dout_bus),
    .stop(stop),
    .reset(reset),
    .io_leds({io_led3, io_led2, io_led1, io_led0}),
    .io_clk(io_clk),
    .io_addr({io_addr2, io_addr1, io_addr0}),
    .io_switches({sw_col4, sw_col3, sw_col2, sw_col1}),
    .io_reg_switches({sw_reg3, sw_reg2, sw_reg1}),
    .sound(sound));

  K16Cpu cpu(
    .clk(clk),
    .reset(reset),
    .stop(stop),
    .interrupt(interrupt),
    .hold(hold),
    .busy(busy),
    .address(cpu_addr_bus),
    .data_in(cpu_din_bus),
    .data_out(cpu_dout_bus),
    .write(cpu_write),
    .statusR(statusR),
    .statusG(statusG),
    .statusB(statusB));

  always @(*)
    begin
      casez (cpu_addr_bus)
        16'b0000????????????: // RAM 0000 - 0FFF
          begin
            ram_write <= cpu_write;
            frame_buffer_write <= 0;
            io_write <= 0;

            ram_addr_bus <= cpu_addr_bus[11:0];
            frame_buffer_waddr_bus <= 0;
            io_addr_bus <= 0;
            rom_addr_bus <= 0;

            cpu_din_bus <= ram_dout_bus;
            ram_din_bus <= cpu_dout_bus;
            frame_buffer_din_bus <= 0;
            io_din_bus <= 0;
          end
        16'b10000???????????: // Frame buffer 8000 - 87FF
          begin
            ram_write <= 0;
            frame_buffer_write <= cpu_write;
            io_write <= 0;

            ram_addr_bus <= 0;
            frame_buffer_waddr_bus <= cpu_addr_bus[10:0];
            io_addr_bus <= 0;
            rom_addr_bus <= 0;

            cpu_din_bus <= 0;
            ram_din_bus <= 0;
            frame_buffer_din_bus <= cpu_dout_bus;
            io_din_bus <= 0;
          end
          16'b1111000?????????: // ROM F000 - F1FF
            begin
              ram_write <= 0;
              frame_buffer_write <= 0;
              io_write <= 0;

              ram_addr_bus <= 0;
              frame_buffer_waddr_bus <= 0;
              io_addr_bus <= 0;
              rom_addr_bus <= cpu_addr_bus[8:0];

              cpu_din_bus <= rom_dout_bus;
              ram_din_bus <= 0;
              frame_buffer_din_bus <= 0;
              io_din_bus <= 0;
            end
        16'b1111111111111???: // IO FFF8 - FFFF
          begin
            ram_write <= 0;
            frame_buffer_write <= 0;
            io_write <= cpu_write;

            ram_addr_bus <= 0;
            frame_buffer_waddr_bus <= 0;
            io_addr_bus <= cpu_addr_bus[2:0];
            rom_addr_bus <= 0;

            cpu_din_bus <= io_dout_bus;
            ram_din_bus <= 0;
            frame_buffer_din_bus <= 0;
            io_din_bus <= cpu_dout_bus;
          end
        default:
          begin
            ram_write <= 0;
            frame_buffer_write <= 0;
            io_write <= 0;

            ram_addr_bus <= 0;
            frame_buffer_waddr_bus <= 0;
            io_addr_bus <= 0;
            rom_addr_bus <= 0;

            cpu_din_bus <= 16'h9FFF;
            ram_din_bus <= 0;
            frame_buffer_din_bus <= 0;
            io_din_bus <= 0;
          end
      endcase
    end

endmodule
