`ifndef K16PSG_V
`define K16PSG_V

// K16Psg: a sound chip like the AY-3-8910 (programmable sound generator).
//
// Three square-wave tone channels, one noise generator, a mixer, 16 volume
// levels per channel, and one envelope generator. The 14 registers have the
// same numbers and bit widths as the AY's R0 .. R13 and are at
// 0xFFD0 .. 0xFFDD (addr = register number). R14 and R15 (the AY's I/O
// ports) are not there and read 0.
//
//   R0, R1   tone period A: fine (8 bits), coarse (4 bits)
//   R2, R3   tone period B
//   R4, R5   tone period C
//   R6       noise period (5 bits)
//   R7       mixer: bit 0..2 = 1: tone A, B, C off; bit 3..5 = 1: noise A, B, C off
//   R8..R10  volume A, B, C: bits 3..0 level, bit 4 = 1: level from the envelope
//   R11, R12 envelope period: fine, coarse
//   R13      envelope shape (bits 3..0: continue, attack, alternate, hold);
//            writing R13 restarts the envelope
//
// The chip runs at 1.7734 MHz like the AY in the ZX Spectrum 128: a phase
// accumulator makes the AY's internal tick (clock / 8 = 221.7 kHz) from the
// 25 MHz clock.
//   tone frequency     = 1773400 / (16 * period)
//   noise shift rate   = 1773400 / (16 * period)
//   envelope step rate = 1773400 / (16 * period), 16 steps per cycle
//
// level is the sum of the three channels (0 .. 765), for the DAC in K16Io.
// While reset is 1, all registers are 0 (mixer 0, volumes 0: silent) and the
// generators are as at power-up.

