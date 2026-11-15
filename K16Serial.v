`ifndef K16SERIAL_V
`define K16SERIAL_V

// K16Serial: a serial port (UART) with 8 data bits, no parity, 1 stop bit
// (8N1), and the interrupt cause register.
//
// Registers (addr = address - 0xFFE0):
//   0 DATA      read: the next received byte (bits 7..0), which is removed
//               from the receive buffer (0 if the buffer is empty);
//               write: send a byte (bits 7..0)
//   1 STATUS    read only: bit 0 RX_READY (a byte can be read), bit 1
//               TX_READY (a byte can be written), bit 2 TX_IDLE (all bytes
//               sent), bit 3 OVERRUN (a received byte was lost, the buffer
//               was full), bit 4 FRAMING (a byte without stop bit was
//               dropped); reading STATUS clears bits 3 and 4
//   2 CONTROL   read/write: bits 3..0 bit rate (0 = 115200, 1 = 57600,
//               2 = 38400, 3 = 19200, 4 = 9600, 5 = 4800, 6 = 2400,
//               7 = 1200, 8 = 300, 9..15 like 0), bit 4 receive interrupt
//               enable, bit 5 transmit interrupt enable
//   3 INT_CAUSE read only: bit 0 FRAME (a vertical blanking happened since
//               the last read; reading clears it), bit 1 receive interrupt
//               pending (RX_READY and enabled), bit 2 transmit interrupt
//               pending (TX_READY and enabled)
//
// irq is 1 while bit 1 or 2 of INT_CAUSE is 1 (a level, unlike the one-clock
// frame interrupt of the video). The receive buffer holds 16 bytes.
//
// The CPU has no read strobe, and it keeps an address on the bus for several
// clocks (a store even writes for 2 clocks). So an access counts once: a
// write in its first clock, a read when the CPU leaves the address. The value
// of a read is taken in its first clock and held, so the CPU gets exactly the
// value whose side effect (remove the byte, clear the flags) is applied.
//
// RESET (reset = 1) clears CONTROL (115200, interrupts off), the buffer, and
// the flags, and stops a transmission.