module K16Psg(clk, reset, addr, din, write_en, dout, level);
  input            clk;
  input            reset;           // RESET switch: all registers 0 (silent), generators as at power-up
  input      [3:0] addr;
  input      [7:0] din;
  input            write_en;
  output reg [7:0] dout = 0;
  output reg [9:0] level = 0;

  // Phase accumulator: 25 MHz * 581 / 65536 = 221.6 kHz (AY clock / 8)
  parameter TICK_INCREMENT = 16'd581;

  reg [7:0]  r0 = 0, r2 = 0, r4 = 0, r11 = 0, r12 = 0;
  reg [3:0]  r1 = 0, r3 = 0, r5 = 0, r13 = 0;
  reg [4:0]  r6 = 0, r8 = 0, r9 = 0, r10 = 0;
  reg [5:0]  r7 = 0;

  reg [15:0] phase = 0;
  reg        tick = 0;
  reg        half = 0;              // Noise and envelope count every 2nd tick

  reg [11:0] count_a = 0, count_b = 0, count_c = 0;
  reg        tone_a = 0, tone_b = 0, tone_c = 0;
  reg [4:0]  count_noise = 0;
  reg [16:0] lfsr = 17'd1;
  reg [15:0] count_env = 0;
  reg [3:0]  env_step = 4'd15;
  reg        env_attack = 0;
  reg        env_hold = 1;
  reg        env_alternate = 0;
  reg        env_holding = 1;

  // A period of 0 counts like 1
  wire [11:0] period_a     = {r1, r0} == 0 ? 12'd1 : {r1, r0};
  wire [11:0] period_b     = {r3, r2} == 0 ? 12'd1 : {r3, r2};
  wire [11:0] period_c     = {r5, r4} == 0 ? 12'd1 : {r5, r4};
  wire [4:0]  period_noise = r6 == 0 ? 5'd1 : r6;
  wire [15:0] period_env   = {r12, r11} == 0 ? 16'd1 : {r12, r11};

  wire [3:0]  env_volume = env_step ^ {4{env_attack}};

  // Logarithmic volume (about 3 dB per step, measured AY levels * 255)
  function [7:0] volume;
    input [3:0] theLevel;
    case (theLevel)
      4'd0:  volume = 8'd0;
      4'd1:  volume = 8'd3;
      4'd2:  volume = 8'd4;
      4'd3:  volume = 8'd6;
      4'd4:  volume = 8'd8;
      4'd5:  volume = 8'd12;
      4'd6:  volume = 8'd17;
      4'd7:  volume = 8'd26;
      4'd8:  volume = 8'd32;
      4'd9:  volume = 8'd51;
      4'd10: volume = 8'd71;
      4'd11: volume = 8'd90;
      4'd12: volume = 8'd120;
      4'd13: volume = 8'd153;
      4'd14: volume = 8'd194;
      4'd15: volume = 8'd255;
    endcase
  endfunction

  // Output of a channel: (tone or tone off) and (noise or noise off)
  wire on_a = (tone_a | r7[0]) & (lfsr[0] | r7[3]);
  wire on_b = (tone_b | r7[1]) & (lfsr[0] | r7[4]);
  wire on_c = (tone_c | r7[2]) & (lfsr[0] | r7[5]);

  wire [7:0] out_a = on_a ? volume(r8[4]  ? env_volume : r8[3:0])  : 8'd0;
  wire [7:0] out_b = on_b ? volume(r9[4]  ? env_volume : r9[3:0])  : 8'd0;
  wire [7:0] out_c = on_c ? volume(r10[4] ? env_volume : r10[3:0]) : 8'd0;

  // ------------------------------------------------------------ The tick

  always @(posedge clk)
    begin
      {tick, phase} <= {1'b0, phase} + {1'b0, TICK_INCREMENT};
      level <= {2'b0, out_a} + {2'b0, out_b} + {2'b0, out_c};
    end

  // ------------------------------------------------------------ Generators

  always @(posedge clk)
    begin
      if (tick)
        begin
          half <= ~half;

          if (count_a >= period_a - 12'd1) begin count_a <= 0; tone_a <= ~tone_a; end
          else count_a <= count_a + 12'd1;
          if (count_b >= period_b - 12'd1) begin count_b <= 0; tone_b <= ~tone_b; end
          else count_b <= count_b + 12'd1;
          if (count_c >= period_c - 12'd1) begin count_c <= 0; tone_c <= ~tone_c; end
          else count_c <= count_c + 12'd1;

          if (half)
            begin
              // Noise: 17-bit LFSR, the new bit is bit 0 XOR bit 3
              if (count_noise >= period_noise - 5'd1)
                begin
                  count_noise <= 0;
                  lfsr <= {lfsr[0] ^ lfsr[3], lfsr[16:1]};
                end
              else
                count_noise <= count_noise + 5'd1;

              // Envelope: 16 steps from 15 down to 0, then hold, repeat or
              // alternate the direction
              if (count_env >= period_env - 16'd1)
                begin
                  count_env <= 0;
                  if (!env_holding)
                    begin
                      if (env_step != 0)
                        env_step <= env_step - 4'd1;
                      else
                        begin
                          if (env_alternate)
                            env_attack <= ~env_attack;
                          if (env_hold)
                            env_holding <= 1;
                          else
                            env_step <= 4'd15;
                        end
                    end
                end
              else
                count_env <= count_env + 16'd1;
            end
        end

      // Writing R13 restarts the envelope (after the step logic, so it wins)
      if (write_en && addr == 4'd13)
        begin
          env_step <= 4'd15;
          env_attack <= din[2];
          env_holding <= 0;
          count_env <= 0;
          if (din[3])                 // Continue: hold and alternate as given
            begin
              env_hold <= din[0];
              env_alternate <= din[1];
            end
          else                        // No continue: one ramp, then 0
            begin
              env_hold <= 1;
              env_alternate <= din[2];
            end
        end

      if (reset)
        begin
          half <= 0;
          count_a <= 0;
          count_b <= 0;
          count_c <= 0;
          tone_a <= 0;
          tone_b <= 0;
          tone_c <= 0;
          count_noise <= 0;
          lfsr <= 17'd1;
          count_env <= 0;
          env_step <= 4'd15;
          env_attack <= 0;
          env_hold <= 1;
          env_alternate <= 0;
          env_holding <= 1;
        end
    end

  // ------------------------------------------------------------ Registers

  always @(posedge clk)
    begin
      if (write_en)
        case (addr)
          4'd0:  r0  <= din;
          4'd1:  r1  <= din[3:0];
          4'd2:  r2  <= din;
          4'd3:  r3  <= din[3:0];
          4'd4:  r4  <= din;
          4'd5:  r5  <= din[3:0];
          4'd6:  r6  <= din[4:0];
          4'd7:  r7  <= din[5:0];
          4'd8:  r8  <= din[4:0];
          4'd9:  r9  <= din[4:0];
          4'd10: r10 <= din[4:0];
          4'd11: r11 <= din;
          4'd12: r12 <= din;
          4'd13: r13 <= din[3:0];
          default: ;
        endcase
      if (reset)
        begin
          r0 <= 0; r1 <= 0; r2 <= 0; r3 <= 0; r4 <= 0; r5 <= 0; r6 <= 0;
          r7 <= 0; r8 <= 0; r9 <= 0; r10 <= 0; r11 <= 0; r12 <= 0; r13 <= 0;
        end
      case (addr)
        4'd0:  dout <= r0;
        4'd1:  dout <= {4'd0, r1};
        4'd2:  dout <= r2;
        4'd3:  dout <= {4'd0, r3};
        4'd4:  dout <= r4;
        4'd5:  dout <= {4'd0, r5};
        4'd6:  dout <= {3'd0, r6};
        4'd7:  dout <= {2'd0, r7};
        4'd8:  dout <= {3'd0, r8};
        4'd9:  dout <= {3'd0, r9};
        4'd10: dout <= {3'd0, r10};
        4'd11: dout <= r11;
        4'd12: dout <= r12;
        4'd13: dout <= {4'd0, r13};
        default: dout <= 8'd0;
      endcase
    end
endmodule

`endif