module K16Serial(clk, reset, select, addr, write, din, dout, frame, irq, rx, tx);
  input             clk;
  input             reset;
  input             select;          // The CPU's address is 0xFFE0 .. 0xFFE3
  input      [1:0]  addr;
  input             write;           // The CPU writes
  input      [15:0] din;
  output reg [15:0] dout = 0;
  input             frame;           // Frame interrupt of the video (one clock)
  output            irq;
  input             rx;
  output            tx;

  reg [5:0] control = 0;

  // Clocks per bit at 25 MHz
  function [16:0] clocks_per_bit;
    input [3:0] theRate;
    case (theRate)
      4'd1:    clocks_per_bit = 17'd434;    // 57600
      4'd2:    clocks_per_bit = 17'd651;    // 38400
      4'd3:    clocks_per_bit = 17'd1302;   // 19200
      4'd4:    clocks_per_bit = 17'd2604;   // 9600
      4'd5:    clocks_per_bit = 17'd5208;   // 4800
      4'd6:    clocks_per_bit = 17'd10417;  // 2400
      4'd7:    clocks_per_bit = 17'd20833;  // 1200
      4'd8:    clocks_per_bit = 17'd83333;  // 300
      default: clocks_per_bit = 17'd217;    // 115200
    endcase
  endfunction

  wire [16:0] bit_clocks = clocks_per_bit(control[3:0]);

  // ------------------------------------------------------------ Bus accesses

  wire rd = select && !write;
  wire wr = select && write;
  reg  rd_d = 0;
  reg  wr_d = 0;
  reg  [1:0] rd_addr = 0;              // Register of the read in progress
  reg  rd_valid = 0;                   // A DATA read got a byte
  wire read_start = rd && !rd_d;
  wire read_end   = rd_d && !rd;
  wire write_start = wr && !wr_d;

  // ------------------------------------------------------------ Receive buffer

  reg [7:0] fifo [0:15];
  reg [3:0] fifo_in = 0;
  reg [3:0] fifo_out = 0;
  reg [4:0] fifo_count = 0;
  wire      rx_ready = fifo_count != 0;
  wire      fifo_full = fifo_count[4];

  // ------------------------------------------------------------ Flags

  reg overrun = 0;
  reg framing = 0;
  reg frame_flag = 0;

  // ------------------------------------------------------------ Transmitter

  reg        thr_full = 0;             // Holding register: the next byte
  reg [7:0]  thr = 0;
  reg        tx_busy = 0;
  reg [9:0]  tsr = 10'h3FF;            // Stop bit, 8 data bits, start bit
  reg [3:0]  tx_bits = 0;
  reg [16:0] tx_count = 0;
  assign tx = tx_busy ? tsr[0] : 1'b1;
  wire tx_ready = !thr_full;
  wire tx_idle = !thr_full && !tx_busy;

  // ------------------------------------------------------------ Receiver

  reg        rx_s1 = 1, rx_s2 = 1, rx_s3 = 1;   // Synchronizer, and the value before
  reg [1:0]  rx_state = 0;
  localparam RX_IDLE = 0;
  localparam RX_START = 1;
  localparam RX_DATA = 2;
  localparam RX_STOP = 3;
  reg [16:0] rx_count = 0;
  reg [2:0]  rx_bit = 0;
  reg [7:0]  rx_shift = 0;
  reg        rx_push = 0;               // rx_shift is complete: into the buffer

  assign irq = (rx_ready && control[4]) || (tx_ready && control[5]);

  always @(posedge clk)
    begin
      rd_d <= rd;
      wr_d <= wr;
      rx_s1 <= rx;
      rx_s2 <= rx_s1;
      rx_s3 <= rx_s2;
      rx_push <= 0;

      // ---------------------------------------------------------- Reads

      if (read_start)
        begin
          rd_addr <= addr;
          rd_valid <= rx_ready;
          case (addr)
            2'd0: dout <= {8'h00, rx_ready ? fifo[fifo_out] : 8'h00};
            2'd1: dout <= {11'd0, framing, overrun, tx_idle, tx_ready, rx_ready};
            2'd2: dout <= {10'd0, control};
            2'd3: dout <= {13'd0, tx_ready && control[5], rx_ready && control[4], frame_flag};
          endcase
        end

      // The flags: a new event wins over clearing the reported one
      if (read_end && rd_addr == 2'd1)
        begin
          if (dout[3]) overrun <= 0;
          if (dout[4]) framing <= 0;
        end
      if (read_end && rd_addr == 2'd3 && dout[0])
        frame_flag <= 0;
      if (frame)
        frame_flag <= 1;

      // ---------------------------------------------------------- Writes

      if (write_start && addr == 2'd2)
        control <= din[5:0];

      // ---------------------------------------------------------- Transmitter

      if (tx_busy)
        begin
          if (tx_count >= bit_clocks - 17'd1)
            begin
              tx_count <= 0;
              tsr <= {1'b1, tsr[9:1]};
              if (tx_bits == 4'd9)
                tx_busy <= 0;
              tx_bits <= tx_bits + 4'd1;
            end
          else
            tx_count <= tx_count + 17'd1;
        end
      else if (thr_full)
        begin
          tsr <= {1'b1, thr, 1'b0};
          tx_busy <= 1;
          thr_full <= 0;
          tx_count <= 0;
          tx_bits <= 0;
        end
      // A write while the holding register is full replaces its byte
      if (write_start && addr == 2'd0)
        begin
          thr <= din[7:0];
          thr_full <= 1;
        end

      // ---------------------------------------------------------- Receiver

      case (rx_state)
        RX_IDLE:
          if (rx_s3 && !rx_s2)                       // Falling edge: start bit
            begin
              rx_count <= 0;
              rx_state <= RX_START;
            end
        RX_START:
          if (rx_count >= {1'b0, bit_clocks[16:1]})  // Middle of the start bit
            begin
              rx_count <= 0;
              rx_bit <= 0;
              rx_state <= rx_s2 ? RX_IDLE : RX_DATA; // High again: a glitch
            end
          else
            rx_count <= rx_count + 17'd1;
        RX_DATA:
          if (rx_count >= bit_clocks - 17'd1)        // Middle of a data bit
            begin
              rx_count <= 0;
              rx_shift <= {rx_s2, rx_shift[7:1]};
              rx_bit <= rx_bit + 3'd1;
              if (rx_bit == 3'd7)
                rx_state <= RX_STOP;
            end
          else
            rx_count <= rx_count + 17'd1;
        RX_STOP:
          if (rx_count >= bit_clocks - 17'd1)        // Middle of the stop bit
            begin
              rx_state <= RX_IDLE;
              if (rx_s2)
                rx_push <= 1;
              else
                framing <= 1;
            end
          else
            rx_count <= rx_count + 17'd1;
      endcase

      // ---------------------------------------------------------- Buffer

      if (rx_push && !fifo_full)
        begin
          fifo[fifo_in] <= rx_shift;
          fifo_in <= fifo_in + 4'd1;
        end
      if (rx_push && fifo_full)
        overrun <= 1;
      if (read_end && rd_addr == 2'd0 && rd_valid)
        fifo_out <= fifo_out + 4'd1;
      fifo_count <= fifo_count + {4'd0, rx_push && !fifo_full} - {4'd0, read_end && rd_addr == 2'd0 && rd_valid};

      if (reset)
        begin
          control <= 0;
          fifo_in <= 0;
          fifo_out <= 0;
          fifo_count <= 0;
          overrun <= 0;
          framing <= 0;
          frame_flag <= 0;
          thr_full <= 0;
          tx_busy <= 0;
          rx_state <= RX_IDLE;
          rx_push <= 0;
        end
    end
endmodule

`endif
